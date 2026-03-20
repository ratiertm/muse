"""User Persona service"""
from uuid import UUID
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.user_persona import UserPersona
from app.schemas.persona import PersonaCreate, PersonaUpdate


class PersonaService:
    """Service for user persona CRUD operations"""

    @staticmethod
    async def create_persona(
        db: AsyncSession, user_id: UUID, data: PersonaCreate
    ) -> UserPersona:
        """Create a new persona"""
        # If this is set as default, unset other defaults
        if data.is_default:
            await PersonaService._clear_defaults(db, user_id)

        persona = UserPersona(
            user_id=user_id,
            name=data.name,
            appearance=data.appearance,
            personality=data.personality,
            description=data.description,
            is_default=data.is_default,
        )
        db.add(persona)
        await db.commit()
        await db.refresh(persona)
        return persona

    @staticmethod
    async def get_personas(db: AsyncSession, user_id: UUID) -> list[UserPersona]:
        """Get all personas for a user"""
        result = await db.execute(
            select(UserPersona)
            .where(UserPersona.user_id == user_id)
            .order_by(UserPersona.is_default.desc(), UserPersona.created_at)
        )
        return list(result.scalars().all())

    @staticmethod
    async def get_persona(
        db: AsyncSession, persona_id: UUID, user_id: UUID
    ) -> UserPersona | None:
        """Get a specific persona"""
        result = await db.execute(
            select(UserPersona).where(
                UserPersona.id == persona_id,
                UserPersona.user_id == user_id,
            )
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def get_default_persona(
        db: AsyncSession, user_id: UUID
    ) -> UserPersona | None:
        """Get the user's default persona"""
        result = await db.execute(
            select(UserPersona).where(
                UserPersona.user_id == user_id,
                UserPersona.is_default == True,
            )
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def update_persona(
        db: AsyncSession, persona_id: UUID, user_id: UUID, data: PersonaUpdate
    ) -> UserPersona | None:
        """Update a persona"""
        persona = await PersonaService.get_persona(db, persona_id, user_id)
        if not persona:
            return None

        if data.is_default:
            await PersonaService._clear_defaults(db, user_id)

        update_data = data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(persona, key, value)

        await db.commit()
        await db.refresh(persona)
        return persona

    @staticmethod
    async def delete_persona(
        db: AsyncSession, persona_id: UUID, user_id: UUID
    ) -> bool:
        """Delete a persona. Returns True if deleted."""
        persona = await PersonaService.get_persona(db, persona_id, user_id)
        if not persona:
            return False
        await db.delete(persona)
        await db.commit()
        return True

    @staticmethod
    async def _clear_defaults(db: AsyncSession, user_id: UUID) -> None:
        """Clear all default flags for a user"""
        result = await db.execute(
            select(UserPersona).where(
                UserPersona.user_id == user_id,
                UserPersona.is_default == True,
            )
        )
        for persona in result.scalars().all():
            persona.is_default = False
