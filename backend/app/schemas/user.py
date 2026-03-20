"""User schemas for API validation"""
from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field


class UserCreate(BaseModel):
    """Schema for creating a new user"""
    name: str = Field(..., min_length=1, max_length=100, description="Username")
    pin: str = Field(..., min_length=4, max_length=20, description="PIN for authentication")
    avatar_url: str | None = Field(None, description="Optional avatar URL")


class UserResponse(BaseModel):
    """Schema for user responses"""
    id: UUID
    name: str
    avatar_url: str | None
    created_at: datetime
    
    model_config = {"from_attributes": True}


class LoginRequest(BaseModel):
    """Schema for login request"""
    name: str = Field(..., description="Username")
    pin: str = Field(..., description="PIN")


class TokenResponse(BaseModel):
    """Schema for authentication token response"""
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
