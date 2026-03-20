"""CharacterPrivateState model for emotions and secrets"""
import uuid
from datetime import datetime
from sqlalchemy import Text, DateTime, ForeignKey, UniqueConstraint, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base
from app.db.types import GUID


class CharacterPrivateState(Base):
    """Character private state for scenario-specific emotions and secrets"""
    
    __tablename__ = "character_private_state"
    
    id: Mapped[uuid.UUID] = mapped_column(
        GUID,
        primary_key=True,
        default=uuid.uuid4,
    )
    character_id: Mapped[uuid.UUID] = mapped_column(
        GUID,
        ForeignKey("characters.id", ondelete="CASCADE"),
        nullable=False,
    )
    scenario_id: Mapped[uuid.UUID] = mapped_column(
        GUID,
        ForeignKey("scenarios.id", ondelete="CASCADE"),
        nullable=False,
    )
    inner_thoughts: Mapped[str] = mapped_column(
        Text,
        default="",
        nullable=False,
    )
    feelings_toward: Mapped[dict[str, str]] = mapped_column(
        JSON,
        default=dict,
        nullable=False,
    )
    secrets: Mapped[list[str]] = mapped_column(
        JSON,
        default=list,
        nullable=False,
    )
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
    
    # Unique constraint: one private state per character-scenario pair
    __table_args__ = (
        UniqueConstraint("character_id", "scenario_id", name="uq_character_scenario_state"),
    )
    
    # Relationships
    character: Mapped["Character"] = relationship("Character")
    scenario: Mapped["Scenario"] = relationship("Scenario")
