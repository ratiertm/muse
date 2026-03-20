"""FastAPI application entry point"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings

app = FastAPI(
    title="Charbot API",
    description="Character chatbot backend with LLM integration",
    version="0.1.0",
    debug=settings.DEBUG,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "ok", "service": "charbot-backend"}


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Welcome to Charbot API",
        "docs": "/docs",
        "health": "/health",
    }
