# 絵本生成アプリ Backend (FastAPI)

## セットアップ

1. Python 3.10+
2. 仮想環境を作成

```bash
python3 -m venv .venv
source .venv/bin/activate
```

3. 依存関係のインストール

```bash
pip install -U pip
pip install -e .
```

4. 開発サーバ起動

```bash
uvicorn app.main:app --reload --port 8000
```

5. 動作確認

- http://localhost:8000/api/health
- http://localhost:8000/docs
