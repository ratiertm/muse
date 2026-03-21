"""Character service with CRUD business logic"""
from uuid import UUID
from sqlalchemy import select, func, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.character import Character
from app.schemas.character import CharacterCreate, CharacterUpdate


class CharacterService:
    """Service for character CRUD operations"""
    
    @staticmethod
    async def create_character(
        db: AsyncSession,
        user_id: UUID,
        character_data: CharacterCreate,
    ) -> Character:
        """Create a new character"""
        character = Character(
            user_id=user_id,
            **character_data.model_dump(),
        )
        db.add(character)
        await db.commit()
        # Re-query to get fresh data
        result = await db.execute(
            select(Character).where(Character.id == character.id)
        )
        return result.scalar_one()
    
    @staticmethod
    async def get_character(
        db: AsyncSession,
        character_id: UUID,
        user_id: UUID | None = None,
    ) -> Character | None:
        """Get a character by ID. Public characters are accessible by anyone."""
        query = select(Character).where(Character.id == character_id)
        if user_id:
            query = query.where(
                or_(Character.user_id == user_id, Character.is_public == True)
            )

        result = await db.execute(query)
        return result.scalar_one_or_none()
    
    @staticmethod
    async def get_characters(
        db: AsyncSession,
        user_id: UUID | None = None,
        tags: list[str] | None = None,
        search: str | None = None,
        offset: int = 0,
        limit: int = 10,
    ) -> tuple[list[Character], int]:
        """
        Get characters with optional filtering and pagination
        Returns: (characters, total_count)
        """
        # Base query
        query = select(Character)
        count_query = select(func.count(Character.id))
        
        # Filter: public OR owned by user
        if user_id:
            access_filter = or_(Character.user_id == user_id, Character.is_public == True)
            query = query.where(access_filter)
            count_query = count_query.where(access_filter)
        
        # Filter by tags (any match)
        if tags:
            for tag in tags:
                query = query.where(Character.tags.contains([tag]))
                count_query = count_query.where(Character.tags.contains([tag]))
        
        # Search by name, personality, or backstory
        if search:
            search_pattern = f"%{search}%"
            search_filter = or_(
                Character.name.ilike(search_pattern),
                Character.personality.ilike(search_pattern),
                Character.backstory.ilike(search_pattern),
            )
            query = query.where(search_filter)
            count_query = count_query.where(search_filter)
        
        # Get total count
        total_result = await db.execute(count_query)
        total = total_result.scalar_one()
        
        # Apply pagination and ordering
        query = query.order_by(Character.created_at.desc()).offset(offset).limit(limit)
        
        # Execute query
        result = await db.execute(query)
        characters = list(result.scalars().all())
        
        return characters, total
    
    @staticmethod
    async def update_character(
        db: AsyncSession,
        character_id: UUID,
        user_id: UUID,
        character_data: CharacterUpdate,
    ) -> Character | None:
        """Update a character (owner only)"""
        character = await CharacterService.get_character(db, character_id)
        if not character or character.user_id != user_id:
            return None
        
        # Update only provided fields
        update_data = character_data.model_dump(exclude_unset=True)
        for field, value in update_data.items():
            setattr(character, field, value)
        
        await db.commit()
        # Re-query to get fresh data
        result = await db.execute(
            select(Character).where(Character.id == character_id)
        )
        return result.scalar_one()
    
    @staticmethod
    async def delete_character(
        db: AsyncSession,
        character_id: UUID,
        user_id: UUID,
    ) -> bool:
        """Delete a character (owner only). Returns True if deleted, False if not found."""
        character = await CharacterService.get_character(db, character_id)
        if not character or character.user_id != user_id:
            return False
        
        await db.delete(character)
        await db.commit()
        return True
