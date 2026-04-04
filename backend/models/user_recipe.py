"""UserRecipe model — tracks completed and unlocked recipes per user."""

from datetime import datetime
from sqlalchemy import Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import Mapped, mapped_column, relationship
from backend.database import Base


class UserRecipe(Base):
    __tablename__ = "user_recipes"

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), primary_key=True)
    recipe_id: Mapped[int] = mapped_column(ForeignKey("recipes.id"), primary_key=True)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    photo_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    unlocked_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    user: Mapped["User"] = relationship(back_populates="completed_recipes")
    recipe: Mapped["Recipe"] = relationship(back_populates="user_recipes")
