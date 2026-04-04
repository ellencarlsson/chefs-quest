"""Add image_url to recipes

Revision ID: 003
Revises: 002
Create Date: 2026-04-04
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = "003"
down_revision: Union[str, None] = "002"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "recipes",
        sa.Column("image_url", sa.String(500), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("recipes", "image_url")
