from fastapi import APIRouter, HTTPException
from typing import List
import uuid

from ...models.generation import (
    SinglePageRequest, NextPageRequest, StoryPage
)
from ...services.openai_service import OpenAIService
from ...services.supabase_service import SupabaseService

router = APIRouter(prefix="/generate", tags=["generation"])

# サービスのインスタンス
openai_service = OpenAIService()
supabase_service = SupabaseService()

@router.post("/page/first", response_model=StoryPage)
async def generate_first_page(request: SinglePageRequest):
    """最初のページを生成"""
    try:
        # UUIDを明示的に生成
        story_uuid = str(uuid.uuid4())
        
        # Supabaseに新しいストーリーを作成
        story_data = {
            "id": story_uuid,  # UUIDを明示的に指定
            "title": request.story_title,
            "total_pages": request.total_pages,
            "art_style": request.art_style,
            "main_character_name": request.main_character_name,
            "user_id": request.user_id,
            "current_page": 1,
            "is_complete": False
        }
        
        story = await supabase_service.create_story(story_data)
        story_id = story["id"]
        
        # user_idとstory_idを渡して最初のページを生成
        page = await openai_service.generate_single_page(request, request.user_id, story_id)
        
        # ページ保存はopenai_service.generate_single_page内で実行されるため、ここでは不要
        # 重複を避けるためコメントアウト
        # page_data = {
        #     "story_id": story_id,
        #     "page_number": 1,
        #     "text": page.text,
        #     "image_prompt": page.image_prompt,
        #     "image_url": page.image_url,
        #     "image_storage_path": f"users/{request.user_id}/{story_id}/page_1.png"
        # }
        # await supabase_service.create_page(page_data)
        
        # StoryPageモデルにstory_idをセットして返す
        page.story_id = story_id
        return page
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"First page generation failed: {str(e)}")

@router.post("/page/next", response_model=StoryPage)
async def generate_next_page(request: NextPageRequest):
    """ユーザーの意図を反映して次のページを生成"""
    try:
        # ストーリーが存在するかチェック
        story = await supabase_service.get_story(request.story_id)
        if not story:
            raise HTTPException(status_code=404, detail="Story not found")
        
        # ストーリーの文脈を取得（既存のページ）
        pages = await supabase_service.get_pages_by_story_id(request.story_id)
        story_context = [page["text"] for page in pages]
        
        # 前ページ画像URLを取得（1ページ目以外）
        previous_image_url = None
        if request.page_number > 1:
            prev_page = await supabase_service.get_page_by_story_and_number(request.story_id, request.page_number - 1)
            if prev_page:
                previous_image_url = prev_page.get("image_url")
        # 次のページを生成（前ページ画像URLとストーリー情報を渡す）
        page = await openai_service.generate_next_page(request, story_context, previous_image_url, story)
        
        # ページ保存はopenai_service.generate_next_page内で実行されるため、ここでは不要
        # 重複を避けるためコメントアウト
        # page_data = {
        #     "story_id": request.story_id,
        #     "page_number": request.page_number,
        #     "text": page.text,
        #     "image_prompt": page.image_prompt,
        #     "image_url": page.image_url,
        #     "image_storage_path": f"users/{request.user_id}/stories/{request.story_id}/pages/page_{request.page_number}.png"
        # }
        # await supabase_service.create_page(page_data)
        
        # ストーリーの現在ページ数を更新
        await supabase_service.update_story(request.story_id, {"current_page": request.page_number})
        
        return page
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Next page generation failed: {str(e)}")

@router.get("/story/{story_id}")
async def get_story_progress(story_id: str):
    """ストーリーの進行状況を取得"""
    story = await supabase_service.get_story(story_id)
    if not story:
        raise HTTPException(status_code=404, detail="Story not found")
    
    pages = await supabase_service.get_pages_by_story_id(story_id)
    
    return {
        "story_id": story_id,
        "title": story["title"],
        "total_pages": story["total_pages"],
        "current_page": story["current_page"],
        "art_style": story["art_style"],
        "main_character_name": story["main_character_name"],
        "is_complete": story["is_complete"],
        "pages_count": len(pages),
        "pages": pages
    }

@router.get("/health")
async def generation_health():
    """生成サービスのヘルスチェック"""
    try:
        # OpenAI APIキーの存在確認
        import os
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise HTTPException(status_code=500, detail="OpenAI API key not configured")
        
        return {
            "status": "healthy",
            "openai_configured": bool(api_key),
            "services": ["text_generation", "image_generation"]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Health check failed: {str(e)}")
