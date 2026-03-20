"""Scenario CRUD endpoints"""
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db
from app.schemas.scenario import (
    ScenarioCreate,
    ScenarioUpdate,
    ScenarioResponse,
    WorldStateUpdate,
    ScenarioCharacterAdd,
    CharacterInScenarioResponse,
)
from app.schemas.common import PaginationParams, PaginatedResponse
from app.services.scenario_service import ScenarioService
from app.core.auth import get_current_user
from app.models.user import User

router = APIRouter()


@router.post("", response_model=ScenarioResponse, status_code=201)
async def create_scenario(
    scenario_data: ScenarioCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create a new scenario"""
    scenario = await ScenarioService.create_scenario(
        db=db,
        user_id=current_user.id,
        scenario_data=scenario_data,
    )
    return scenario


@router.get("", response_model=PaginatedResponse[ScenarioResponse])
async def list_scenarios(
    page: int = Query(default=1, ge=1, description="Page number"),
    per_page: int = Query(default=10, ge=1, le=100, description="Items per page"),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Get scenario list with pagination
    
    - **page**: Page number (1-indexed)
    - **per_page**: Number of items per page (max 100)
    """
    pagination = PaginationParams(page=page, per_page=per_page)
    
    scenarios, total = await ScenarioService.get_scenarios(
        db=db,
        user_id=current_user.id,
        offset=pagination.offset,
        limit=pagination.per_page,
    )
    
    return PaginatedResponse.create(
        items=scenarios,
        total=total,
        page=pagination.page,
        per_page=pagination.per_page,
    )


@router.get("/{scenario_id}", response_model=ScenarioResponse)
async def get_scenario(
    scenario_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get a specific scenario by ID"""
    scenario = await ScenarioService.get_scenario(
        db=db,
        scenario_id=scenario_id,
        user_id=current_user.id,
    )
    
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    return scenario


@router.put("/{scenario_id}", response_model=ScenarioResponse)
async def update_scenario(
    scenario_id: UUID,
    scenario_data: ScenarioUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update a scenario"""
    scenario = await ScenarioService.update_scenario(
        db=db,
        scenario_id=scenario_id,
        user_id=current_user.id,
        scenario_data=scenario_data,
    )
    
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    return scenario


@router.patch("/{scenario_id}/world-state", response_model=ScenarioResponse)
async def update_world_state(
    scenario_id: UUID,
    world_state_data: WorldStateUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update world_state with partial updates (merge)"""
    scenario = await ScenarioService.update_world_state(
        db=db,
        scenario_id=scenario_id,
        user_id=current_user.id,
        world_state_data=world_state_data,
    )
    
    if not scenario:
        raise HTTPException(status_code=404, detail="Scenario not found")
    
    return scenario


@router.delete("/{scenario_id}", status_code=204)
async def delete_scenario(
    scenario_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete a scenario"""
    deleted = await ScenarioService.delete_scenario(
        db=db,
        scenario_id=scenario_id,
        user_id=current_user.id,
    )
    
    if not deleted:
        raise HTTPException(status_code=404, detail="Scenario not found")


# Character management endpoints

@router.post("/{scenario_id}/characters", status_code=201)
async def add_character_to_scenario(
    scenario_id: UUID,
    character_data: ScenarioCharacterAdd,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Add a character to a scenario"""
    added = await ScenarioService.add_character_to_scenario(
        db=db,
        scenario_id=scenario_id,
        character_id=character_data.character_id,
        user_id=current_user.id,
    )
    
    if not added:
        raise HTTPException(
            status_code=400,
            detail="Failed to add character (not found or already exists)",
        )
    
    return {"message": "Character added to scenario successfully"}


@router.get("/{scenario_id}/characters", response_model=list[CharacterInScenarioResponse])
async def get_scenario_characters(
    scenario_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get all characters in a scenario"""
    characters = await ScenarioService.get_scenario_characters(
        db=db,
        scenario_id=scenario_id,
        user_id=current_user.id,
    )
    
    return characters


@router.delete("/{scenario_id}/characters/{character_id}", status_code=204)
async def remove_character_from_scenario(
    scenario_id: UUID,
    character_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Remove a character from a scenario"""
    removed = await ScenarioService.remove_character_from_scenario(
        db=db,
        scenario_id=scenario_id,
        character_id=character_id,
        user_id=current_user.id,
    )
    
    if not removed:
        raise HTTPException(status_code=404, detail="Character not found in scenario")
