"""Chat streaming endpoints"""
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db
from app.services.character_service import CharacterService
from app.core.llm_client import llm_client
from app.core.prompt_builder import PromptBuilder

router = APIRouter()

# Temporary: hardcoded user_id for testing
TEMP_USER_ID = UUID("00000000-0000-0000-0000-000000000001")


class TestStreamRequest(BaseModel):
    """Request schema for test streaming endpoint"""
    character_id: UUID
    message: str
    model: str = "gpt-4o-mini"


@router.post("/test-stream")
async def test_stream_chat(
    request: TestStreamRequest,
    db: AsyncSession = Depends(get_db),
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
        user_id=TEMP_USER_ID,
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
