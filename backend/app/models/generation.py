from pydantic import BaseModel
from typing import List, Optional

class StoryGenerationRequest(BaseModel):
    theme: str
    target_age: str  # "3-5", "6-8", "9-12" など
    pages_count: int = 5
    style: str = "watercolor"  # "watercolor", "cartoon", "realistic" など
    language: str = "japanese"
    user_id: str  # ユーザー識別ID

class SinglePageRequest(BaseModel):
    """最初のページ生成リクエスト（フロントエンドから渡される基本情報）"""
    story_title: str              # 絵本タイトル
    total_pages: int              # 総ページ数
    art_style: str               # 画風（"watercolor", "cartoon", "realistic" など）
    main_character_name: str     # 主人公の名前
    user_id: str                 # ユーザーID
    language: str = "japanese"   # 言語（デフォルト値）

class NextPageRequest(BaseModel):
    """次ページ生成リクエスト（ユーザーの意図を反映）"""
    story_id: str                # 継続中の絵本ID
    page_number: int            # 次のページ番号
    user_direction: str         # ユーザーが考えた展開（「うさぎが新しい友達に出会う」など）
    user_id: str               # ユーザーID

class StoryPage(BaseModel):
    page_number: int
    text: str
    image_prompt: str
    image_url: Optional[str] = None
    story_id: Optional[str] = None

class GeneratedStory(BaseModel):
    id: str
    title: str
    pages: List[StoryPage]
    theme: str
    target_age: str
    style: str
    user_id: str  # ユーザー識別ID

class ImageGenerationRequest(BaseModel):
    prompt: str
    style: str = "watercolor"
    size: str = "1024x1024"

class ImageGenerationResponse(BaseModel):
    image_url: str
    revised_prompt: str
