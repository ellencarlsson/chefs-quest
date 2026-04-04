"""Admin utility endpoints."""

import re
import subprocess
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/admin", tags=["admin"])

INGREDIENT_HEADER = re.compile(r'(?i)^(ingredients?|ingr[eé]dienser?|vad du beh[öo]ver):?\s*$')
STEP_HEADER = re.compile(r'(?i)^(steps?|instructions?|directions?|how to|method|g[öo]r s[åa] h[äe]r|tillvägag[åa]ngss[äe]tt|s[åa] g[öo]r du):?\s*$')
STEP_LINE = re.compile(r'^(\d+)[.)]\s*(.+)')
AMOUNT_UNIT = re.compile(
    r'^([\d½¼¾⅓⅔\s/.,]+)\s*(g|kg|ml|l|dl|cl|tbsp|tsp|msk|tsk|cups?|oz|lb|st|stycken|pieces?|handfull?)\.?\s+(.+)',
    re.IGNORECASE,
)
AMOUNT_ONLY = re.compile(r'^([\d½¼¾⅓⅔\s/.,]+)\s+(.+)')


def parse_ingredient(line: str) -> dict | None:
    line = line.lstrip('-•*').strip()
    if not line:
        return None
    m = AMOUNT_UNIT.match(line)
    if m:
        return {"name": m.group(3).strip(), "amount": m.group(1).strip(), "unit": m.group(2).strip()}
    m = AMOUNT_ONLY.match(line)
    if m:
        return {"name": m.group(2).strip(), "amount": m.group(1).strip(), "unit": None}
    return {"name": line, "amount": None, "unit": None}


def parse_recipe(description: str) -> dict:
    lines = [l.strip() for l in description.splitlines() if l.strip()]
    if not lines:
        return {"title": "", "ingredients": [], "steps": []}

    title = lines[0]
    ingredients: list[dict] = []
    steps: list[dict] = []
    mode = None

    for line in lines[1:]:
        if INGREDIENT_HEADER.match(line):
            mode = "ingredients"
            continue
        if STEP_HEADER.match(line):
            mode = "steps"
            continue

        if mode == "ingredients":
            ing = parse_ingredient(line)
            if ing:
                ingredients.append(ing)
        elif mode == "steps":
            m = STEP_LINE.match(line)
            if m:
                steps.append({"step_number": int(m.group(1)), "instruction": m.group(2).strip()})
            else:
                steps.append({"step_number": len(steps) + 1, "instruction": line})
        else:
            # No header found yet — detect numbered steps inline
            m = STEP_LINE.match(line)
            if m:
                mode = "steps"
                steps.append({"step_number": int(m.group(1)), "instruction": m.group(2).strip()})

    return {"title": title, "ingredients": ingredients, "steps": steps}


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


@router.post("/import-tiktok")
def import_tiktok(body: ImportRequest) -> dict:
    description = fetch_tiktok_description(body.url)
    return parse_recipe(description)
