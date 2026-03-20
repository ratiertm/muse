"""FastAPI dependencies for dependency injection"""
from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db

# Re-export for convenience
__all__ = ["get_db"]
