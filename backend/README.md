# 絵本生成アプリ Backend (FastAPI + OpenAI)

## 機能
- OpenAI GPT-4でストーリーテキスト生成
- DALL-E 3で絵本イラスト生成
- RESTful API エンドポイント

## セットアップ

### 1. 環境変数設定
```bash
export OPENAI_API_KEY="your-openai-api-key"
```

### 2. Python環境
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -e .
```

### 3. 開発サーバ起動
```bash
uvicorn app.main:app --reload --port 8000
```

## API エンドポイント

### ヘルスチェック
- `GET /api/health` - サーバー状態確認
- `GET /api/v1/generate/health` - OpenAI接続確認

### ストーリー生成
- `POST /api/v1/generate/story` - 完全な絵本生成（テキスト+画像）
- `POST /api/v1/generate/story/text-only` - テキストのみ生成
- `POST /api/v1/generate/image` - 単一画像生成

### リクエスト例
```json
{
  "theme": "森の動物たちの冒険",
  "target_age": "5-7",
  "pages_count": 5,
  "style": "watercolor",
  "language": "japanese"
}
```

## 確認URL
- http://localhost:8000/docs - Swagger UI
- http://localhost:8000/api/health
