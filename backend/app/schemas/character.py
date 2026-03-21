"""Character schemas for API validation"""
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field


class CharacterBase(BaseModel):
    """Base character schema with common fields"""
    name: str = Field(..., min_length=1, max_length=200)
    personality: str = Field(..., min_length=1)
    speech_style: str = Field(..., min_length=1)
    backstory: str = Field(..., min_length=1)
    scenario: str = Field(default="", description="Optional scenario context")
    first_message: str = Field(default="", description="Character's first message")
    example_dialogue: str = Field(default="", description="Example conversation")
    tags: list[str] = Field(default_factory=list)
    avatar_url: str | None = None
    model_preference: str | None = None


class CharacterCreate(CharacterBase):
    """Schema for creating a new character"""
    is_public: bool = False


class CharacterUpdate(BaseModel):
    """Schema for updating a character (all fields optional)"""
    name: str | None = Field(None, min_length=1, max_length=200)
    personality: str | None = Field(None, min_length=1)
    speech_style: str | None = Field(None, min_length=1)
    backstory: str | None = Field(None, min_length=1)
    scenario: str | None = None
    first_message: str | None = None
    example_dialogue: str | None = None
    tags: list[str] | None = None
    avatar_url: str | None = None
    model_preference: str | None = None


class CharacterResponse(CharacterBase):
    """Schema for character responses"""
    id: UUID
    user_id: UUID
    is_public: bool = False
    is_mine: bool = False
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}


class CharacterAutoGenerateRequest(BaseModel):
    """Schema for auto-generating character from source work"""
    source_work: str = Field(..., min_length=1, max_length=200, description="원작 작품명 (예: 죠죠의 기묘한 모험)")
    character_name: str = Field(..., min_length=1, max_length=200, description="캐릭터 이름 (예: 디오)")
