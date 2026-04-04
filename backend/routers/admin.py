"""Admin utility endpoints."""

import json
import os
import subprocess
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
import anthropic

router = APIRouter(prefix="/admin", tags=["admin"])

EXTRACT_PROMPT = """\
Given the following TikTok video description, extract recipe data.

Return ONLY a JSON object with this structure (no markdown, no explanation):
{{
  "title": "Recipe name",
  "ingredients": [
    {{"name": "ingredient name", "amount": "quantity", "unit": "unit"}}
  ],
  "steps": [
    {{"step_number": 1, "instruction": "step description"}}
  ]
}}

If a field cannot be determined, use null for amount/unit. Steps must be ordered.

Description:
{description}
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


def extract_recipe_from_description(description: str) -> dict:
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="ANTHROPIC_API_KEY not configured.")

    client = anthropic.Anthropic(api_key=api_key)
    message = client.messages.create(
        model="claude-haiku-4-5-20251001",
        max_tokens=1024,
        messages=[{"role": "user", "content": EXTRACT_PROMPT.format(description=description)}],
    )
    raw = message.content[0].text.strip()
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        raise HTTPException(status_code=500, detail="Claude returned invalid JSON.")


@router.post("/import-tiktok")
def import_tiktok(body: ImportRequest) -> dict:
    description = fetch_tiktok_description(body.url)
    return extract_recipe_from_description(description)
