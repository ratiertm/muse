"""Character CRUD endpoints"""
import logging
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

logger = logging.getLogger(__name__)

from app.dependencies import get_db
from app.schemas.character import (
    CharacterCreate,
    CharacterUpdate,
    CharacterResponse,
    CharacterAutoGenerateRequest,
)
from app.schemas.common import PaginationParams, PaginatedResponse
from app.services.character_service import CharacterService
from app.core.auth import get_current_user
from app.core.auto_generator import auto_generator
from app.core.avatar_generator import get_avatar_generator
from app.models.user import User

router = APIRouter()


@router.post("", response_model=CharacterResponse, status_code=201)
async def create_character(
    character_data: CharacterCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create a new character"""
    character = await CharacterService.create_character(
        db=db,
        user_id=current_user.id,
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
    current_user: User = Depends(get_current_user),
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
        user_id=current_user.id,
        tags=tags,
        search=search,
        offset=pagination.offset,
        limit=pagination.per_page,
    )

    # Add is_mine flag
    items = []
    for c in characters:
        resp = CharacterResponse.model_validate(c)
        resp.is_mine = (c.user_id == current_user.id)
        items.append(resp)

    return PaginatedResponse.create(
        items=items,
        total=total,
        page=pagination.page,
        per_page=pagination.per_page,
    )


@router.get("/{character_id}", response_model=CharacterResponse)
async def get_character(
    character_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get a specific character by ID"""
    character = await CharacterService.get_character(
        db=db,
        character_id=character_id,
        user_id=current_user.id,
    )
    
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")
    
    return character


@router.put("/{character_id}", response_model=CharacterResponse)
async def update_character(
    character_id: UUID,
    character_data: CharacterUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update a character"""
    character = await CharacterService.update_character(
        db=db,
        character_id=character_id,
        user_id=current_user.id,
        character_data=character_data,
    )
    
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")
    
    return character


@router.delete("/{character_id}", status_code=204)
async def delete_character(
    character_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete a character"""
    deleted = await CharacterService.delete_character(
        db=db,
        character_id=character_id,
        user_id=current_user.id,
    )
    
    if not deleted:
        raise HTTPException(status_code=404, detail="Character not found")


@router.post("/auto-generate", response_model=CharacterCreate)
async def auto_generate_character(
    request: CharacterAutoGenerateRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Auto-generate a character from source work and character name
    
    Uses LLM to generate personality, speech style, backstory, scenario,
    first message, example dialogue, and tags based on the source work.
    
    Returns pre-filled CharacterCreate data for user to review/edit.
    Does NOT save to database - user must save via POST /characters.
    
    Args:
        source_work: 원작 작품명 (예: "죠죠의 기묘한 모험")
        character_name: 캐릭터 이름 (예: "디오")
    
    Returns:
        CharacterCreate: Pre-filled character data ready for editing/saving
    """
    try:
        character = await auto_generator.generate_from_source(
            source_work=request.source_work,
            character_name=request.character_name,
        )
        return character
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"자동 생성 실패: {str(e)}")


@router.post("/{character_id}/generate-avatar")
async def generate_character_avatar(
    character_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Generate an anime-style avatar for a character using DALL-E 3
    
    Creates an anime-style portrait based on the character's personality
    and backstory. Updates the character's avatar_url in the database.
    
    Args:
        character_id: Character ID
    
    Returns:
        {"avatar_url": str} - URL of the generated avatar
    """
    # Get character
    character = await CharacterService.get_character(
        db=db,
        character_id=character_id,
        user_id=current_user.id,
    )
    
    if not character:
        raise HTTPException(status_code=404, detail="Character not found")
    
    try:
        # Generate avatar
        avatar_url = await get_avatar_generator().generate_avatar(character)
        
        # Update character with new avatar URL
        await CharacterService.update_character(
            db=db,
            character_id=character_id,
            user_id=current_user.id,
            character_data=CharacterUpdate(avatar_url=avatar_url),
        )
        
        return {"avatar_url": avatar_url}
        
    except Exception as e:
        logger.error(f"Avatar generation failed: {e}")
        raise HTTPException(status_code=500, detail="아바타 생성에 실패했습니다.")
