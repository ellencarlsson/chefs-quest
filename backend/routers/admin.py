"""Admin utility endpoints."""

import json
import os
import subprocess
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from groq import Groq

router = APIRouter(prefix="/admin", tags=["admin"])

EXTRACT_PROMPT = """\
Given the following TikTok video description, extract recipe data.

Return ONLY a JSON object with this exact structure (no markdown, no explanation):
{
  "title": "Recipe name",
  "ingredients": [
    {"name": "ingredient name", "amount": "quantity or null", "unit": "unit or null"}
  ],
  "steps": [
    {"step_number": 1, "instruction": "step description"}
  ]
}

Rules:
- Use null (not empty string) when amount or unit is unknown
- Steps must be in order
- If multiple sub-recipes exist, combine all ingredients and steps into one list

Description:
"""


class ImportRequest(BaseModel):
    url: str


def fetch_tiktok_description(url: str) -> str:
    result = subprocess.run(
        ["yt-dlp", "--skip-download", "--print", "description", url],
        capture_output=True,
        text=True,
        timeout=30,
    )
    if result.returncode != 0:
        raise HTTPException(status_code=422, detail=f"Could not fetch TikTok video: {result.stderr.strip()}")
    description = result.stdout.strip()
    if not description:
        raise HTTPException(status_code=422, detail="Video has no description to extract recipe from.")
    return description


def extract_recipe_with_groq(description: str) -> dict:
    api_key = os.environ.get("GROQ_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GROQ_API_KEY not configured.")

    client = Groq(api_key=api_key)
    response = client.chat.completions.create(
        model="llama-3.1-8b-instant",
        messages=[{"role": "user", "content": EXTRACT_PROMPT + description}],
        temperature=0,
        max_tokens=1024,
    )
    raw = response.choices[0].message.content.strip()
    # Strip markdown code fences if model wraps response
    raw = raw.removeprefix("```json").removeprefix("```").removesuffix("```").strip()
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail="Could not parse recipe from description.")


@router.post("/import-tiktok")
def import_tiktok(body: ImportRequest) -> dict:
    description = fetch_tiktok_description(body.url)
    return extract_recipe_with_groq(description)
