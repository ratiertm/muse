"""add persona_id to conversations

Revision ID: b2c3d4e5f6g7
Revises: a1b2c3d4e5f6
Create Date: 2026-03-21

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from app.db.types import GUID

# revision identifiers, used by Alembic.
revision: str = "b2c3d4e5f6g7"
down_revision: Union[str, None] = "a1b2c3d4e5f6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "conversations",
        sa.Column("persona_id", GUID(), nullable=True),
    )
    op.create_foreign_key(
        "fk_conversations_persona_id",
        "conversations",
        "user_personas",
        ["persona_id"],
        ["id"],
        ondelete="SET NULL",
    )
    op.create_index(
        "ix_conversations_persona_id",
        "conversations",
        ["persona_id"],
    )


def downgrade() -> None:
    op.drop_index("ix_conversations_persona_id", table_name="conversations")
    op.drop_constraint("fk_conversations_persona_id", "conversations", type_="foreignkey")
    op.drop_column("conversations", "persona_id")
