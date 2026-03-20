"""Knowledge schemas for API validation"""
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel


class KnowledgeUpdate(BaseModel):
    """Schema for updating character knowledge"""
    known_facts: list[str] | None = None
    unknown_facts: list[str] | None = None


class KnowledgeResponse(BaseModel):
    """Schema for character knowledge responses"""
    id: UUID
    character_id: UUID
    scenario_id: UUID
    known_facts: list[str]
    unknown_facts: list[str]
    created_at: datetime
    updated_at: datetime
    
    model_config = {"from_attributes": True}
