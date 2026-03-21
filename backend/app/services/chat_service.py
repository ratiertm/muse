"""Chat service with conversation and message management"""
from uuid import UUID
from datetime import datetime
from sqlalchemy import select, func, delete
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.conversation import Conversation
from app.models.message import Message, MessageRole
from app.models.character import Character
from app.models.group_conversation_participant import GroupConversationParticipant


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
    
    # ===== Message Edit/Delete/Regenerate =====

    @staticmethod
    async def get_message(
        db: AsyncSession,
        message_id: UUID,
        conversation_id: UUID,
    ) -> Message | None:
        """Get a single message by ID within a conversation"""
        result = await db.execute(
            select(Message).where(
                Message.id == message_id,
                Message.conversation_id == conversation_id,
            )
        )
        return result.scalar_one_or_none()

    @staticmethod
    async def update_message(
        db: AsyncSession,
        message_id: UUID,
        content: str,
    ) -> Message:
        """Update message content"""
        result = await db.execute(
            select(Message).where(Message.id == message_id)
        )
        message = result.scalar_one()
        message.content = content
        await db.commit()
        await db.refresh(message)
        return message

    @staticmethod
    async def delete_message(
        db: AsyncSession,
        message_id: UUID,
    ) -> None:
        """Delete a message"""
        await db.execute(
            delete(Message).where(Message.id == message_id)
        )
        await db.commit()

    @staticmethod
    async def delete_last_assistant_message(
        db: AsyncSession,
        conversation_id: UUID,
    ) -> Message | None:
        """Delete the last assistant message and return it (for regeneration)"""
        result = await db.execute(
            select(Message)
            .where(
                Message.conversation_id == conversation_id,
                Message.role == MessageRole.ASSISTANT,
            )
            .order_by(Message.created_at.desc())
            .limit(1)
        )
        last_msg = result.scalar_one_or_none()
        if last_msg:
            await db.execute(
                delete(Message).where(Message.id == last_msg.id)
            )
            await db.commit()
        return last_msg

    # ===== Group Chat Methods =====
    
    @staticmethod
    async def create_group_conversation(
        db: AsyncSession,
        user_id: UUID,
        scenario_id: UUID,
        character_ids: list[UUID],
        title: str,
        persona_id: UUID | None = None,
    ) -> Conversation:
        """
        Create a new group conversation with multiple characters

        Args:
            db: Database session
            user_id: User creating the conversation
            scenario_id: Scenario for God Agent orchestration
            character_ids: List of character UUIDs to include
            title: Group chat title
            persona_id: Optional user persona ID for personalized interactions

        Returns:
            Created conversation
        """
        # Create conversation with is_group=True and character_id=None
        conversation = Conversation(
            user_id=user_id,
            character_id=None,  # Group chat has no single character
            scenario_id=scenario_id,
            is_group=True,
            title=title,
            persona_id=persona_id,
        )
        db.add(conversation)
        await db.flush()  # Get conversation ID
        
        # Add participants
        for char_id in character_ids:
            participant = GroupConversationParticipant(
                conversation_id=conversation.id,
                character_id=char_id,
                turn_order=None,  # God Agent decides dynamically
            )
            db.add(participant)
        
        await db.commit()
        
        # Re-query to get fresh data with relationships
        result = await db.execute(
            select(Conversation)
            .where(Conversation.id == conversation.id)
            .options(selectinload(Conversation.participants))
        )
        return result.scalar_one()
    
    @staticmethod
    async def get_group_participants(
        db: AsyncSession,
        conversation_id: UUID,
    ) -> list[Character]:
        """
        Get all characters participating in a group conversation
        
        Args:
            db: Database session
            conversation_id: Group conversation ID
        
        Returns:
            List of Character objects
        """
        query = (
            select(Character)
            .join(GroupConversationParticipant, GroupConversationParticipant.character_id == Character.id)
            .where(GroupConversationParticipant.conversation_id == conversation_id)
            .order_by(GroupConversationParticipant.created_at)
        )
        
        result = await db.execute(query)
        return list(result.scalars().all())
    
    @staticmethod
    async def save_group_message(
        db: AsyncSession,
        conversation_id: UUID,
        role: MessageRole,
        content: str,
        character_id: UUID | None = None,
        token_count: int | None = None,
    ) -> Message:
        """
        Save a message in a group conversation
        
        For group chats, character_id indicates which character spoke.
        For user messages, character_id is None.
        
        Args:
            db: Database session
            conversation_id: Conversation ID
            role: Message role (user or assistant)
            content: Message content
            character_id: Character who spoke (None for user)
            token_count: Estimated token count
        
        Returns:
            Saved message
        """
        message = Message(
            conversation_id=conversation_id,
            role=role,
            content=content,
            character_id=character_id,
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
