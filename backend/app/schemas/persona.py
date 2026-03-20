"""User Persona schemas"""
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field


class PersonaCreate(BaseModel):
    """Request schema for creating a persona"""
    name: str = Field(..., min_length=1, max_length=100)
    appearance: str | None = Field(None, max_length=2000)
    personality: str | None = Field(None, max_length=2000)
    description: str | None = Field(None, max_length=2000)
    is_default: bool = False


class PersonaUpdate(BaseModel):
    """Request schema for updating a persona"""
    name: str | None = Field(None, min_length=1, max_length=100)
    appearance: str | None = Field(None, max_length=2000)
    personality: str | None = Field(None, max_length=2000)
    description: str | None = Field(None, max_length=2000)
    is_default: bool | None = None


class PersonaResponse(BaseModel):
    """Response schema for a persona"""
    id: UUID
    user_id: UUID
    name: str
    appearance: str | None
    personality: str | None
    description: str | None
    is_default: bool
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
