#!/usr/bin/env python3
"""
Supabase接続テスト
"""
import os
import sys
from dotenv import load_dotenv

# .envファイルを読み込み
load_dotenv()

def test_supabase_connection():
    """Supabase接続をテストする"""
    
    # 環境変数の確認
    url = os.getenv('SUPABASE_URL')
    key = os.getenv('SUPABASE_SERVICE_KEY')
    
    print("=== Supabase接続テスト ===")
    print(f"SUPABASE_URL: {url[:30]}..." if url else "SUPABASE_URL not found")
    print(f"SERVICE_KEY: {'設定済み' if key else '未設定'}")
    
    if not url or not key:
        print("❌ 必要な環境変数が設定されていません")
        return False
    
    try:
        import requests
    except ImportError:
        print("❌ requestsライブラリがインストールされていません")
        print("pip install requests を実行してください")
        return False
    
    # REST API接続テスト
    try:
        print("\n--- REST API テスト ---")
        response = requests.get(
            f'{url}/rest/v1/',
            headers={
                'apikey': key,
                'Authorization': f'Bearer {key}'
            },
            timeout=10
        )
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            print("✅ REST API接続成功")
        else:
            print(f"❌ REST API接続エラー: {response.text[:100]}")
            return False
    except Exception as e:
        print(f"❌ REST API接続失敗: {str(e)}")
        return False
    
    # Storage API接続テスト
    try:
        print("\n--- Storage API テスト ---")
        response = requests.get(
            f'{url}/storage/v1/bucket',
            headers={
                'apikey': key,
                'Authorization': f'Bearer {key}'
            },
            timeout=10
        )
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            print("✅ Storage API接続成功")
            try:
                buckets = response.json()
                bucket_names = [b.get("name") for b in buckets if isinstance(b, dict) and "name" in b]
                print(f"利用可能なバケット: {bucket_names}")
                
                # 推奨バケット名の確認
                recommended_buckets = ['images', 'story-images']
                found_bucket = None
                for bucket in recommended_buckets:
                    if bucket in bucket_names:
                        found_bucket = bucket
                        break
                
                if found_bucket:
                    print(f"✅ 画像保存用バケット '{found_bucket}' が見つかりました")
                    print(f"環境変数に SUPABASE_IMAGES_BUCKET={found_bucket} を設定してください")
                else:
                    print("⚠️ 画像保存用バケットが見つかりません")
                    print("Supabaseダッシュボードで 'images' または 'story-images' バケットを作成してください")
                    
            except Exception as json_error:
                print(f"バケット情報の解析エラー: {json_error}")
        else:
            print(f"❌ Storage API接続エラー: {response.text[:100]}")
            return False
    except Exception as e:
        print(f"❌ Storage API接続失敗: {str(e)}")
        return False
    
    print("\n✅ Supabase接続テスト完了")
    return True

if __name__ == "__main__":
    success = test_supabase_connection()
    if success:
        print("\n🎉 接続テスト成功！バックエンドを起動できます")
    else:
        print("\n💥 接続テスト失敗。設定を確認してください")
    sys.exit(0 if success else 1)
