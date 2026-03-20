"""Character CRUD endpoints"""
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db
from app.schemas.character import CharacterCreate, CharacterUpdate, CharacterResponse
from app.schemas.common import PaginationParams, PaginatedResponse
from app.services.character_service import CharacterService

router = APIRouter()

# Temporary: hardcoded user_id for testing (will be replaced with auth in Plan 05)
TEMP_USER_ID = UUID("00000000-0000-0000-0000-000000000001")


@router.post("", response_model=CharacterResponse, status_code=201)
async def create_character(
    character_data: CharacterCreate,
    db: AsyncSession = Depends(get_db),
):
    """Create a new character"""
    character = await CharacterService.create_character(
        db=db,
        user_id=TEMP_USER_ID,
        character_data=character_data,
    )
    return character


@router.get("", response_model=PaginatedResponse[CharacterResponse])
async def list_characters(
    tags: list[str] = Query(default=None, description="Filter by tags (all must match)"),
    search: str | None = Query(default=None, description="Search in name/personality/backstory"),
    page: int = Query(default=1, ge=1, description="Page number"),
    per_page: int = Query(default=10, ge=1, le=100, description="Items per page"),
    db: AsyncSession = Depends(get_db),
):
    """
    Get character list with filtering and pagination
    
    - **tags**: Filter by tags (comma-separated in query string)
    - **search**: Search text in name, personality, or backstory
    - **page**: Page number (1-indexed)
    - **per_page**: Number of items per page (max 100)
    """
    pagination = PaginationParams(page=page, per_page=per_page)
    
    characters, total = await CharacterService.get_characters(
        db=db,
        user_id=TEMP_USER_ID,
        tags=tags,
        search=search,
        offset=pagination.offset,
        limit=pagination.per_page,
    )
    
    return PaginatedResponse.create(
        items=characters,
        total=total,
        page=pagination.page,
        per_page=pagination.per_page,
    )


@router.get("/{character_id}", response_model=CharacterResponse)
async def get_character(
    character_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """Get a specific character by ID"""
    character = await CharacterService.get_character(
        db=db,
        character_id=character_id,
        user_id=TEMP_USER_ID,
    )
    
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")
    
    return character


@router.put("/{character_id}", response_model=CharacterResponse)
async def update_character(
    character_id: UUID,
    character_data: CharacterUpdate,
    db: AsyncSession = Depends(get_db),
):
    """Update a character"""
    character = await CharacterService.update_character(
        db=db,
        character_id=character_id,
        user_id=TEMP_USER_ID,
        character_data=character_data,
    )
    
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")
    
    return character


@router.delete("/{character_id}", status_code=204)
async def delete_character(
    character_id: UUID,
    db: AsyncSession = Depends(get_db),
):
    """Delete a character"""
    deleted = await CharacterService.delete_character(
        db=db,
        character_id=character_id,
        user_id=TEMP_USER_ID,
    )
    
    if not deleted:
        raise HTTPException(status_code=404, detail="Character not found")
