import os
from openai import AsyncOpenAI
from typing import List
import json
import logging
from dotenv import load_dotenv
import uuid
import httpx
import tempfile
import base64

# .envファイルを読み込み（開発環境用）
load_dotenv()

from ..models.generation import (
    StoryGenerationRequest, GeneratedStory, StoryPage, 
    ImageGenerationRequest, ImageGenerationResponse,
    SinglePageRequest, NextPageRequest
)
from .supabase_service import SupabaseService

logger = logging.getLogger(__name__)

class OpenAIService:
    def __init__(self):
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY environment variable is required")
        self.client = AsyncOpenAI(api_key=api_key)
        self.supabase = SupabaseService()
        # Supabase Storage bucket name (override via env if needed)
        self.images_bucket = os.getenv("SUPABASE_IMAGES_BUCKET", "images")

    @staticmethod
    def _extract_json_object(raw: str):
        """文字列中から最初のJSONオブジェクトを抽出してdictにして返す（失敗時None）。"""
        if not raw:
            return None
        try:
            # まずはそのまま
            return json.loads(raw)
        except Exception:
            pass
        try:
            start = raw.find("{")
            end = raw.rfind("}")
            if start != -1 and end != -1 and end > start:
                return json.loads(raw[start:end+1])
        except Exception as e:
            logger.error(f"Fallback JSON extraction failed: {e}")
        return None

    async def generate_story_text(self, request: StoryGenerationRequest) -> List[StoryPage]:
        """テーマに基づいて絵本のテキストとイメージプロンプトを生成"""
        
        prompt = f"""
あなたは子供向け絵本作家です。以下の条件で絵本を作成してください：

テーマ: {request.theme}
対象年齢: {request.target_age}歳
ページ数: {request.pages_count}ページ
イラストスタイル: {request.style}

各ページについて以下を生成してください：
1. 子供に分かりやすいテキスト（{request.language}）
2. そのページのイラスト用英語プロンプト

出力は以下のJSON形式で：
{{
  "title": "絵本のタイトル",
  "pages": [
    {{
      "page_number": 1,
      "text": "ページのテキスト",
      "image_prompt": "Illustration prompt in English for {request.style} style"
    }}
  ]
}}

注意：
- テキストは4~5歳の子供に適した内容で
- テキストは必ずすべてひらがなで書いてください
- 1行は20文字程度にしてください
- 全部で4行までにしてください
- 文節ごとに半角スペースを入れてください
- イメージプロンプトは詳細で、{request.style}スタイルを含める
- 各ページは物語として繋がるように
"""

        try:
            logger.info(f"Sending request to OpenAI - Theme: {request.theme}, Pages: {request.pages_count}, Style: {request.style}")
            logger.info(f"Prompt length: {len(prompt)} characters")
            
            response = await self.client.chat.completions.create(
                model="gpt-5",
                messages=[
                    {"role": "system", "content": "あなたは経験豊富な子供向け絵本作家です。必ず有効なJSONフォーマットで回答してください。"},
                    {"role": "user", "content": prompt}
                ],
                # temperature=0.8,
                max_completion_tokens=4000,
                response_format={"type": "json_object"}
            )

            logger.info(f"Received response from OpenAI - Status: {response}")
            content = response.choices[0].message.content
            logger.info(f"OpenAI response: {content}")
            logger.info(f"Response content length: {len(content) if content else 0}")
            story_data = json.loads(content)
            
            pages = []
            for page_data in story_data["pages"]:
                pages.append(StoryPage(
                    page_number=page_data["page_number"],
                    text=page_data["text"],
                    image_prompt=page_data["image_prompt"]
                ))

            return story_data["title"], pages

        except Exception as e:
            logger.error(f"Error generating story text: {e}")
            raise

    async def generate_and_store_image(self, request: ImageGenerationRequest) -> str:
        """画像を生成し、公開URLを返す（必要ならSupabase保存まで内包）"""
        try:
            # generate_image がURL返却まで面倒を見る（b64時は保存してURL化）
            image_response = await self.generate_image(request)
            if not image_response or not image_response.image_url:
                raise ValueError("Image generation returned empty URL")
            return image_response.image_url
        except Exception as e:
            logger.error(f"Error generating and storing image: {e}")
            # 最低限のフォールバック画像
            return "https://via.placeholder.com/512x512.png?text=Image+Error"
            
    async def generate_and_store_story_image(self, prompt: str, style: str, user_id: str, story_id: str, page_number: int, previous_image_url: str = None) -> tuple[str, str]:
        """ストーリー用の画像を生成し、フォルダ構造で保存。前ページ画像があればプロンプトに含める"""
        try:
            # 画像生成リクエストを作成
            image_request = ImageGenerationRequest(prompt=prompt, style=style)
            # プロンプト強化
            enhanced_prompt = f"{prompt}, {style} style, children's book illustration, warm and friendly, high quality"
            if previous_image_url:
                enhanced_prompt += f"\nこの画像({previous_image_url})に登場する全てのキャラクターを必ず同じ姿・服装・色・雰囲気で描写してください。脇役や動物なども含め、できるだけ一貫性を保ってください。"
            response = await self.client.images.generate(
                model="gpt-image-1",
                prompt=enhanced_prompt,
                size="1024x1024",
                quality="medium",
                n=1
            )

            # レスポンス検証
            if not getattr(response, "data", None) or len(response.data) == 0:
                raise ValueError("OpenAI did not return image data")

            first = response.data[0]
            
            # 1) URL があればそのまま返す（ファイルパスは空文字）
            image_url = getattr(first, "url", None)
            if image_url:
                return "", image_url

            # 2) URLが無ければ b64_json を確認してSupabaseへフォルダ構造で保存
            b64_json = getattr(first, "b64_json", None)
            if b64_json:
                try:
                    image_bytes = base64.b64decode(b64_json)
                except Exception as be:
                    raise ValueError(f"Failed to decode base64 image: {be}")

                # フォルダ構造でアップロード
                file_path, public_url = await self.supabase.upload_story_image(
                    self.images_bucket, user_id, story_id, page_number, image_bytes
                )
                return file_path, public_url

            # 3) どちらも無い場合はエラー
            raise ValueError("OpenAI image response has neither url nor b64_json")
            
        except Exception as e:
            logger.error(f"Error generating and storing story image: {e}")
            # 最低限のフォールバック画像
            return "", "https://via.placeholder.com/512x512.png?text=Image+Error"

    async def generate_complete_story(self, request: StoryGenerationRequest) -> GeneratedStory:
        """テキストと画像の両方を生成して完全な絵本を作成"""
        
        try:
            # 1. ストーリーテキストを生成
            title, pages = await self.generate_story_text(request)
            
            # 2. 各ページの画像を生成
            for page in pages:
                image_request = ImageGenerationRequest(
                    prompt=page.image_prompt,
                    style=request.style
                )
                image_response = await self.generate_image(image_request)
                page.image_url = image_response.image_url

            # 3. ストーリーオブジェクトを作成
            story_id = f"story_{hash(title)}_{len(pages)}"
            
            return GeneratedStory(
                id=story_id,
                title=title,
                pages=pages,
                theme=request.theme,
                target_age=request.target_age,
                style=request.style
            )

        except Exception as e:
            logger.error(f"Error generating complete story: {e}")
            raise

    async def generate_single_page(self, request: SinglePageRequest, user_id: str = None, story_id: str = None) -> StoryPage:
        """最初のページを生成（絵本の基本情報から開始）"""
        
        prompt = f"""
あなたは子供向け絵本作家です。以下の情報で絵本の最初のページを作成してください：

絵本タイトル: {request.story_title}
総ページ数: {request.total_pages}ページ
画風: {request.art_style}
主人公の名前: {request.main_character_name}

このタイトルと主人公を使って、物語の導入となる最初のページを作成してください。

重要: 必ず以下の正確なJSON形式でのみ回答してください。マークダウンのコードブロック（```）は使用せず、説明文も一切含めないでください。純粋なJSONオブジェクトのみを返してください：

{{
  "page_number": 1,
  "text": "このページのテキスト（主人公の名前を使用）",
  "image_prompt": "Illustration prompt in English for {request.art_style} style"
}}

注意：
- 主人公の名前「{request.main_character_name}」を必ず使用
- 子供に適した内容で
- テキストは必ずすべてひらがなで書いてください
- 1行は20文字程度にしてください
- 全部で4行までにしてください
- 文節ごとに半角スペースを入れてください
- 残り{request.total_pages - 1}ページで展開できるような導入に
- イメージプロンプトは{request.art_style}スタイルを含める
- 回答は上記のJSONフォーマットのみ。一切の追加テキスト、説明、コードブロックは不要
"""

        try:
            # ユーザー入力情報をログ出力
            user_input = f"タイトル: {request.story_title}, 主人公: {request.main_character_name}, スタイル: {request.art_style}"
            logger.info(f"User input for first page: {user_input}")
            logger.info(f"Generated prompt: {prompt}")
            
            response = await self.client.chat.completions.create(
                model="gpt-5",
                messages=[
                    {"role": "system", "content": "あなたは経験豊富な子供向け絵本作家です。必ず有効なJSONフォーマットで回答してください。マークダウンのコードブロック（```json や ``` など）は一切使用せず、純粋なJSONオブジェクトのみを出力してください。"},
                    {"role": "user", "content": prompt}
                ],
                # temperature=0.8,
                max_completion_tokens=4000,
                response_format={"type": "json_object"}
            )

            # メタ情報ログ
            try:
                choice0 = response.choices[0]
                finish_reason = getattr(choice0, "finish_reason", None)
                model_used = getattr(response, "model", None)
                resp_id = getattr(response, "id", None)
                usage = getattr(response, "usage", None)
                logger.info(f"OpenAI meta(first): id={resp_id}, model={model_used}, finish_reason={finish_reason}, usage={usage}")
            except Exception:
                pass

            choice = response.choices[0]
            parsed = getattr(getattr(choice, "message", object()), "parsed", None)
            content = choice.message.content
            if parsed is not None:
                logger.info("OpenAI provided parsed JSON (first).")
                page_data = parsed
            else:
                logger.info(f"OpenAI response: {content}")
                if not content:
                    raise ValueError("OpenAI returned invalid JSON: ")
                # JSONパース or フォールバック
                page_data = self._extract_json_object(content)
                if page_data is None:
                    raise ValueError(f"OpenAI returned invalid JSON: {content}")
            
            # 画像生成：story_idとuser_idがある場合はフォルダ構造で保存
            if user_id and story_id:
                image_storage_path, image_url = await self.generate_and_store_story_image(
                    page_data["image_prompt"], 
                    request.art_style, 
                    user_id, 
                    story_id, 
                    1  # 最初のページ
                )
            else:
                # 従来の方法で画像生成
                image_request = ImageGenerationRequest(
                    prompt=page_data["image_prompt"],
                    style=request.art_style
                )
                image_url = await self.generate_and_store_image(image_request)
                image_storage_path = ""
            
            # プロンプトとレスポンスをDBに保存
            if user_id and story_id:
                try:
                    await self.supabase.save_page_with_prompt(
                        story_id=story_id,
                        page_number=1,
                        text=page_data["text"],
                        image_prompt=page_data["image_prompt"],
                        image_url=image_url,
                        user_prompt=user_input,
                        generated_response=page_data
                    )
                except Exception as db_error:
                    logger.error(f"Failed to save prompt data to DB: {db_error}")
            
            result_page = StoryPage(
                page_number=page_data["page_number"],
                text=page_data["text"],
                image_prompt=page_data["image_prompt"],
                image_url=image_url
            )
            
            # 返却するJSONをログ出力
            result_json = {
                "page_number": result_page.page_number,
                "text": result_page.text,
                "image_prompt": result_page.image_prompt,
                "image_url": result_page.image_url
            }
            logger.info(f"Returning JSON response: {json.dumps(result_json, ensure_ascii=False)}")
            
            return result_page

        except Exception as e:
            logger.error(f"Error generating single page: {e}")
            raise

    async def generate_next_page(self, request: NextPageRequest, story_context: List[str], previous_image_url: str = None, story: dict = None) -> StoryPage:
        """ユーザーの意図を反映して次のページを生成。前ページ画像URLがあればプロンプトに含める"""
        
        context = "これまでのストーリー:\n" + "\n".join([f"ページ{i+1}: {page}" for i, page in enumerate(story_context)])
        
        # ストーリーから画風を取得
        art_style = story.get("art_style", "watercolor") if story else "watercolor"
        
        prompt = f"""
絵本の続きを作成してください：

{context}

ページ番号: {request.page_number}
画風: {art_style}
ユーザーが考えた展開: {request.user_direction}

この展開を受けて、自然に続くページを作成してください。

重要: 必ず以下の正確なJSON形式でのみ回答してください。マークダウンのコードブロック（```）は使用せず、説明文も一切含めないでください。純粋なJSONオブジェクトのみを返してください：

{{
  "page_number": {request.page_number},
  "text": "このページのテキスト",
  "image_prompt": "Illustration prompt in English for {art_style} style"
}}

注意：
- ユーザーの意図を反映しつつ、子供に適した内容に
- テキストは必ずすべてひらがなで書いてください
- 1行は20文字程度にしてください
- 全部で4行までにしてください
- 文節ごとに半角スペースを入れてください
- イメージプロンプトは{art_style}スタイルを含める
- 前のページからの自然な流れを保つ
- 回答は上記のJSONフォーマットのみ。一切の追加テキスト、説明、コードブロックは不要
"""

        try:
            # ユーザー入力をログ出力
            user_input = f"ページ{request.page_number}: {request.user_direction}"
            logger.info(f"User input for next page: {user_input}")
            logger.info(f"Generated prompt: {prompt}")
            
            response = await self.client.chat.completions.create(
                model="gpt-5",
                messages=[
                    {"role": "system", "content": "あなたは経験豊富な子供向け絵本作家です。必ず有効なJSONフォーマットで回答してください。マークダウンのコードブロック（```json や ``` など）は一切使用せず、純粋なJSONオブジェクトのみを出力してください。"},
                    {"role": "user", "content": prompt}
                ],
                # temperature=0.8,
                max_completion_tokens=4000,
                response_format={"type": "json_object"}
            )

            # メタ情報ログ
            try:
                choice0 = response.choices[0]
                finish_reason = getattr(choice0, "finish_reason", None)
                model_used = getattr(response, "model", None)
                resp_id = getattr(response, "id", None)
                usage = getattr(response, "usage", None)
                logger.info(f"OpenAI meta(next): id={resp_id}, model={model_used}, finish_reason={finish_reason}, usage={usage}")
            except Exception:
                pass

            choice = response.choices[0]
            parsed = getattr(getattr(choice, "message", object()), "parsed", None)
            content = choice.message.content
            if parsed is not None:
                logger.info("OpenAI provided parsed JSON (next).")
                page_data = parsed
            else:
                logger.info(f"OpenAI response: {content}")
                if not content:
                    raise ValueError("OpenAI returned invalid JSON: ")
                page_data = self._extract_json_object(content)
                if page_data is None:
                    raise ValueError(f"OpenAI returned invalid JSON: {content}")
            
            # フォルダ構造で画像を生成・保存（前ページ画像URLを渡す）
            # ストーリーから画風を取得（デフォルトは水彩）
            style = story.get("art_style", "watercolor") if story else "watercolor"
            image_storage_path, image_url = await self.generate_and_store_story_image(
                page_data["image_prompt"],
                style,
                request.user_id,
                request.story_id,
                request.page_number,
                previous_image_url=previous_image_url
            )
            
            # プロンプトとレスポンスをDBに保存
            try:
                await self.supabase.save_page_with_prompt(
                    story_id=request.story_id,
                    page_number=request.page_number,
                    text=page_data["text"],
                    image_prompt=page_data["image_prompt"],
                    image_url=image_url,
                    user_prompt=user_input,
                    generated_response=page_data
                )
            except Exception as db_error:
                logger.error(f"Failed to save prompt data to DB: {db_error}")
            
            result_page = StoryPage(
                page_number=page_data["page_number"],
                text=page_data["text"],
                image_prompt=page_data["image_prompt"],
                image_url=image_url
            )
            
            # 返却するJSONをログ出力
            result_json = {
                "page_number": result_page.page_number,
                "text": result_page.text,
                "image_prompt": result_page.image_prompt,
                "image_url": result_page.image_url
            }
            logger.info(f"Returning JSON response: {json.dumps(result_json, ensure_ascii=False)}")
            
            return result_page

        except Exception as e:
            logger.error(f"Error generating next page: {e}")
            raise
