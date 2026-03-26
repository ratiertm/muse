"""FastAPI application entry point"""
import time
from contextlib import asynccontextmanager
from pathlib import Path
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from sqlalchemy import text

from app.config import settings
from app.api.v1 import router as api_v1_router
from app.core.exceptions import (
    AppException,
    app_exception_handler,
    generic_exception_handler,
)
from app.core.logging_config import setup_logging, get_logger
from app.db.database import engine
from app.discord_notify import notify_500_error

# Setup logging
setup_logging(log_level="INFO" if not settings.DEBUG else "DEBUG")
logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Lifecycle manager for app startup and shutdown"""
    logger.info("Starting Muse Backend", extra={"version": "0.1.0"})
    yield
    logger.info("Shutting down Muse Backend")


# Initialize FastAPI app
app = FastAPI(
    title="Muse API",
    description="Character chatbot backend with God Agent orchestration",
    version="0.1.0",
    debug=settings.DEBUG,
    lifespan=lifespan,
)

# Static files (avatars)
static_dir = Path(__file__).parent.parent / "static"
if static_dir.exists():
    app.mount("/static", StaticFiles(directory=str(static_dir)), name="static")

# Rate limiting
limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"])
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request logging middleware
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """Log all requests with timing"""
    start_time = time.time()
    
    # Process request
    response = await call_next(request)
    
    # Calculate duration
    duration = time.time() - start_time

    # Discord alert on 500 errors
    if response.status_code >= 500:
        notify_500_error(request.method, str(request.url.path), f"Status {response.status_code}")

    # Log request
    logger.info(
        "Request processed",
        extra={
            "method": request.method,
            "path": request.url.path,
            "status_code": response.status_code,
            "duration_ms": int(duration * 1000),
            "client": request.client.host if request.client else "unknown",
        },
    )
    
    return response


# Exception handlers
app.add_exception_handler(AppException, app_exception_handler)
app.add_exception_handler(Exception, generic_exception_handler)

# Include API routers
app.include_router(api_v1_router)


@app.get("/health")
async def health_check():
    """Enhanced health check with DB and service checks"""
    checks = {
        "database": "unknown",
        "openai": "ok" if settings.OPENAI_API_KEY else "missing",
        "anthropic": "ok" if settings.ANTHROPIC_API_KEY else "missing",
    }
    
    # Check database connection
    try:
        async with engine.connect() as conn:
            await conn.execute(text("SELECT 1"))
            checks["database"] = "ok"
    except Exception as e:
        checks["database"] = f"error: {str(e)}"
        logger.error("Database health check failed", exc_info=True)
    
    # Determine overall status
    overall_status = "ok" if checks["database"] == "ok" else "degraded"
    
    return {
        "status": overall_status,
        "service": "muse-backend",
        "version": "0.1.0",
        "checks": checks,
    }


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Welcome to Muse API",
        "version": "0.1.0",
        "docs": "/docs",
        "health": "/health",
    }
