"""CharacterKnowledge model for knowledge graph"""
import uuid
from datetime import datetime
from sqlalchemy import DateTime, ForeignKey, UniqueConstraint, JSON
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.database import Base
from app.db.types import GUID


class CharacterKnowledge(Base):
    """Character knowledge graph for scenario-specific facts"""
    
    __tablename__ = "character_knowledge"
    
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
    known_facts: Mapped[list[str]] = mapped_column(
        JSON,
        default=list,
        nullable=False,
    )
    unknown_facts: Mapped[list[str]] = mapped_column(
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
    
    # Unique constraint: one knowledge record per character-scenario pair
    __table_args__ = (
        UniqueConstraint("character_id", "scenario_id", name="uq_character_scenario_knowledge"),
    )
    
    # Relationships
    character: Mapped["Character"] = relationship("Character")
    scenario: Mapped["Scenario"] = relationship("Scenario")
