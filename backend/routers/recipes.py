"""Recipe CRUD endpoints."""

import shutil
import uuid
from pathlib import Path
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from backend.database import get_db
from backend.models.recipe import Recipe
from backend.models.recipe_ingredient import RecipeIngredient
from backend.models.recipe_step import RecipeStep
from backend.schemas.recipe import RecipeCreate, RecipeUpdate, RecipeResponse

IMAGES_DIR = Path(__file__).parent.parent / "static" / "images"
IMAGES_DIR.mkdir(parents=True, exist_ok=True)

router = APIRouter(prefix="/recipes", tags=["recipes"])


@router.get("/", response_model=list[RecipeResponse])
def list_recipes(db: Session = Depends(get_db)):
    return db.query(Recipe).all()


@router.get("/{recipe_id}", response_model=RecipeResponse)
def get_recipe(recipe_id: int, db: Session = Depends(get_db)):
    recipe = db.get(Recipe, recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    return recipe


@router.post("/", response_model=RecipeResponse, status_code=201)
def create_recipe(body: RecipeCreate, db: Session = Depends(get_db)):
    data = body.model_dump(exclude={"ingredients", "steps"})
    recipe = Recipe(**data)
    db.add(recipe)
    db.flush()
    for ing in body.ingredients:
        db.add(RecipeIngredient(recipe_id=recipe.id, **ing.model_dump()))
    for step in body.steps:
        db.add(RecipeStep(recipe_id=recipe.id, **step.model_dump()))
    db.commit()
    db.refresh(recipe)
    return recipe


@router.put("/{recipe_id}", response_model=RecipeResponse)
def update_recipe(recipe_id: int, body: RecipeUpdate, db: Session = Depends(get_db)):
    recipe = db.get(Recipe, recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    for field, value in body.model_dump(exclude_unset=True).items():
        setattr(recipe, field, value)
    db.commit()
    db.refresh(recipe)
    return recipe


@router.post("/{recipe_id}/image", response_model=RecipeResponse)
def upload_recipe_image(
    recipe_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    recipe = db.get(Recipe, recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")

    suffix = Path(file.filename or "image.jpg").suffix.lower() or ".jpg"
    filename = f"recipe_{recipe_id}_{uuid.uuid4().hex[:8]}{suffix}"
    dest = IMAGES_DIR / filename
    with dest.open("wb") as f:
        shutil.copyfileobj(file.file, f)

    recipe.image_url = f"/static/images/{filename}"
    db.commit()
    db.refresh(recipe)
    return recipe


@router.delete("/{recipe_id}", status_code=204)
def delete_recipe(recipe_id: int, db: Session = Depends(get_db)):
    recipe = db.get(Recipe, recipe_id)
    if not recipe:
        raise HTTPException(status_code=404, detail="Recipe not found")
    db.delete(recipe)
    db.commit()
