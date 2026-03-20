"""Private state service for character emotional state management"""
from uuid import UUID
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import IntegrityError

from app.models.character_private_state import CharacterPrivateState


class PrivateStateService:
    """Service for character private state CRUD operations"""
    
    @staticmethod
    async def get_or_create_state(
        db: AsyncSession,
        character_id: UUID,
        scenario_id: UUID,
    ) -> CharacterPrivateState:
        """Get or create private state for character-scenario pair"""
        # Try to get existing
        query = select(CharacterPrivateState).where(
            CharacterPrivateState.character_id == character_id,
            CharacterPrivateState.scenario_id == scenario_id,
        )
        result = await db.execute(query)
        state = result.scalar_one_or_none()
        
        if state:
            return state
        
        # Create new
        try:
            state = CharacterPrivateState(
                character_id=character_id,
                scenario_id=scenario_id,
                inner_thoughts="",
                feelings_toward={},
                secrets=[],
            )
            db.add(state)
            await db.commit()
            # Re-query to get fresh data
            result = await db.execute(query)
            return result.scalar_one()
        except IntegrityError:
            # Race condition: another process created it
            await db.rollback()
            result = await db.execute(query)
            return result.scalar_one()
    
    @staticmethod
    async def update_inner_thoughts(
        db: AsyncSession,
        character_id: UUID,
        scenario_id: UUID,
        thoughts: str,
    ) -> CharacterPrivateState:
        """Update inner thoughts (overwrites)"""
        state = await PrivateStateService.get_or_create_state(
            db, character_id, scenario_id
        )
        
        state.inner_thoughts = thoughts
        await db.commit()
        
        # Re-query to get fresh data
        result = await db.execute(
            select(CharacterPrivateState).where(CharacterPrivateState.id == state.id)
        )
        return result.scalar_one()
    
    @staticmethod
    async def update_feeling(
        db: AsyncSession,
        character_id: UUID,
        scenario_id: UUID,
        target: str,
        sentiment: str,
    ) -> CharacterPrivateState:
        """Update feeling toward a specific target"""
        state = await PrivateStateService.get_or_create_state(
            db, character_id, scenario_id
        )
        
        # Update feelings_toward dict
        feelings = state.feelings_toward.copy() if state.feelings_toward else {}
        feelings[target] = sentiment
        state.feelings_toward = feelings
        
        await db.commit()
        
        # Re-query to get fresh data
        result = await db.execute(
            select(CharacterPrivateState).where(CharacterPrivateState.id == state.id)
        )
        return result.scalar_one()
    
    @staticmethod
    async def add_secret(
        db: AsyncSession,
        character_id: UUID,
        scenario_id: UUID,
        secret: str,
    ) -> CharacterPrivateState:
        """Add a secret to the secrets list"""
        state = await PrivateStateService.get_or_create_state(
            db, character_id, scenario_id
        )
        
        if secret not in state.secrets:
            state.secrets = state.secrets + [secret]
            await db.commit()
            # Re-query to get fresh data
            result = await db.execute(
                select(CharacterPrivateState).where(CharacterPrivateState.id == state.id)
            )
            state = result.scalar_one()
        
        return state
    
    @staticmethod
    async def get_state(
        db: AsyncSession,
        character_id: UUID,
        scenario_id: UUID,
    ) -> CharacterPrivateState | None:
        """Get private state for character-scenario pair"""
        query = select(CharacterPrivateState).where(
            CharacterPrivateState.character_id == character_id,
            CharacterPrivateState.scenario_id == scenario_id,
        )
        result = await db.execute(query)
        return result.scalar_one_or_none()
