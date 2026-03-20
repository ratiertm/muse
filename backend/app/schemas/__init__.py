"""Pydantic schemas for request/response validation"""
from app.schemas.character import CharacterCreate, CharacterUpdate, CharacterResponse
from app.schemas.common import PaginationParams, PaginatedResponse

__all__ = [
    "CharacterCreate",
    "CharacterUpdate",
    "CharacterResponse",
    "PaginationParams",
    "PaginatedResponse",
]
