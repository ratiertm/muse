"""Message model"""
import uuid
import enum
from datetime import datetime
from sqlalchemy import String, Text, DateTime, ForeignKey, Integer, Enum
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base
from app.db.types import GUID


class MessageRole(str, enum.Enum):
    """Message role enumeration"""
    USER = "user"
    ASSISTANT = "assistant"
    SYSTEM = "system"


class Message(Base):
    """Message model for chat history (1:1 and group)"""
    
    __tablename__ = "messages"
    
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
    character_id: Mapped[uuid.UUID | None] = mapped_column(
        GUID,
        ForeignKey("characters.id", ondelete="SET NULL"),
        nullable=True,  # NULL for user messages, set for character messages in group chat
    )
    role: Mapped[MessageRole] = mapped_column(
        Enum(MessageRole),
        nullable=False,
    )
    content: Mapped[str] = mapped_column(Text, nullable=False)
    token_count: Mapped[int | None] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
    )
    
    # Relationships
    conversation: Mapped["Conversation"] = relationship("Conversation", back_populates="messages")
    character: Mapped["Character | None"] = relationship("Character")
