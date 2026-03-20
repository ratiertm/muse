"""Scenario service with CRUD business logic"""
from uuid import UUID
from sqlalchemy import select, func, delete
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import IntegrityError

from app.models.scenario import Scenario
from app.models.scenario_character import ScenarioCharacter
from app.models.character import Character
from app.schemas.scenario import ScenarioCreate, ScenarioUpdate, WorldStateUpdate


class ScenarioService:
    """Service for scenario CRUD operations"""
    
    @staticmethod
    async def create_scenario(
        db: AsyncSession,
        user_id: UUID,
        scenario_data: ScenarioCreate,
    ) -> Scenario:
        """Create a new scenario"""
        scenario = Scenario(
            user_id=user_id,
            **scenario_data.model_dump(),
        )
        db.add(scenario)
        await db.commit()
        # Re-query to get fresh data
        result = await db.execute(
            select(Scenario).where(Scenario.id == scenario.id)
        )
        return result.scalar_one()
    
    @staticmethod
    async def get_scenario(
        db: AsyncSession,
        scenario_id: UUID,
        user_id: UUID | None = None,
    ) -> Scenario | None:
        """Get a scenario by ID, optionally filtered by user_id"""
        query = select(Scenario).where(Scenario.id == scenario_id)
        if user_id:
            query = query.where(Scenario.user_id == user_id)
        
        result = await db.execute(query)
        return result.scalar_one_or_none()
    
    @staticmethod
    async def get_scenarios(
        db: AsyncSession,
        user_id: UUID | None = None,
        offset: int = 0,
        limit: int = 10,
    ) -> tuple[list[Scenario], int]:
        """
        Get scenarios with optional filtering and pagination
        Returns: (scenarios, total_count)
        """
        # Base query
        query = select(Scenario)
        count_query = select(func.count(Scenario.id))
        
        # Filter by user
        if user_id:
            query = query.where(Scenario.user_id == user_id)
            count_query = count_query.where(Scenario.user_id == user_id)
        
        # Get total count
        total_result = await db.execute(count_query)
        total = total_result.scalar_one()
        
        # Apply pagination and ordering
        query = query.order_by(Scenario.created_at.desc()).offset(offset).limit(limit)
        
        # Execute query
        result = await db.execute(query)
        scenarios = list(result.scalars().all())
        
        return scenarios, total
    
    @staticmethod
    async def update_scenario(
        db: AsyncSession,
        scenario_id: UUID,
        user_id: UUID,
        scenario_data: ScenarioUpdate,
    ) -> Scenario | None:
        """Update a scenario"""
        scenario = await ScenarioService.get_scenario(db, scenario_id, user_id)
        if not scenario:
            return None
        
        # Update only provided fields
        update_data = scenario_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(scenario, field, value)
        
        await db.commit()
        # Re-query to get fresh data
        result = await db.execute(
            select(Scenario).where(Scenario.id == scenario_id)
        )
        return result.scalar_one()
    
    @staticmethod
    async def update_world_state(
        db: AsyncSession,
        scenario_id: UUID,
        user_id: UUID,
        world_state_data: WorldStateUpdate,
    ) -> Scenario | None:
        """Update world_state with partial updates (merge)"""
        scenario = await ScenarioService.get_scenario(db, scenario_id, user_id)
        if not scenario:
            return None
        
        # Merge updates into existing world_state
        current_state = scenario.world_state or {}
        update_data = world_state_data.model_dump(exclude_unset=True)
        
        for key, value in update_data.items():
            if value is not None:
                current_state[key] = value
        
        scenario.world_state = current_state
        await db.commit()
        
        # Re-query to get fresh data
        result = await db.execute(
            select(Scenario).where(Scenario.id == scenario_id)
        )
        return result.scalar_one()
    
    @staticmethod
    async def delete_scenario(
        db: AsyncSession,
        scenario_id: UUID,
        user_id: UUID,
    ) -> bool:
        """Delete a scenario. Returns True if deleted, False if not found."""
        scenario = await ScenarioService.get_scenario(db, scenario_id, user_id)
        if not scenario:
            return False
        
        await db.delete(scenario)
        await db.commit()
        return True
    
    # ScenarioCharacter operations
    
    @staticmethod
    async def add_character_to_scenario(
        db: AsyncSession,
        scenario_id: UUID,
        character_id: UUID,
        user_id: UUID,
    ) -> bool:
        """
        Add a character to a scenario.
        Returns True if added, False if scenario/character not found or already exists.
        """
        # Verify scenario belongs to user
        scenario = await ScenarioService.get_scenario(db, scenario_id, user_id)
        if not scenario:
            return False
        
        # Verify character belongs to user
        result = await db.execute(
            select(Character).where(
                Character.id == character_id,
                Character.user_id == user_id,
            )
        )
        character = result.scalar_one_or_none()
        if not character:
            return False
        
        # Add to scenario
        try:
            scenario_character = ScenarioCharacter(
                scenario_id=scenario_id,
                character_id=character_id,
            )
            db.add(scenario_character)
            await db.commit()
            return True
        except IntegrityError:
            # Already exists
            await db.rollback()
            return False
    
    @staticmethod
    async def get_scenario_characters(
        db: AsyncSession,
        scenario_id: UUID,
        user_id: UUID,
    ) -> list[Character]:
        """Get all characters in a scenario"""
        # Verify scenario belongs to user
        scenario = await ScenarioService.get_scenario(db, scenario_id, user_id)
        if not scenario:
            return []
        
        # Get characters through junction table
        query = (
            select(Character)
            .join(ScenarioCharacter, ScenarioCharacter.character_id == Character.id)
            .where(ScenarioCharacter.scenario_id == scenario_id)
            .order_by(ScenarioCharacter.created_at)
        )
        
        result = await db.execute(query)
        return list(result.scalars().all())
    
    @staticmethod
    async def remove_character_from_scenario(
        db: AsyncSession,
        scenario_id: UUID,
        character_id: UUID,
        user_id: UUID,
    ) -> bool:
        """
        Remove a character from a scenario.
        Returns True if removed, False if not found.
        """
        # Verify scenario belongs to user
        scenario = await ScenarioService.get_scenario(db, scenario_id, user_id)
        if not scenario:
            return False
        
        # Delete junction record
        query = delete(ScenarioCharacter).where(
            ScenarioCharacter.scenario_id == scenario_id,
            ScenarioCharacter.character_id == character_id,
        )
        
        result = await db.execute(query)
        await db.commit()
        
        return result.rowcount > 0
