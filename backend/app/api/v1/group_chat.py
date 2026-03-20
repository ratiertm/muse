"""Group chat endpoints with God Agent orchestration"""
import asyncio
import json
import logging
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks
from fastapi.responses import StreamingResponse
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db
from app.schemas.chat import (
    GroupChatCreateRequest,
    GroupChatMessageRequest,
    GroupChatStreamEvent,
    ConversationResponse,
)
from app.schemas.character import CharacterResponse
from app.services.chat_service import ChatService
from app.services.character_service import CharacterService
from app.services.scenario_service import ScenarioService
from app.core.llm_client import llm_client
from app.core.prompt_builder import PromptBuilder
from app.core.context_manager import ContextManager
from app.core.god_agent import GodAgent
from app.core.auth import get_current_user
from app.models.user import User
from app.models.message import MessageRole

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("", response_model=ConversationResponse)
async def create_group_chat(
    request: GroupChatCreateRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Create a new group conversation
    
    Creates a group chat with multiple characters in a scenario.
    Requires at least 2 characters and a valid scenario.
    
    Args:
        scenario_id: Scenario ID for God Agent orchestration
        character_ids: List of character IDs (minimum 2)
        title: Group chat title
    
    Returns:
        Created conversation
    """
    # Verify scenario exists and belongs to user
    scenario = await ScenarioService.get_scenario(db, request.scenario_id)
    if not scenario or scenario.user_id != current_user.id:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    # Verify all characters exist and belong to user
    for char_id in request.character_ids:
        character = await CharacterService.get_character(
            db=db,
            character_id=char_id,
            user_id=current_user.id,
        )
        if not character:
            raise HTTPException(
                status_code=404,
                detail=f"Character {char_id} not found"
            )
    
    # Create group conversation
    conversation = await ChatService.create_group_conversation(
        db=db,
        user_id=current_user.id,
        scenario_id=request.scenario_id,
        character_ids=request.character_ids,
        title=request.title,
    )
    
    logger.info(f"Created group conversation {conversation.id} with {len(request.character_ids)} characters")
    
    return conversation


@router.get("/{conversation_id}/participants", response_model=list[CharacterResponse])
async def get_group_participants(
    conversation_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Get all participants in a group conversation
    
    Args:
        conversation_id: Group conversation ID
    
    Returns:
        List of characters in the group
    """
    # Verify conversation exists and belongs to user
    conversation = await ChatService.get_conversation(
        db=db,
        conversation_id=conversation_id,
        user_id=current_user.id,
    )
    
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    if not conversation.is_group:
        raise HTTPException(status_code=400, detail="Not a group conversation")
    
    # Get participants
    participants = await ChatService.get_group_participants(db, conversation_id)
    
    return participants


@router.post("/{conversation_id}/message")
async def send_group_message(
    conversation_id: UUID,
    request: GroupChatMessageRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Send a message in a group chat and get streamed responses from multiple characters
    
    Flow:
    1. God Agent decides which character(s) should respond
    2. For each responding character:
       - God Agent generates briefing (with knowledge filtering)
       - Character Agent generates response (streamed)
       - Response is saved with character_id
       - God Agent updates world state (background)
    3. All responses are streamed as SSE events
    
    Args:
        conversation_id: Group conversation ID
        message: User message text
    
    Returns:
        SSE stream with character responses
        Event format: {"character_id": "...", "character_name": "...", "chunk": "...", "is_done": false}
        Final event: {"is_done": true}
    """
    # Verify conversation exists and belongs to user
    conversation = await ChatService.get_conversation(
        db=db,
        conversation_id=conversation_id,
        user_id=current_user.id,
    )
    
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    if not conversation.is_group:
        raise HTTPException(status_code=400, detail="Not a group conversation")
    
    if not conversation.scenario_id:
        raise HTTPException(status_code=400, detail="Group chat requires a scenario")
    
    # Get scenario
    scenario = await ScenarioService.get_scenario(db, conversation.scenario_id)
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    # Get all participants
    participants = await ChatService.get_group_participants(db, conversation_id)
    
    if not participants:
        raise HTTPException(status_code=400, detail="No participants in group chat")
    
    # Save user message
    await ChatService.save_group_message(
        db=db,
        conversation_id=conversation_id,
        role=MessageRole.USER,
        content=request.message,
        character_id=None,  # User message
    )
    
    # Get recent conversation history
    history_messages = await ChatService.get_recent_messages(
        db=db,
        conversation_id=conversation_id,
        limit=30,
    )
    
    # Convert to dict format for God Agent
    conversation_history = [
        {"role": msg.role.value, "content": msg.content}
        for msg in history_messages
    ]
    
    # Initialize God Agent
    god_agent = GodAgent(llm_client, model="gpt-4o-mini")
    
    # === STEP 1: God Agent decides who responds ===
    responding_character_ids = await god_agent.decide_next_speakers(
        db=db,
        scenario=scenario,
        participants=participants,
        user_message=request.message,
        conversation_history=conversation_history,
    )
    
    logger.info(f"God Agent selected {len(responding_character_ids)} characters to respond")
    
    # Get responding characters
    responding_characters = [
        char for char in participants
        if char.id in responding_character_ids
    ]
    
    # === STEP 2: Stream responses from each character ===
    async def event_generator():
        """Generate SSE events for each character's response"""
        
        for character in responding_characters:
            logger.info(f"Generating response for {character.name}")
            
            # Generate briefing for this character
            briefing = await god_agent.brief_character(
                db=db,
                character=character,
                scenario=scenario,
                user_message=request.message,
                conversation_history=conversation_history,
            )
            
            # Build system prompt with briefing
            system_prompt = PromptBuilder.build_prompt_with_briefing(
                character=character,
                briefing=briefing,
                user_name="User",
            )
            
            # Build context messages
            context_messages = ContextManager.prepare_context_messages(
                system_prompt=system_prompt,
                conversation_history=history_messages,
                max_history_tokens=3000,
            )
            
            # Add current user message
            context_messages.append({"role": "user", "content": request.message})
            
            # Stream character response
            character_response = ""
            
            try:
                # Send character header event
                header_event = GroupChatStreamEvent(
                    character_id=character.id,
                    character_name=character.name,
                    chunk="",
                    is_done=False,
                )
                yield f"data: {header_event.model_dump_json()}\n\n"
                
                # Stream response chunks
                async for chunk in llm_client.stream(
                    messages=context_messages,
                    model="claude-sonnet-4-20250514",  # Use Claude for character responses
                    temperature=0.7,
                    max_tokens=1000,
                ):
                    character_response += chunk
                    
                    # Send chunk event
                    chunk_event = GroupChatStreamEvent(
                        character_id=character.id,
                        character_name=character.name,
                        chunk=chunk,
                        is_done=False,
                    )
                    yield f"data: {chunk_event.model_dump_json()}\n\n"
                
                # Save character message
                await ChatService.save_group_message(
                    db=db,
                    conversation_id=conversation_id,
                    role=MessageRole.ASSISTANT,
                    content=character_response,
                    character_id=character.id,
                )
                
                # Schedule God Agent update as background task
                async def update_god_state():
                    """Background task to update God Agent state"""
                    try:
                        from app.dependencies import get_db
                        async for bg_db in get_db():
                            bg_god_agent = GodAgent(llm_client, model="gpt-4o-mini")
                            
                            # Re-fetch scenario and character
                            bg_scenario = await ScenarioService.get_scenario(bg_db, scenario.id)
                            bg_character = await CharacterService.get_character(bg_db, character.id)
                            bg_participants = await ChatService.get_group_participants(bg_db, conversation_id)
                            
                            if bg_scenario and bg_character:
                                await bg_god_agent.observe_and_update_group(
                                    db=bg_db,
                                    speaker_character=bg_character,
                                    scenario=bg_scenario,
                                    user_message=request.message,
                                    assistant_response=character_response,
                                    present_characters=bg_participants,
                                )
                                logger.info(f"God Agent group state updated for {character.name}")
                            
                            break
                    except Exception as e:
                        logger.error(f"Failed to update God Agent group state: {e}")
                
                background_tasks.add_task(update_god_state)
                
                logger.info(f"Completed response for {character.name}")
                
            except Exception as e:
                logger.error(f"Error generating response for {character.name}: {e}")

                error_event = GroupChatStreamEvent(
                    character_id=character.id,
                    character_name=character.name,
                    chunk=f"\n\n[{character.name}의 응답 생성 중 오류가 발생했습니다]",
                    is_done=False,
                )
                yield f"data: {error_event.model_dump_json()}\n\n"
        
        # Send final done event
        done_event = GroupChatStreamEvent(is_done=True)
        yield f"data: {done_event.model_dump_json()}\n\n"
    
    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
            "X-Conversation-Id": str(conversation_id),
        },
    )
