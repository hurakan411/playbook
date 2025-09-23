# Supabase連携 絵本生成アプリ Backend

## 追加機能
- Supabase PostgreSQL でデータ永続化
- Supabase Storage で画像保存
- 生成された画像の自動アップロード

## セットアップ

### 1. Supabaseプロジェクト作成
1. https://supabase.com でプロジェクト作成
2. SQL Editor で `backend/database/schema.sql` を実行
3. Settings > API から URL と Service Role キーを取得

### 2. 環境変数設定
```bash
# .env ファイルに追加
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-role-key-here
OPENAI_API_KEY=sk-your-openai-key
```

### 3. 依存関係とサーバー起動
```bash
cd backend
source ../.venv/bin/activate
pip install -e .
uvicorn app.main:app --reload --port 8000
```

## データベース構造

### stories テーブル
- id: UUID (Primary Key)
- title: TEXT
- theme: TEXT
- target_age: TEXT
- style: TEXT
- created_at/updated_at: TIMESTAMP

### pages テーブル
- id: UUID (Primary Key)
- story_id: UUID (Foreign Key)
- page_number: INTEGER
- text: TEXT
- image_prompt: TEXT
- image_url: TEXT
- image_storage_path: TEXT
- created_at: TIMESTAMP

### ストレージバケット
- story-images: 生成された画像ファイル保存

## API フロー
1. `POST /page/first` → OpenAI生成 → Supabase DB/Storage保存
2. `POST /page/next` → 文脈取得 → OpenAI生成 → Supabase保存
3. `GET /story/{story_id}` → Supabase から完全なストーリー取得

## 利点
- ✅ 永続化データ（サーバー再起動でも消えない）
- ✅ 画像の高速配信（CDN経由）
- ✅ スケーラブル（複数ユーザー対応）
- ✅ バックアップ（Supabaseが自動管理）
