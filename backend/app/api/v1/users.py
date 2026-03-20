"""User and authentication endpoints"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_db
from app.schemas.user import UserCreate, UserResponse, LoginRequest, TokenResponse
from app.core.auth import AuthService, get_current_user
from app.models.user import User

router = APIRouter()


@router.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    user_data: UserCreate,
    db: AsyncSession = Depends(get_db),
):
    """
    Create a new user account
    
    - **name**: Username (must be unique)
    - **pin**: PIN for authentication (will be hashed)
    - **avatar_url**: Optional avatar URL
    """
    # Check if username already exists
    result = await db.execute(
        select(User).where(User.name == user_data.name)
    )
    existing_user = result.scalar_one_or_none()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Username already exists",
        )
    
    # Hash PIN
    pin_hash = AuthService.hash_pin(user_data.pin)
    
    # Create user
    user = User(
        name=user_data.name,
        pin_hash=pin_hash,
        avatar_url=user_data.avatar_url,
    )
    
    db.add(user)
    await db.commit()
    
    # Re-query to get fresh data
    result = await db.execute(
        select(User).where(User.id == user.id)
    )
    return result.scalar_one()


@router.post("/auth/login", response_model=TokenResponse)
async def login(
    login_data: LoginRequest,
    db: AsyncSession = Depends(get_db),
):
    """
    Login with username and PIN
    
    Returns a JWT access token that should be used in Authorization header:
    `Authorization: Bearer <token>`
    
    - **name**: Username
    - **pin**: PIN
    """
    # Get user by name
    result = await db.execute(
        select(User).where(User.name == login_data.name)
    )
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or PIN",
        )
    
    # Verify PIN
    if not AuthService.verify_pin(login_data.pin, user.pin_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or PIN",
        )
    
    # Create access token
    access_token = AuthService.create_access_token(user.id)
    
    return TokenResponse(
        access_token=access_token,
        user=UserResponse.model_validate(user),
    )


@router.get("/auth/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_user),
):
    """
    Get current authenticated user information
    
    Requires authentication via Bearer token.
    """
    return current_user
