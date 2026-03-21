"""Chat and conversation schemas for API validation"""
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field

from app.models.message import MessageRole


class ChatRequest(BaseModel):
    """Request schema for chat endpoint"""
    character_id: UUID = Field(..., description="Character to chat with")
    conversation_id: UUID | None = Field(None, description="Existing conversation ID (creates new if not provided)")
    scenario_id: UUID | None = Field(None, description="Scenario ID for God Agent orchestration (only used when creating new conversation)")
    message: str = Field(..., min_length=1, description="User message")
    model: str | None = Field(None, description="Override model preference")


class ChatMessageResponse(BaseModel):
    """Response schema for a single message"""
    id: UUID
    conversation_id: UUID
    character_id: UUID | None
    role: MessageRole
    content: str
    token_count: int | None
    created_at: datetime
    
    model_config = {"from_attributes": True}


class ConversationResponse(BaseModel):
    """Response schema for conversation"""
    id: UUID
    user_id: UUID
    character_id: UUID | None
    scenario_id: UUID | None
    persona_id: UUID | None = None
    is_group: bool
    title: str
    created_at: datetime
    updated_at: datetime
    
    model_config = {"from_attributes": True}


class ConversationWithMessages(ConversationResponse):
    """Conversation with message list"""
    messages: list[ChatMessageResponse] = Field(default_factory=list)


# ===== Group Chat Schemas =====

class GroupChatCreateRequest(BaseModel):
    """Request schema for creating a group chat"""
    scenario_id: UUID = Field(..., description="Scenario ID for God Agent orchestration")
    character_ids: list[UUID] = Field(..., min_length=2, description="List of character IDs (minimum 2)")
    title: str = Field(..., min_length=1, max_length=500, description="Group chat title")
    persona_id: UUID | None = Field(None, description="User persona ID for personalized interactions")


class GroupChatMessageRequest(BaseModel):
    """Request schema for sending a message in group chat"""
    message: str = Field(..., min_length=1, description="User message")


class GroupChatMessageResponse(BaseModel):
    """Response schema for a single group chat message"""
    character_id: UUID
    character_name: str
    content: str


class GroupChatStreamEvent(BaseModel):
    """SSE event schema for group chat streaming"""
    character_id: UUID | None = None
    character_name: str | None = None
    chunk: str | None = None
    is_done: bool = False


# ===== Message Edit/Delete/Regenerate Schemas =====

class MessageEditRequest(BaseModel):
    """Request schema for editing a message"""
    content: str = Field(..., min_length=1, description="New message content")


class RegenerateRequest(BaseModel):
    """Request schema for regenerating the last assistant message"""
    conversation_id: UUID = Field(..., description="Conversation ID")
    model: str | None = Field(None, description="Override model preference")
