"""Initial schema

Revision ID: 001
Revises:
Create Date: 2026-04-04
"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = "001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "users",
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column("username", sa.String(50), unique=True, nullable=False),
        sa.Column("email", sa.String(255), unique=True, nullable=False),
        sa.Column("xp", sa.Integer, default=0),
        sa.Column("level", sa.Integer, default=1),
        sa.Column("created_at", sa.DateTime, server_default=sa.func.now()),
    )
    op.create_table(
        "recipes",
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column("title", sa.String(100), nullable=False),
        sa.Column("description", sa.Text),
        sa.Column("difficulty", sa.String(20), nullable=False),
        sa.Column("xp_reward", sa.Integer, default=0),
        sa.Column("is_locked", sa.Boolean, default=True),
        sa.Column("created_at", sa.DateTime, server_default=sa.func.now()),
    )
    op.create_table(
        "recipe_steps",
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column("recipe_id", sa.Integer, sa.ForeignKey("recipes.id"), nullable=False),
        sa.Column("step_number", sa.Integer, nullable=False),
        sa.Column("instruction", sa.Text, nullable=False),
    )
    op.create_table(
        "recipe_ingredients",
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column("recipe_id", sa.Integer, sa.ForeignKey("recipes.id"), nullable=False),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("amount", sa.String(50)),
        sa.Column("unit", sa.String(30)),
    )
    op.create_table(
        "user_recipes",
        sa.Column("user_id", sa.Integer, sa.ForeignKey("users.id"), primary_key=True),
        sa.Column("recipe_id", sa.Integer, sa.ForeignKey("recipes.id"), primary_key=True),
        sa.Column("completed_at", sa.DateTime, nullable=True),
        sa.Column("photo_url", sa.String(500), nullable=True),
        sa.Column("unlocked_at", sa.DateTime, server_default=sa.func.now()),
    )
    op.create_table(
        "friendships",
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column("user_id", sa.Integer, sa.ForeignKey("users.id"), nullable=False),
        sa.Column("friend_id", sa.Integer, sa.ForeignKey("users.id"), nullable=False),
        sa.Column("status", sa.String(20), default="pending"),
    )


def downgrade() -> None:
    op.drop_table("friendships")
    op.drop_table("user_recipes")
    op.drop_table("recipe_ingredients")
    op.drop_table("recipe_steps")
    op.drop_table("recipes")
    op.drop_table("users")
