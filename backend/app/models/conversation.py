"""Conversation model"""
import uuid
from datetime import datetime
from sqlalchemy import String, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base
from app.db.types import GUID


class Conversation(Base):
    """Conversation model for chat sessions (1:1 and group)"""
    
    __tablename__ = "conversations"
    
    id: Mapped[uuid.UUID] = mapped_column(
        GUID,
        primary_key=True,
        default=uuid.uuid4,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        GUID,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )
    character_id: Mapped[uuid.UUID | None] = mapped_column(
        GUID,
        ForeignKey("characters.id", ondelete="CASCADE"),
        nullable=True,  # Nullable for group chats
    )
    scenario_id: Mapped[uuid.UUID | None] = mapped_column(
        GUID,
        ForeignKey("scenarios.id", ondelete="SET NULL"),
        nullable=True,
    )
    is_group: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False,
    )
    title: Mapped[str] = mapped_column(String(500), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
        nullable=False,
    )
    
    # Relationships
    user: Mapped["User"] = relationship("User", back_populates="conversations")
    character: Mapped["Character | None"] = relationship("Character", back_populates="conversations")
    scenario: Mapped["Scenario | None"] = relationship("Scenario", back_populates="conversations")
    messages: Mapped[list["Message"]] = relationship(
        "Message",
        back_populates="conversation",
        cascade="all, delete-orphan",
        order_by="Message.created_at",
    )
    participants: Mapped[list["GroupConversationParticipant"]] = relationship(
        "GroupConversationParticipant",
        back_populates="conversation",
        cascade="all, delete-orphan",
    )
