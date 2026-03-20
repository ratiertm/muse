"""Chat streaming endpoints"""
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db
from app.schemas.chat import ChatRequest
from app.services.character_service import CharacterService
from app.services.chat_service import ChatService
from app.core.llm_client import llm_client
from app.core.prompt_builder import PromptBuilder
from app.core.context_manager import ContextManager
from app.core.auth import get_current_user
from app.models.user import User
from app.models.message import MessageRole

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
            # Send error event
            error_msg = f"Error: {str(e)}"
            yield f"data: {error_msg}\n\n"
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
    
    Args:
        character_id: UUID of the character to chat with
        conversation_id: Existing conversation ID (optional, creates new if not provided)
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
        # Create new conversation
        conversation = await ChatService.create_conversation(
            db=db,
            user_id=current_user.id,
            character_id=request.character_id,
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
    
    # Build context with sliding window
    # Filter out the user message we just saved (it'll be added by PromptBuilder)
    history_for_context = [
        msg for msg in history_messages
        if msg.id != user_message.id
    ]
    
    system_prompt = PromptBuilder.build_system_prompt(
        character=character,
        user_name="User",
    )
    
    context_messages = ContextManager.prepare_context_messages(
        system_prompt=system_prompt,
        conversation_history=history_for_context,
        max_history_tokens=3000,
    )
    
    # Add current user message
    context_messages.append({"role": "user", "content": request.message})
    
    # Determine model to use
    model = request.model or character.model_preference or "gpt-4o-mini"
    
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
            
            # Send end marker
            yield "data: [DONE]\n\n"
            
        except Exception as e:
            # Send error event
            error_msg = f"Error: {str(e)}"
            yield f"data: {error_msg}\n\n"
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
