"""Chefs Quest FastAPI backend."""

from fastapi import FastAPI
from backend.routers import recipes

app = FastAPI(title="Chefs Quest API")

app.include_router(recipes.router)


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}
