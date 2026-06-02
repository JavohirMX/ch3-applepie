from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.routers import users, chats, messages, forms

app = FastAPI(
    title="Conversa API",
    description="Backend for Conversa — AI communication companion for accessible travel",
    version="0.1.0",
)

# CORS — allow iOS app and local dev
allow_origins = settings.cors_origins
if settings.app_env == "development":
    allow_origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount routers
app.include_router(users.router)
app.include_router(chats.router)
app.include_router(messages.router)
app.include_router(forms.router)


@app.get("/health")
async def health():
    return {"status": "ok"}
