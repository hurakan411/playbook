import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# from .api.v1.stories import router as stories_router  # 削除
# from .api.v1.generation import router as generation_router
from app.api.v1.generation import router as generation_router

import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s",
)

app = FastAPI(title="Ehon Backend", version="0.1.0")

# CORS
# When allow_credentials=True, we must not use wildcard origins. Configure via env.
# CORS_ALLOW_ORIGINS can be a comma-separated list, e.g. "http://localhost:5173,http://127.0.0.1:3000"
env_origins = os.getenv("CORS_ALLOW_ORIGINS", "").strip()
allow_origins = [o.strip() for o in env_origins.split(",") if o.strip()]

# Allow localhost/127.0.0.1 with any port by regex (useful for dev)
allow_origin_regex = os.getenv(
    "CORS_ALLOW_ORIGIN_REGEX",
    r"https?://(localhost|127\.0\.0\.1)(:\\d+)?$",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,  # empty list is okay when regex is provided
    allow_origin_regex=allow_origin_regex,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/health")
def health():
    return {"status": "ok"}


# app.include_router(stories_router, prefix="/api/v1")  # 削除
app.include_router(generation_router, prefix="/api/v1")
