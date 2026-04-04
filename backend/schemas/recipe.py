"""Pydantic schemas for recipes."""

from pydantic import BaseModel


class RecipeStepSchema(BaseModel):
    id: int
    step_number: int
    instruction: str

    model_config = {"from_attributes": True}


class RecipeIngredientSchema(BaseModel):
    id: int
    name: str
    amount: str | None
    unit: str | None

    model_config = {"from_attributes": True}


class RecipeBase(BaseModel):
    title: str
    description: str | None = None
    difficulty: str
    xp_reward: int = 0
    is_locked: bool = True


class RecipeCreate(RecipeBase):
    pass


class RecipeUpdate(BaseModel):
    title: str | None = None
    description: str | None = None
    difficulty: str | None = None
    xp_reward: int | None = None
    is_locked: bool | None = None


class RecipeResponse(RecipeBase):
    id: int
    steps: list[RecipeStepSchema] = []
    ingredients: list[RecipeIngredientSchema] = []

    model_config = {"from_attributes": True}
