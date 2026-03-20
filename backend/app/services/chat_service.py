"""Chat service with conversation and message management"""
from uuid import UUID
from datetime import datetime
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.conversation import Conversation
from app.models.message import Message, MessageRole
from app.models.character import Character


class ChatService:
    """Service for chat and conversation operations"""
    
    @staticmethod
    async def create_conversation(
        db: AsyncSession,
        user_id: UUID,
        character_id: UUID,
        title: str | None = None,
        scenario_id: UUID | None = None,
    ) -> Conversation:
        """Create a new conversation"""
        # Generate default title from character name if not provided
        if not title:
            result = await db.execute(
                select(Character.name).where(Character.id == character_id)
            )
            character_name = result.scalar_one_or_none()
            title = f"Chat with {character_name or 'Character'}"
        
        conversation = Conversation(
            user_id=user_id,
            character_id=character_id,
            scenario_id=scenario_id,
            title=title,
        )
        db.add(conversation)
        await db.commit()
        
        # Re-query to get fresh data
        result = await db.execute(
            select(Conversation).where(Conversation.id == conversation.id)
        )
        return result.scalar_one()
    
    @staticmethod
    async def get_conversation(
        db: AsyncSession,
        conversation_id: UUID,
        user_id: UUID | None = None,
    ) -> Conversation | None:
        """Get a conversation by ID, optionally filtered by user_id"""
        query = select(Conversation).where(Conversation.id == conversation_id)
        if user_id:
            query = query.where(Conversation.user_id == user_id)
        
        result = await db.execute(query)
        return result.scalar_one_or_none()
    
    @staticmethod
    async def get_conversations(
        db: AsyncSession,
        user_id: UUID,
        character_id: UUID | None = None,
        offset: int = 0,
        limit: int = 10,
    ) -> tuple[list[Conversation], int]:
        """
        Get conversations with optional filtering and pagination
        Returns: (conversations, total_count)
        """
        # Base query
        query = select(Conversation).where(Conversation.user_id == user_id)
        count_query = select(func.count(Conversation.id)).where(
            Conversation.user_id == user_id
        )
        
        # Filter by character if provided
        if character_id:
            query = query.where(Conversation.character_id == character_id)
            count_query = count_query.where(Conversation.character_id == character_id)
        
        # Get total count
        total_result = await db.execute(count_query)
        total = total_result.scalar_one()
        
        # Apply pagination and ordering (newest first)
        query = query.order_by(Conversation.updated_at.desc()).offset(offset).limit(limit)
        
        # Execute query
        result = await db.execute(query)
        conversations = list(result.scalars().all())
        
        return conversations, total
    
    @staticmethod
    async def save_message(
        db: AsyncSession,
        conversation_id: UUID,
        role: MessageRole,
        content: str,
        token_count: int | None = None,
    ) -> Message:
        """Save a message to the conversation"""
        message = Message(
            conversation_id=conversation_id,
            role=role,
            content=content,
            token_count=token_count,
        )
        db.add(message)
        
        # Update conversation updated_at
        result = await db.execute(
            select(Conversation).where(Conversation.id == conversation_id)
        )
        conversation = result.scalar_one_or_none()
        if conversation:
            conversation.updated_at = datetime.utcnow()
        
        await db.commit()
        
        # Re-query to get fresh data
        result = await db.execute(
            select(Message).where(Message.id == message.id)
        )
        return result.scalar_one()
    
    @staticmethod
    async def get_messages(
        db: AsyncSession,
        conversation_id: UUID,
        offset: int = 0,
        limit: int = 100,
    ) -> tuple[list[Message], int]:
        """
        Get messages for a conversation with pagination
        Returns: (messages, total_count)
        """
        # Base query
        query = select(Message).where(Message.conversation_id == conversation_id)
        count_query = select(func.count(Message.id)).where(
            Message.conversation_id == conversation_id
        )
        
        # Get total count
        total_result = await db.execute(count_query)
        total = total_result.scalar_one()
        
        # Apply pagination and ordering (oldest first for chat history)
        query = query.order_by(Message.created_at.asc()).offset(offset).limit(limit)
        
        # Execute query
        result = await db.execute(query)
        messages = list(result.scalars().all())
        
        return messages, total
    
    @staticmethod
    async def get_recent_messages(
        db: AsyncSession,
        conversation_id: UUID,
        limit: int = 20,
    ) -> list[Message]:
        """Get most recent messages for context building"""
        query = (
            select(Message)
            .where(Message.conversation_id == conversation_id)
            .order_by(Message.created_at.desc())
            .limit(limit)
        )
        
        result = await db.execute(query)
        messages = list(result.scalars().all())
        
        # Return in chronological order (oldest first)
        return list(reversed(messages))
