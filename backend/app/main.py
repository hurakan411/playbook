from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .api.v1.stories import router as stories_router

app = FastAPI(title="Ehon Backend", version="0.1.0")

# CORS (adjust origins as needed)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/api/health")
def health():
    return {"status": "ok"}


app.include_router(stories_router, prefix="/api/v1")
