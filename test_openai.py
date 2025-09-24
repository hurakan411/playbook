#!/usr/bin/env python3
"""
OpenAI APIの動作テスト
"""
import asyncio
import os
from openai import AsyncOpenAI
from dotenv import load_dotenv

load_dotenv()

async def test_openai():
    try:
        api_key = os.getenv("OPENAI_API_KEY")
        print(f"API Key found: {api_key[:10]}..." if api_key else "No API key found")
        
        client = AsyncOpenAI(api_key=api_key)
        
        # 簡単なテストプロンプト
        test_prompt = """
テストプロンプトです。以下のJSON形式で回答してください：
{
  "message": "テスト成功",
  "status": "ok"
}
"""
        
        print("OpenAI APIにリクエスト送信中...")
        response = await client.chat.completions.create(
            model="gpt-5",
            messages=[
                {"role": "system", "content": "あなたは有効なJSONフォーマットで回答するアシスタントです。"},
                {"role": "user", "content": test_prompt}
            ],
            max_completion_tokens=500,
            response_format={"type": "json_object"}
        )
        
        print(f"Response object: {response}")
        print(f"Choices length: {len(response.choices)}")
        
        if response.choices:
            content = response.choices[0].message.content
            print(f"Content: '{content}'")
            print(f"Content length: {len(content) if content else 0}")
            print(f"Content type: {type(content)}")
        else:
            print("No choices in response")
            
    except Exception as e:
        print(f"エラーが発生しました: {e}")
        print(f"エラーの型: {type(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(test_openai())
