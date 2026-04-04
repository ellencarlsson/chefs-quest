"""Chefs Quest FastAPI backend."""

from pathlib import Path
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from backend.routers import recipes, admin

app = FastAPI(title="Chefs Quest API")

app.include_router(recipes.router)
app.include_router(admin.router)

ADMIN_DIR = Path(__file__).parent.parent / "admin"
app.mount("/admin", StaticFiles(directory=ADMIN_DIR, html=True), name="admin")


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}
