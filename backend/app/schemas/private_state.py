"""Private state schemas for API validation"""
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel


class PrivateStateUpdate(BaseModel):
    """Schema for updating character private state"""
    inner_thoughts: str | None = None
    feelings_toward: dict[str, str] | None = None
    secrets: list[str] | None = None


class PrivateStateResponse(BaseModel):
    """Schema for character private state responses"""
    id: UUID
    character_id: UUID
    scenario_id: UUID
    inner_thoughts: str
    feelings_toward: dict[str, str]
    secrets: list[str]
    created_at: datetime
    updated_at: datetime
    
    model_config = {"from_attributes": True}
