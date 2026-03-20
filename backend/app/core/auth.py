"""Authentication utilities: PIN hashing, JWT tokens, and user dependency"""
from datetime import datetime, timedelta
from uuid import UUID
from typing import Optional

import jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status, Header
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.dependencies import get_db
from app.models.user import User

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


class AuthService:
    """Authentication service for PIN hashing and JWT tokens"""
    
    @staticmethod
    def hash_pin(pin: str) -> str:
        """Hash a PIN using bcrypt"""
        return pwd_context.hash(pin)
    
    @staticmethod
    def verify_pin(plain_pin: str, hashed_pin: str) -> bool:
        """Verify a PIN against its hash"""
        return pwd_context.verify(plain_pin, hashed_pin)
    
    @staticmethod
    def create_access_token(user_id: UUID, expires_delta: Optional[timedelta] = None) -> str:
        """
        Create a JWT access token
        
        Args:
            user_id: User UUID
            expires_delta: Token expiration time (default: from settings)
        
        Returns:
            JWT token string
        """
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(
                minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
            )
        
        to_encode = {
            "sub": str(user_id),
            "exp": expire,
            "iat": datetime.utcnow(),
        }
        
        encoded_jwt = jwt.encode(
            to_encode,
            settings.SECRET_KEY,
            algorithm=settings.ALGORITHM,
        )
        
        return encoded_jwt
    
    @staticmethod
    def decode_token(token: str) -> UUID:
        """
        Decode and validate JWT token
        
        Args:
            token: JWT token string
        
        Returns:
            User UUID from token
        
        Raises:
            HTTPException: If token is invalid or expired
        """
        credentials_exception = HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
        
        try:
            payload = jwt.decode(
                token,
                settings.SECRET_KEY,
                algorithms=[settings.ALGORITHM],
            )
            user_id_str: str = payload.get("sub")
            if user_id_str is None:
                raise credentials_exception
            
            user_id = UUID(user_id_str)
            return user_id
            
        except jwt.ExpiredSignatureError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token has expired",
                headers={"WWW-Authenticate": "Bearer"},
            )
        except (jwt.InvalidTokenError, ValueError):
            raise credentials_exception


async def get_current_user(
    authorization: Optional[str] = Header(None),
    x_user_id: Optional[str] = Header(None),  # Dev shortcut
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    Get current authenticated user from JWT token or dev header
    
    This dependency can be used in routes to require authentication.
    For development, you can pass X-User-Id header instead of token.
    
    Args:
        authorization: Authorization header with Bearer token
        x_user_id: X-User-Id header for dev (bypasses auth)
        db: Database session
    
    Returns:
        User model instance
    
    Raises:
        HTTPException: If authentication fails
    """
    # Dev shortcut: allow X-User-Id header to bypass authentication
    if x_user_id:
        try:
            user_id = UUID(x_user_id)
            result = await db.execute(
                select(User).where(User.id == user_id)
            )
            user = result.scalar_one_or_none()
            if user:
                return user
        except ValueError:
            pass
    
    # Production: require Bearer token
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing or invalid authorization header",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    token = authorization.split(" ")[1]
    user_id = AuthService.decode_token(token)
    
    # Get user from database
    result = await db.execute(
        select(User).where(User.id == user_id)
    )
    user = result.scalar_one_or_none()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    return user


async def get_current_user_optional(
    authorization: Optional[str] = Header(None),
    x_user_id: Optional[str] = Header(None),
    db: AsyncSession = Depends(get_db),
) -> Optional[User]:
    """
    Optional authentication - returns User if authenticated, None otherwise
    
    Useful for endpoints that work differently based on authentication status.
    """
    try:
        return await get_current_user(authorization, x_user_id, db)
    except HTTPException:
        return None
