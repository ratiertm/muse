"""Chat and conversation schemas for API validation"""
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field

from app.models.message import MessageRole


class ChatRequest(BaseModel):
    """Request schema for chat endpoint"""
    character_id: UUID = Field(..., description="Character to chat with")
    conversation_id: UUID | None = Field(None, description="Existing conversation ID (creates new if not provided)")
    message: str = Field(..., min_length=1, description="User message")
    model: str | None = Field(None, description="Override model preference")


class ChatMessageResponse(BaseModel):
    """Response schema for a single message"""
    id: UUID
    conversation_id: UUID
    role: MessageRole
    content: str
    token_count: int | None
    created_at: datetime
    
    model_config = {"from_attributes": True}


class ConversationResponse(BaseModel):
    """Response schema for conversation"""
    id: UUID
    user_id: UUID
    character_id: UUID
    scenario_id: UUID | None
    title: str
    created_at: datetime
    updated_at: datetime
    
    model_config = {"from_attributes": True}


class ConversationWithMessages(ConversationResponse):
    """Conversation with message list"""
    messages: list[ChatMessageResponse] = Field(default_factory=list)
