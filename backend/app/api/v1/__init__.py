"""API v1 routers"""
from fastapi import APIRouter
from app.api.v1 import characters, chat

router = APIRouter(prefix="/api/v1")
router.include_router(characters.router, prefix="/characters", tags=["characters"])
router.include_router(chat.router, prefix="/chat", tags=["chat"])

__all__ = ["router"]
