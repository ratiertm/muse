# Charbot Backend

Character chatbot backend with FastAPI and LLM integration.

## Features

- FastAPI async REST API
- PostgreSQL with SQLAlchemy 2.0 async
- LLM integration via litellm
- SSE streaming for chat responses
- Character card system

## Setup

```bash
# Install dependencies
poetry install

# Start PostgreSQL
docker compose up -d

# Run migrations
poetry run alembic upgrade head

# Start server
poetry run uvicorn app.main:app --reload
```

## API Docs

Visit http://localhost:8000/docs for interactive API documentation.
