"""Chat streaming endpoints"""
import asyncio
import logging
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.dependencies import get_db
from app.schemas.chat import ChatRequest, RegenerateRequest
from app.services.character_service import CharacterService
from app.services.chat_service import ChatService
from app.services.scenario_service import ScenarioService
from app.core.llm_client import llm_client
from app.core.prompt_builder import PromptBuilder
from app.core.context_manager import ContextManager
from app.core.god_agent import GodAgent
from app.core.auth import get_current_user
from app.services.persona_service import PersonaService
from app.models.user import User
from app.models.message import MessageRole
from app.models.scenario import Scenario

logger = logging.getLogger(__name__)

router = APIRouter()


class TestStreamRequest(BaseModel):
    """Request schema for test streaming endpoint"""
    character_id: UUID
    message: str
    model: str = "gpt-4o-mini"


@router.post("/test-stream")
async def test_stream_chat(
    request: TestStreamRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Test endpoint for SSE streaming chat
    
    Sends a message to a character and streams the response via Server-Sent Events.
    This is a simplified test endpoint without conversation history or persistence.
    
    Args:
        character_id: UUID of the character to chat with
        message: User message text
        model: LLM model to use (default: gpt-4o-mini)
    
    Returns:
        SSE stream of response chunks
    """
    # Get character
    character = await CharacterService.get_character(
        db=db,
        character_id=request.character_id,
        user_id=current_user.id,
    )
    
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")
    
    # Build messages
    messages = PromptBuilder.build_messages(
        character=character,
        user_message=request.message,
        conversation_history=None,  # No history for test endpoint
        user_name="User",
    )
    
    # Stream response
    async def event_generator():
        """Generate SSE events from LLM stream"""
        try:
            async for chunk in llm_client.stream(
                messages=messages,
                model=request.model,
                temperature=0.7,
                max_tokens=1000,
            ):
                # Send as SSE event
                yield f"data: {chunk}\n\n"
            
            # Send end marker
            yield "data: [DONE]\n\n"
            
        except Exception as e:
            # Send generic error event (don't expose internal details)
            logger.error(f"Test stream error: {e}")
            yield f"data: Error: 응답 생성 중 오류가 발생했습니다.\n\n"
            yield "data: [DONE]\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",  # Disable nginx buffering
        },
    )


@router.post("")
async def stream_chat(
    request: ChatRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Main chat endpoint with conversation management and streaming
    
    - Auto-creates conversation on first message
    - Inserts character's first_message if conversation is new
    - Saves both user and assistant messages
    - Applies sliding window context management
    - Streams response via SSE
    - Uses God Agent flow when scenario_id is present
    
    Args:
        character_id: UUID of the character to chat with
        conversation_id: Existing conversation ID (optional, creates new if not provided)
        scenario_id: Scenario ID for God Agent orchestration (only when creating new conversation)
        message: User message text
        model: Override model preference (optional)
    
    Returns:
        SSE stream of response chunks
    """
    # Get character
    character = await CharacterService.get_character(
        db=db,
        character_id=request.character_id,
        user_id=current_user.id,
    )
    
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")
    
    # Get or create conversation
    conversation = None
    is_new_conversation = False
    
    if request.conversation_id:
        # Use existing conversation
        conversation = await ChatService.get_conversation(
            db=db,
            conversation_id=request.conversation_id,
            user_id=current_user.id,
        )
        if not conversation:
            raise HTTPException(status_code=404, detail="Conversation not found")
        
        # Verify conversation belongs to the character
        if conversation.character_id != request.character_id:
            raise HTTPException(
                status_code=400,
                detail="Conversation does not belong to this character"
            )
    else:
        # Create new conversation with optional scenario_id
        conversation = await ChatService.create_conversation(
            db=db,
            user_id=current_user.id,
            character_id=request.character_id,
            scenario_id=request.scenario_id,
        )
        is_new_conversation = True
    
    # If new conversation and character has first_message, insert it
    if is_new_conversation and character.first_message:
        await ChatService.save_message(
            db=db,
            conversation_id=conversation.id,
            role=MessageRole.ASSISTANT,
            content=character.first_message,
        )
    
    # Save user message
    user_message = await ChatService.save_message(
        db=db,
        conversation_id=conversation.id,
        role=MessageRole.USER,
        content=request.message,
    )
    
    # Get recent conversation history for context
    history_messages = await ChatService.get_recent_messages(
        db=db,
        conversation_id=conversation.id,
        limit=30,  # Get last 30 messages for context
    )
    
    # Filter out the user message we just saved
    history_for_context = [
        msg for msg in history_messages
        if msg.id != user_message.id
    ]
    
    # Load user's default persona for prompt personalization
    persona = await PersonaService.get_default_persona(db, current_user.id)

    # Check if this conversation uses God Agent (has scenario_id)
    scenario = None
    system_prompt = None

    if conversation.scenario_id:
        # === GOD AGENT FLOW ===
        logger.info(f"Using God Agent flow for conversation {conversation.id} with scenario {conversation.scenario_id}")
        
        # Load scenario
        scenario = await ScenarioService.get_scenario(db, conversation.scenario_id)
        if not scenario:
            raise HTTPException(status_code=404, detail="Scenario not found")
        
        # Initialize God Agent
        god_agent = GodAgent(llm_client, model="gpt-4o-mini")
        
        # Convert history to dict format for God Agent
        conversation_history_dicts = [
            {"role": msg.role.value, "content": msg.content}
            for msg in history_for_context
        ]
        
        # Generate briefing
        briefing = await god_agent.brief_character(
            db=db,
            character=character,
            scenario=scenario,
            user_message=request.message,
            conversation_history=conversation_history_dicts,
        )
        
        logger.info(f"Generated God Agent briefing for {character.name}")
        
        # Build system prompt WITH briefing
        system_prompt = PromptBuilder.build_prompt_with_briefing(
            character=character,
            briefing=briefing,
            user_name=persona.name if persona else "User",
            persona=persona,
        )
        
        # Use Claude Sonnet for character responses (God Agent uses GPT-4o-mini)
        model = request.model or "claude-sonnet-4-20250514"
    else:
        # === STANDARD FLOW (Phase 1) ===
        logger.info(f"Using standard flow for conversation {conversation.id}")
        
        system_prompt = PromptBuilder.build_system_prompt(
            character=character,
            user_name=persona.name if persona else "User",
            persona=persona,
        )
        
        # Determine model to use
        model = request.model or character.model_preference or "gpt-4o-mini"
    
    # Build context messages
    context_messages = ContextManager.prepare_context_messages(
        system_prompt=system_prompt,
        conversation_history=history_for_context,
        max_history_tokens=3000,
    )
    
    # Add current user message
    context_messages.append({"role": "user", "content": request.message})
    
    # Stream response
    async def event_generator():
        """Generate SSE events from LLM stream and save response"""
        assistant_response = ""
        
        try:
            async for chunk in llm_client.stream(
                messages=context_messages,
                model=model,
                temperature=0.7,
                max_tokens=1000,
            ):
                assistant_response += chunk
                # Send as SSE event
                yield f"data: {chunk}\n\n"
            
            # Save assistant response
            await ChatService.save_message(
                db=db,
                conversation_id=conversation.id,
                role=MessageRole.ASSISTANT,
                content=assistant_response,
            )
            
            # If using God Agent, schedule observe_and_update as background task
            if scenario:
                logger.info(f"Scheduling God Agent observe_and_update for {character.name}")
                
                # Background task to update world state
                async def update_god_state():
                    """Background task to update God Agent state"""
                    try:
                        # Create new DB session for background task
                        from app.dependencies import get_db
                        async for bg_db in get_db():
                            god_agent = GodAgent(llm_client, model="gpt-4o-mini")
                            
                            # Re-fetch scenario and character for background task
                            bg_scenario = await ScenarioService.get_scenario(bg_db, conversation.scenario_id)
                            bg_character = await CharacterService.get_character(bg_db, character.id)
                            
                            if bg_scenario and bg_character:
                                await god_agent.observe_and_update(
                                    db=bg_db,
                                    character=bg_character,
                                    scenario=bg_scenario,
                                    user_message=request.message,
                                    assistant_response=assistant_response,
                                )
                                logger.info(f"God Agent state updated for scenario {conversation.scenario_id}")
                            
                            break  # Exit after first (only) iteration
                    except Exception as e:
                        logger.error(f"Failed to update God Agent state: {e}")
                
                # Schedule as background task
                background_tasks.add_task(update_god_state)
            
            # Send end marker
            yield "data: [DONE]\n\n"
            
        except Exception as e:
            # Send generic error event (don't expose internal details)
            logger.error(f"Chat stream error: {e}")
            yield f"data: Error: 응답 생성 중 오류가 발생했습니다.\n\n"
            yield "data: [DONE]\n\n"
    
    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
            "X-Conversation-Id": str(conversation.id),  # Return conversation ID in header
        },
    )


@router.post("/regenerate")
async def regenerate_response(
    request: RegenerateRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Regenerate (swipe) the last assistant message.

    Deletes the last assistant message and re-generates a new response
    based on the same conversation context.
    """
    # Get conversation
    conversation = await ChatService.get_conversation(
        db=db,
        conversation_id=request.conversation_id,
        user_id=current_user.id,
    )
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")

    # Delete last assistant message
    deleted_msg = await ChatService.delete_last_assistant_message(
        db=db, conversation_id=conversation.id
    )
    if not deleted_msg:
        raise HTTPException(status_code=400, detail="No assistant message to regenerate")

    # Get the character for this conversation
    character = await CharacterService.get_character(
        db=db,
        character_id=conversation.character_id,
        user_id=current_user.id,
    )
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")

    # Get conversation history (now without the deleted message)
    history_messages = await ChatService.get_recent_messages(
        db=db, conversation_id=conversation.id, limit=30
    )

    # Load user's default persona
    persona = await PersonaService.get_default_persona(db, current_user.id)
    user_name = persona.name if persona else "User"

    # Build context (same logic as stream_chat)
    scenario = None
    system_prompt = None

    if conversation.scenario_id:
        scenario = await ScenarioService.get_scenario(db, conversation.scenario_id)
        god_agent = GodAgent(llm_client, model="gpt-4o-mini")
        conversation_history_dicts = [
            {"role": msg.role.value, "content": msg.content}
            for msg in history_messages
        ]
        # Find the last user message for briefing
        last_user_msg = ""
        for msg in reversed(history_messages):
            if msg.role.value == "user":
                last_user_msg = msg.content
                break

        briefing = await god_agent.brief_character(
            db=db,
            character=character,
            scenario=scenario,
            user_message=last_user_msg,
            conversation_history=conversation_history_dicts,
        )
        system_prompt = PromptBuilder.build_prompt_with_briefing(
            character=character, briefing=briefing, user_name=user_name, persona=persona
        )
        model = request.model or "claude-sonnet-4-20250514"
    else:
        system_prompt = PromptBuilder.build_system_prompt(
            character=character, user_name=user_name, persona=persona
        )
        model = request.model or character.model_preference or "gpt-4o-mini"

    context_messages = ContextManager.prepare_context_messages(
        system_prompt=system_prompt,
        conversation_history=history_messages,
        max_history_tokens=3000,
    )

    async def event_generator():
        assistant_response = ""
        try:
            async for chunk in llm_client.stream(
                messages=context_messages,
                model=model,
                temperature=0.8,  # Slightly higher for variety on regeneration
                max_tokens=1000,
            ):
                assistant_response += chunk
                yield f"data: {chunk}\n\n"

            # Save new assistant response
            await ChatService.save_message(
                db=db,
                conversation_id=conversation.id,
                role=MessageRole.ASSISTANT,
                content=assistant_response,
            )

            if scenario:
                last_user_msg = ""
                for msg in reversed(history_messages):
                    if msg.role.value == "user":
                        last_user_msg = msg.content
                        break

                async def update_god_state():
                    try:
                        from app.dependencies import get_db
                        async for bg_db in get_db():
                            bg_god = GodAgent(llm_client, model="gpt-4o-mini")
                            bg_scenario = await ScenarioService.get_scenario(bg_db, conversation.scenario_id)
                            bg_character = await CharacterService.get_character(bg_db, character.id)
                            if bg_scenario and bg_character:
                                await bg_god.observe_and_update(
                                    db=bg_db,
                                    character=bg_character,
                                    scenario=bg_scenario,
                                    user_message=last_user_msg,
                                    assistant_response=assistant_response,
                                )
                            break
                    except Exception as e:
                        logger.error(f"Failed to update God Agent state: {e}")

                background_tasks.add_task(update_god_state)

            yield "data: [DONE]\n\n"

        except Exception as e:
            logger.error(f"Regenerate stream error: {e}")
            yield f"data: Error: 응답 재생성 중 오류가 발생했습니다.\n\n"
            yield "data: [DONE]\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
            "X-Conversation-Id": str(conversation.id),
        },
    )
