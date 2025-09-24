#!/usr/bin/env python3
"""
絵本生成API の動作検証スクリプト
"""

import requests
import json
import sys
import time

# API設定
BASE_URL = "http://localhost:8000"
API_PREFIX = "/generate"

def test_health_check():
    """ヘルスチェック"""
    print("🔍 ヘルスチェックを実行中...")
    try:
        response = requests.get(f"{BASE_URL}{API_PREFIX}/health")
        if response.status_code == 200:
            print("✅ ヘルスチェック成功")
            print(f"   レスポンス: {response.json()}")
            return True
        else:
            print(f"❌ ヘルスチェック失敗: {response.status_code}")
            print(f"   エラー: {response.text}")
            return False
    except Exception as e:
        print(f"❌ ヘルスチェックエラー: {e}")
        return False

def test_create_first_page():
    """最初のページ生成テスト"""
    print("\n📖 最初のページ生成テスト...")
    
    # サンプルリクエスト
    request_data = {
        "story_title": "くまさんの大冒険",
        "total_pages": 8,
        "art_style": "水彩画風",
        "main_character_name": "くまのポン太",
        "target_age": 5,
        "user_id": "test_user_123"
    }
    
    try:
        print(f"📝 リクエストデータ: {json.dumps(request_data, ensure_ascii=False, indent=2)}")
        response = requests.post(f"{BASE_URL}{API_PREFIX}/page/first", json=request_data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ 最初のページ生成成功")
            print(f"   ストーリーID: {result.get('story_id')}")
            print(f"   テキスト: {result.get('text', '')[:100]}...")
            print(f"   画像URL: {result.get('image_url', 'なし')}")
            return result.get('story_id')
        else:
            print(f"❌ 最初のページ生成失敗: {response.status_code}")
            print(f"   エラー: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ 最初のページ生成エラー: {e}")
        return None

def test_create_next_page(story_id: str):
    """次のページ生成テスト"""
    print(f"\n📖 次のページ生成テスト (ストーリーID: {story_id})...")
    
    request_data = {
        "story_id": story_id,
        "page_number": 2,
        "user_direction": "くまのポン太が森で友達を見つける場面にしてください",
        "user_id": "test_user_123"
    }
    
    try:
        print(f"📝 リクエストデータ: {json.dumps(request_data, ensure_ascii=False, indent=2)}")
        response = requests.post(f"{BASE_URL}{API_PREFIX}/page/next", json=request_data)
        
        if response.status_code == 200:
            result = response.json()
            print("✅ 次のページ生成成功")
            print(f"   テキスト: {result.get('text', '')[:100]}...")
            print(f"   画像URL: {result.get('image_url', 'なし')}")
            return True
        else:
            print(f"❌ 次のページ生成失敗: {response.status_code}")
            print(f"   エラー: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ 次のページ生成エラー: {e}")
        return False

def test_get_story_progress(story_id: str):
    """ストーリー進行状況確認テスト"""
    print(f"\n📊 ストーリー進行状況確認 (ストーリーID: {story_id})...")
    
    try:
        response = requests.get(f"{BASE_URL}{API_PREFIX}/story/{story_id}")
        
        if response.status_code == 200:
            result = response.json()
            print("✅ ストーリー進行状況取得成功")
            print(f"   タイトル: {result.get('title')}")
            print(f"   総ページ数: {result.get('total_pages')}")
            print(f"   現在のページ: {result.get('current_page')}")
            print(f"   作成済みページ数: {result.get('pages_count')}")
            print(f"   完了状態: {result.get('is_complete')}")
            return True
        else:
            print(f"❌ ストーリー進行状況取得失敗: {response.status_code}")
            print(f"   エラー: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ ストーリー進行状況取得エラー: {e}")
        return False

def main():
    """メイン実行関数"""
    print("🚀 絵本生成API動作検証開始")
    print("=" * 50)
    
    # 1. ヘルスチェック
    if not test_health_check():
        print("\n❌ APIサーバーが利用できません。サーバーを起動してから再実行してください。")
        sys.exit(1)
    
    # 2. 最初のページ生成
    story_id = test_create_first_page()
    if not story_id:
        print("\n❌ 最初のページ生成に失敗しました。")
        sys.exit(1)
    
    # 3. ストーリー進行状況確認
    test_get_story_progress(story_id)
    
    # 4. 次のページ生成
    test_create_next_page(story_id)
    
    # 5. 最終的なストーリー進行状況確認
    test_get_story_progress(story_id)
    
    print("\n" + "=" * 50)
    print("🎉 全ての動作検証が完了しました！")

if __name__ == "__main__":
    main()
