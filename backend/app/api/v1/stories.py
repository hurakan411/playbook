from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List

router = APIRouter(prefix="/stories", tags=["stories"])

class Story(BaseModel):
    id: str
    title: str
    pages: List[str]  # simple representation for now

# naive in-memory store
DB: dict[str, Story] = {}

@router.get("/", response_model=List[Story])
def list_stories():
    return list(DB.values())

@router.post("/", response_model=Story)
def create_story(story: Story):
    if story.id in DB:
        raise HTTPException(status_code=400, detail="Story already exists")
    DB[story.id] = story
    return story

@router.get("/{story_id}", response_model=Story)
def get_story(story_id: str):
    if story_id not in DB:
        raise HTTPException(status_code=404, detail="Not found")
    return DB[story_id]

@router.delete("/{story_id}")
def delete_story(story_id: str):
    if story_id not in DB:
        raise HTTPException(status_code=404, detail="Not found")
    del DB[story_id]
    return {"ok": True}
