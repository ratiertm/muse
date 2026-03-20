#!/usr/bin/env python3
"""Seed test user for development"""
import asyncio
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from uuid import UUID
from sqlalchemy import select
from app.db.database import AsyncSessionLocal
from app.models.user import User

# Test user ID used in API endpoints
TEST_USER_ID = UUID("00000000-0000-0000-0000-000000000001")
TEST_USER_NAME = "test_user"
TEST_PIN_HASH = "$2b$12$dummy_hash_for_testing_only"


async def seed_test_user():
    """Create or update test user"""
    async with AsyncSessionLocal() as db:
        try:
            # Check if user exists
            result = await db.execute(
                select(User).where(User.id == TEST_USER_ID)
            )
            user = result.scalar_one_or_none()
            
            if user:
                print(f"Test user already exists: {user.name} (id={user.id})")
            else:
                # Create test user
                user = User(
                    id=TEST_USER_ID,
                    name=TEST_USER_NAME,
                    pin_hash=TEST_PIN_HASH,
                )
                db.add(user)
                await db.commit()
                print(f"Created test user: {user.name} (id={user.id})")
            
        except Exception as e:
            print(f"Error seeding test user: {e}")
            await db.rollback()
            raise


if __name__ == "__main__":
    asyncio.run(seed_test_user())
