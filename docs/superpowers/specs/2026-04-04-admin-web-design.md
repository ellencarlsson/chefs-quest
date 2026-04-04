# Design: Web Admin — Add and Manage Recipes (Issue #14)

## Summary

A localhost web admin page for adding and managing recipes. Plain HTML + CSS + JavaScript, no framework. Connects directly to the local FastAPI backend.

The UI already exists in `admin/index.html`. The missing piece is that ingredients and steps are collected in the form but not sent to or stored by the backend.

## Scope

- Extend `RecipeCreate` schema to accept nested ingredients and steps
- Update `create_recipe` endpoint to persist them in the same transaction
- Update `admin/index.html` to include ingredients and steps in the POST body

Out of scope: editing existing recipes, authentication, deployment.

## Backend Changes

### New input schemas (`backend/schemas/recipe.py`)

```python
class IngredientCreate(BaseModel):
    name: str
    amount: str | None = None
    unit: str | None = None

class StepCreate(BaseModel):
    step_number: int
    instruction: str
```

`RecipeCreate` gains two new fields:

```python
class RecipeCreate(RecipeBase):
    ingredients: list[IngredientCreate] = []
    steps: list[StepCreate] = []
```

### Updated endpoint (`backend/routers/recipes.py`)

`create_recipe` iterates over `body.ingredients` and `body.steps`, creates `RecipeIngredient` and `RecipeStep` objects, attaches them to the recipe, and commits in one transaction.

## Frontend Changes

### `admin/index.html`

In the `save-btn` click handler, add `ingredients` and `steps` to the POST body:

```js
const body = {
  title, description, difficulty, xp_reward,
  is_locked: false,
  ingredients: getIngredients(),
  steps: getSteps(),
};
```

`getIngredients()` and `getSteps()` already exist and return the correct structure — no changes needed there.

## Data Flow

1. User fills in the form and clicks Save
2. Frontend collects all fields including ingredients and steps
3. `POST /recipes/` with full body
4. Backend creates `Recipe`, then `RecipeIngredient` and `RecipeStep` rows in one transaction
5. Returns `RecipeResponse` (already includes `ingredients` and `steps`)
6. Frontend reloads the recipe list
