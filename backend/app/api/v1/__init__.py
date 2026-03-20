"""API v1 routers"""
from fastapi import APIRouter
from app.api.v1 import characters, chat, conversations, scenarios, users, group_chat

router = APIRouter(prefix="/api/v1")
router.include_router(users.router, tags=["users"])
router.include_router(characters.router, prefix="/characters", tags=["characters"])
router.include_router(scenarios.router, prefix="/scenarios", tags=["scenarios"])
router.include_router(conversations.router, prefix="/conversations", tags=["conversations"])
router.include_router(chat.router, prefix="/chat", tags=["chat"])
router.include_router(group_chat.router, prefix="/group-chat", tags=["group-chat"])

__all__ = ["router"]
