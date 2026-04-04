"""Chefs Quest FastAPI backend."""

from pathlib import Path
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from backend.routers import recipes, admin

app = FastAPI(title="Chefs Quest API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(recipes.router)
app.include_router(admin.router)

STATIC_DIR = Path(__file__).parent / "static"
STATIC_DIR.mkdir(exist_ok=True)
(STATIC_DIR / "images").mkdir(exist_ok=True)
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

ADMIN_DIR = Path(__file__).parent.parent / "admin"
app.mount("/admin", StaticFiles(directory=ADMIN_DIR, html=True), name="admin")


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}
