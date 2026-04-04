"""Chefs Quest FastAPI backend."""

from fastapi import FastAPI

app = FastAPI(title="Chefs Quest API")


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}
