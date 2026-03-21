"""Scenario schemas for API validation"""
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field, field_validator


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
    purpose: str = Field(default="", description="시나리오의 목적/목표")


class ScenarioCreate(ScenarioBase):
    """Schema for creating a new scenario"""
    world_state: dict = Field(default_factory=dict)
    is_public: bool = False


class ScenarioUpdate(BaseModel):
    """Schema for updating a scenario (all fields optional)"""
    name: str | None = Field(None, min_length=1, max_length=200)
    description: str | None = Field(None, min_length=1)
    purpose: str | None = None
    world_state: dict | None = None
    is_public: bool | None = None


class ScenarioResponse(ScenarioBase):
    """Schema for scenario responses"""
    id: UUID
    user_id: UUID
    world_state: dict = Field(default_factory=dict)
    is_public: bool = False
    is_mine: bool = False
    character_avatars: list[dict] = Field(default_factory=list, description="캐릭터 이름+아바타 목록")
    created_at: datetime
    updated_at: datetime

    @field_validator("world_state", mode="before")
    @classmethod
    def ensure_world_state_dict(cls, v):
        if v is None:
            return {}
        return v

    model_config = {"from_attributes": True}


class ScenarioCharacterAdd(BaseModel):
    """Schema for adding a character to a scenario"""
    character_id: UUID


class ScenarioAutoGenerateRequest(BaseModel):
    """Schema for auto-generating scenario from source work"""
    source_work: str = Field(..., min_length=1, max_length=200, description="원작 작품명")


class CharacterInScenarioResponse(BaseModel):
    """Schema for character in scenario response"""
    id: UUID
    name: str
    avatar_url: str | None
    
    model_config = {"from_attributes": True}
