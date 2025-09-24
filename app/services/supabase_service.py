import os
from supabase import create_client, Client
from typing import Optional
import logging

logger = logging.getLogger(__name__)

class SupabaseService:
    async def get_page_by_story_and_number(self, story_id: str, page_number: int) -> Optional[dict]:
        """指定したストーリーIDとページ番号のページ情報を取得"""
        try:
            result = self.client.table("pages").select("*").eq("story_id", story_id).eq("page_number", page_number).execute()
            return result.data[0] if result.data else None
        except Exception as e:
            logger.error(f"Error getting page by story and number: {e}")
            raise
    def __init__(self):
        url = os.getenv("SUPABASE_URL")
        key = os.getenv("SUPABASE_SERVICE_KEY")  # Service roleキー（サーバー用）
        
        if not url or not key:
            raise ValueError("SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables are required")
        
        self.client: Client = create_client(url, key)
        
    async def create_story(self, story_data: dict) -> dict:
        """新しいストーリーをデータベースに作成"""
        try:
            result = self.client.table("stories").insert(story_data).execute()
            return result.data[0]
        except Exception as e:
            logger.error(f"Error creating story: {e}")
            raise
            
    async def get_story(self, story_id: str) -> Optional[dict]:
        """ストーリーを取得"""
        try:
            result = self.client.table("stories").select("*").eq("id", story_id).execute()
            return result.data[0] if result.data else None
        except Exception as e:
            logger.error(f"Error getting story: {e}")
            raise
            
    async def update_story(self, story_id: str, update_data: dict) -> dict:
        """ストーリーを更新"""
        try:
            result = self.client.table("stories").update(update_data).eq("id", story_id).execute()
            return result.data[0]
        except Exception as e:
            logger.error(f"Error updating story: {e}")
            raise
            
    async def add_page(self, page_data: dict) -> dict:
        """新しいページをデータベースに追加"""
        try:
            result = self.client.table("pages").insert(page_data).execute()
            return result.data[0]
        except Exception as e:
            logger.error(f"Error adding page: {e}")
            raise
            
    async def create_page(self, page_data: dict) -> dict:
        """新しいページを作成（add_pageのエイリアス）"""
        return await self.add_page(page_data)
            
    async def get_story_pages(self, story_id: str) -> list:
        """ストーリーのページ一覧を取得"""
        try:
            result = self.client.table("pages").select("*").eq("story_id", story_id).order("page_number").execute()
            return result.data
        except Exception as e:
            logger.error(f"Error getting story pages: {e}")
            raise
            
    async def get_pages_by_story_id(self, story_id: str) -> list:
        """ストーリーIDでページ一覧を取得（get_story_pagesのエイリアス）"""
        return await self.get_story_pages(story_id)
            
    async def upload_image(self, bucket: str, file_path: str, file_data: bytes) -> str:
        """Supabase Storageに画像をアップロード"""
        try:
            result = self.client.storage.from_(bucket).upload(file_path, file_data)
            # パブリックURLを生成
            public_url = self.client.storage.from_(bucket).get_public_url(file_path)
            return public_url
        except Exception as e:
            logger.error(f"Error uploading image: {e}")
            raise
            
    async def upload_story_image(self, bucket: str, user_id: str, story_id: str, page_number: int, file_data: bytes, file_extension: str = "png") -> tuple[str, str]:
        """ストーリー用の画像をユーザーID配下に保存"""
        try:
            # フォルダ構造: users/{user_id}/{story_id}/page_{page_number}.{extension}
            file_path = f"users/{user_id}/{story_id}/page_{page_number}.{file_extension}"
            
            result = self.client.storage.from_(bucket).upload(file_path, file_data)
            
            # パブリックURLを生成
            public_url = self.client.storage.from_(bucket).get_public_url(file_path)
            
            # ファイルパスとURLの両方を返す
            return file_path, public_url
        except Exception as e:
            logger.error(f"Error uploading story image: {e}")
            raise
            
    async def save_page_with_prompt(
        self,
        story_id: str,
        page_number: int,
        text: str,
        image_prompt: str,
        image_url: str,
        user_prompt: str = None,
        generated_response: dict = None
    ) -> dict:
        """ページ情報をユーザープロンプトと生成レスポンスと共に保存"""
        try:
            page_data = {
                "story_id": story_id,
                "page_number": page_number,
                "text": text,
                "image_prompt": image_prompt,
                "image_url": image_url,
                "user_prompt": user_prompt,
                "generated_response": generated_response
            }
            
            # ログ出力
            logger.info(f"Saving page {page_number} for story {story_id}")
            logger.info(f"User prompt: {user_prompt}")
            logger.info(f"Generated response: {generated_response}")
            
            result = self.client.table("pages").insert(page_data).execute()
            
            if result.data:
                logger.info(f"Successfully saved page {page_number} with prompt data")
                return result.data[0]
            else:
                logger.error(f"Failed to save page {page_number}")
                return None
                
        except Exception as e:
            logger.error(f"Error saving page with prompt: {e}")
            raise

    async def update_page_with_prompt(
        self,
        story_id: str,
        page_number: int,
        text: str = None,
        image_prompt: str = None,
        image_url: str = None,
        user_prompt: str = None,
        generated_response: dict = None
    ) -> dict:
        """既存ページ情報をユーザープロンプトと生成レスポンスと共に更新"""
        try:
            update_data = {}
            if text is not None:
                update_data["text"] = text
            if image_prompt is not None:
                update_data["image_prompt"] = image_prompt
            if image_url is not None:
                update_data["image_url"] = image_url
            if user_prompt is not None:
                update_data["user_prompt"] = user_prompt
            if generated_response is not None:
                update_data["generated_response"] = generated_response
            
            # ログ出力
            logger.info(f"Updating page {page_number} for story {story_id}")
            logger.info(f"User prompt: {user_prompt}")
            logger.info(f"Generated response: {generated_response}")
            
            result = self.client.table("pages").update(update_data).eq("story_id", story_id).eq("page_number", page_number).execute()
            
            if result.data:
                logger.info(f"Successfully updated page {page_number} with prompt data")
                return result.data[0]
            else:
                logger.error(f"Failed to update page {page_number}")
                return None
                
        except Exception as e:
            logger.error(f"Error updating page with prompt: {e}")
            raise
