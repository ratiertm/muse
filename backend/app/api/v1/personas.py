"""User Persona CRUD endpoints (REQ-09)"""
from uuid import UUID
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db
from app.schemas.persona import PersonaCreate, PersonaUpdate, PersonaResponse
from app.services.persona_service import PersonaService
from app.core.auth import get_current_user
from app.models.user import User

router = APIRouter()


@router.get("", response_model=list[PersonaResponse])
async def list_personas(
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get all personas for the current user"""
    return await PersonaService.get_personas(db, current_user.id)


@router.post("", response_model=PersonaResponse, status_code=201)
async def create_persona(
    request: PersonaCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Create a new persona"""
    return await PersonaService.create_persona(db, current_user.id, request)


@router.get("/{persona_id}", response_model=PersonaResponse)
async def get_persona(
    persona_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Get a specific persona"""
    persona = await PersonaService.get_persona(db, persona_id, current_user.id)
    if not persona:
        raise HTTPException(status_code=404, detail="Persona not found")
    return persona


@router.patch("/{persona_id}", response_model=PersonaResponse)
async def update_persona(
    persona_id: UUID,
    request: PersonaUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Update a persona"""
    persona = await PersonaService.update_persona(
        db, persona_id, current_user.id, request
    )
    if not persona:
        raise HTTPException(status_code=404, detail="Persona not found")
    return persona


@router.delete("/{persona_id}", status_code=204)
async def delete_persona(
    persona_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Delete a persona"""
    deleted = await PersonaService.delete_persona(db, persona_id, current_user.id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Persona not found")
