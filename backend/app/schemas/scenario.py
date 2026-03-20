"""Scenario schemas for API validation"""
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field


class WorldStateUpdate(BaseModel):
    """Schema for updating world state"""
    timeline: str | None = None
    location: str | None = None
    current_time: str | None = None
    active_events: list[str] | None = None
    world_facts: list[str] | None = None


class ScenarioBase(BaseModel):
    """Base scenario schema"""
    name: str = Field(..., min_length=1, max_length=200)
    description: str = Field(..., min_length=1)


class ScenarioCreate(ScenarioBase):
    """Schema for creating a new scenario"""
    world_state: dict = Field(default_factory=dict)


class ScenarioUpdate(BaseModel):
    """Schema for updating a scenario (all fields optional)"""
    name: str | None = Field(None, min_length=1, max_length=200)
    description: str | None = Field(None, min_length=1)
    world_state: dict | None = None


class ScenarioResponse(ScenarioBase):
    """Schema for scenario responses"""
    id: UUID
    user_id: UUID
    world_state: dict
    created_at: datetime
    updated_at: datetime
    
    model_config = {"from_attributes": True}


class ScenarioCharacterAdd(BaseModel):
    """Schema for adding a character to a scenario"""
    character_id: UUID


class CharacterInScenarioResponse(BaseModel):
    """Schema for character in scenario response"""
    id: UUID
    name: str
    avatar_url: str | None
    
    model_config = {"from_attributes": True}
