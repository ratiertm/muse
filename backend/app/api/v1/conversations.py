"""Conversation endpoints"""
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db
from app.schemas.chat import ConversationResponse, ChatMessageResponse, MessageEditRequest
from app.schemas.common import PaginatedResponse
from app.services.chat_service import ChatService
from app.core.auth import get_current_user
from app.models.user import User

router = APIRouter()


@router.get("", response_model=PaginatedResponse[ConversationResponse])
async def list_conversations(
    character_id: UUID | None = Query(default=None, description="Filter by character ID"),
    page: int = Query(default=1, ge=1, description="Page number"),
    per_page: int = Query(default=10, ge=1, le=100, description="Items per page"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Get conversation list for current user
    
    - **character_id**: Filter by specific character (optional)
    - **page**: Page number (1-indexed)
    - **per_page**: Number of items per page (max 100)
    """
    offset = (page - 1) * per_page
    
    conversations, total = await ChatService.get_conversations(
        db=db,
        user_id=current_user.id,
        character_id=character_id,
        offset=offset,
        limit=per_page,
    )
    
    return PaginatedResponse.create(
        items=conversations,
        total=total,
        page=page,
        per_page=per_page,
    )


@router.get("/{conversation_id}", response_model=ConversationResponse)
async def get_conversation(
    conversation_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get a specific conversation by ID"""
    conversation = await ChatService.get_conversation(
        db=db,
        conversation_id=conversation_id,
        user_id=current_user.id,
    )
    
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    return conversation


@router.get("/{conversation_id}/messages", response_model=PaginatedResponse[ChatMessageResponse])
async def get_conversation_messages(
    conversation_id: UUID,
    page: int = Query(default=1, ge=1, description="Page number"),
    per_page: int = Query(default=100, ge=1, le=500, description="Items per page"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Get message history for a conversation
    
    - **page**: Page number (1-indexed)
    - **per_page**: Number of messages per page (max 500)
    """
    # Verify conversation exists and belongs to user
    conversation = await ChatService.get_conversation(
        db=db,
        conversation_id=conversation_id,
        user_id=current_user.id,
    )
    
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")
    
    offset = (page - 1) * per_page
    
    messages, total = await ChatService.get_messages(
        db=db,
        conversation_id=conversation_id,
        offset=offset,
        limit=per_page,
    )
    
    return PaginatedResponse.create(
        items=messages,
        total=total,
        page=page,
        per_page=per_page,
    )


@router.patch(
    "/{conversation_id}/messages/{message_id}",
    response_model=ChatMessageResponse,
)
async def edit_message(
    conversation_id: UUID,
    message_id: UUID,
    request: MessageEditRequest,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Edit a message's content"""
    # Verify conversation belongs to user
    conversation = await ChatService.get_conversation(
        db=db,
        conversation_id=conversation_id,
        user_id=current_user.id,
    )
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")

    # Verify message exists in conversation
    message = await ChatService.get_message(db, message_id, conversation_id)
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")

    updated = await ChatService.update_message(db, message_id, request.content)
    return updated


@router.delete(
    "/{conversation_id}/messages/{message_id}",
    status_code=204,
)
async def delete_message(
    conversation_id: UUID,
    message_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete a message"""
    # Verify conversation belongs to user
    conversation = await ChatService.get_conversation(
        db=db,
        conversation_id=conversation_id,
        user_id=current_user.id,
    )
    if not conversation:
        raise HTTPException(status_code=404, detail="Conversation not found")

    # Verify message exists in conversation
    message = await ChatService.get_message(db, message_id, conversation_id)
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")

    await ChatService.delete_message(db, message_id)
