"""Knowledge service for character knowledge management"""
from uuid import UUID
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.exc import IntegrityError

from app.models.character_knowledge import CharacterKnowledge


class KnowledgeService:
    """Service for character knowledge CRUD operations"""
    
    @staticmethod
    async def get_or_create_knowledge(
        db: AsyncSession,
        character_id: UUID,
        scenario_id: UUID,
    ) -> CharacterKnowledge:
        """Get or create knowledge record for character-scenario pair"""
        # Try to get existing
        query = select(CharacterKnowledge).where(
            CharacterKnowledge.character_id == character_id,
            CharacterKnowledge.scenario_id == scenario_id,
        )
        result = await db.execute(query)
        knowledge = result.scalar_one_or_none()
        
        if knowledge:
            return knowledge
        
        # Create new
        try:
            knowledge = CharacterKnowledge(
                character_id=character_id,
                scenario_id=scenario_id,
                known_facts=[],
                unknown_facts=[],
            )
            db.add(knowledge)
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
    async def add_known_fact(
        db: AsyncSession,
        character_id: UUID,
        scenario_id: UUID,
        fact: str,
    ) -> CharacterKnowledge:
        """Add a fact to known_facts"""
        knowledge = await KnowledgeService.get_or_create_knowledge(
            db, character_id, scenario_id
        )
        
        if fact not in knowledge.known_facts:
            knowledge.known_facts = knowledge.known_facts + [fact]
            await db.commit()
            # Re-query to get fresh data
            result = await db.execute(
                select(CharacterKnowledge).where(CharacterKnowledge.id == knowledge.id)
            )
            knowledge = result.scalar_one()
        
        return knowledge
    
    @staticmethod
    async def add_unknown_fact(
        db: AsyncSession,
        character_id: UUID,
        scenario_id: UUID,
        fact: str,
    ) -> CharacterKnowledge:
        """Add a fact to unknown_facts"""
        knowledge = await KnowledgeService.get_or_create_knowledge(
            db, character_id, scenario_id
        )
        
        if fact not in knowledge.unknown_facts:
            knowledge.unknown_facts = knowledge.unknown_facts + [fact]
            await db.commit()
            # Re-query to get fresh data
            result = await db.execute(
                select(CharacterKnowledge).where(CharacterKnowledge.id == knowledge.id)
            )
            knowledge = result.scalar_one()
        
        return knowledge
    
    @staticmethod
    async def move_to_known(
        db: AsyncSession,
        character_id: UUID,
        scenario_id: UUID,
        fact: str,
    ) -> CharacterKnowledge:
        """Move a fact from unknown_facts to known_facts"""
        knowledge = await KnowledgeService.get_or_create_knowledge(
            db, character_id, scenario_id
        )
        
        # Remove from unknown if present
        unknown_facts = [f for f in knowledge.unknown_facts if f != fact]
        
        # Add to known if not already there
        known_facts = knowledge.known_facts if fact in knowledge.known_facts else knowledge.known_facts + [fact]
        
        knowledge.unknown_facts = unknown_facts
        knowledge.known_facts = known_facts
        
        await db.commit()
        # Re-query to get fresh data
        result = await db.execute(
            select(CharacterKnowledge).where(CharacterKnowledge.id == knowledge.id)
        )
        return result.scalar_one()
    
    @staticmethod
    async def get_knowledge(
        db: AsyncSession,
        character_id: UUID,
        scenario_id: UUID,
    ) -> CharacterKnowledge | None:
        """Get knowledge record for character-scenario pair"""
        query = select(CharacterKnowledge).where(
            CharacterKnowledge.character_id == character_id,
            CharacterKnowledge.scenario_id == scenario_id,
        )
        result = await db.execute(query)
        return result.scalar_one_or_none()
