"""Group conversation participant model"""
import uuid
from datetime import datetime
from sqlalchemy import DateTime, ForeignKey, Integer, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base
from app.db.types import GUID


class GroupConversationParticipant(Base):
    """Many-to-many relationship between conversations and characters for group chats"""
    
    __tablename__ = "group_conversation_participants"
    
    id: Mapped[uuid.UUID] = mapped_column(
        GUID,
        primary_key=True,
        default=uuid.uuid4,
    )
    conversation_id: Mapped[uuid.UUID] = mapped_column(
        GUID,
        ForeignKey("conversations.id", ondelete="CASCADE"),
        nullable=False,
    )
    character_id: Mapped[uuid.UUID] = mapped_column(
        GUID,
        ForeignKey("characters.id", ondelete="CASCADE"),
        nullable=False,
    )
    turn_order: Mapped[int | None] = mapped_column(
        Integer,
        nullable=True,  # NULL = God Agent decides dynamically
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
    )
    
    # Relationships
    conversation: Mapped["Conversation"] = relationship("Conversation", back_populates="participants")
    character: Mapped["Character"] = relationship("Character")
    
    # Unique constraint: one character can only appear once per conversation
    __table_args__ = (
        UniqueConstraint("conversation_id", "character_id", name="uq_conversation_character"),
    )
