"""Add user_personas table (REQ-09)

Revision ID: a1b2c3d4e5f6
Revises: 80e52326d13f
Create Date: 2026-03-20 16:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from app.db.types import GUID


# revision identifiers, used by Alembic.
revision: str = 'a1b2c3d4e5f6'
down_revision: Union[str, Sequence[str], None] = '80e52326d13f'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Upgrade schema."""
    op.create_table('user_personas',
        sa.Column('id', GUID(length=36), nullable=False),
        sa.Column('user_id', GUID(length=36), nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('appearance', sa.Text(), nullable=True),
        sa.Column('personality', sa.Text(), nullable=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('is_default', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('created_at', sa.DateTime(), nullable=False),
        sa.Column('updated_at', sa.DateTime(), nullable=False),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.PrimaryKeyConstraint('id')
    )
    op.create_index('ix_user_personas_user_id', 'user_personas', ['user_id'])


def downgrade() -> None:
    """Downgrade schema."""
    op.drop_index('ix_user_personas_user_id', table_name='user_personas')
    op.drop_table('user_personas')
