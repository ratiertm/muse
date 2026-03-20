#!/bin/bash
set -e

echo "🚀 Muse Backend Deployment Script"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo -e "${RED}Error: .env.production not found!${NC}"
    echo "Please create .env.production from .env.production.example"
    exit 1
fi

echo -e "${YELLOW}Step 1: Pulling latest code...${NC}"
git pull origin main || {
    echo -e "${RED}Warning: Could not pull latest code. Continuing with local version.${NC}"
}

echo -e "${YELLOW}Step 2: Loading environment variables...${NC}"
export $(cat .env.production | grep -v '^#' | xargs)

echo -e "${YELLOW}Step 3: Building Docker images...${NC}"
docker-compose -f docker-compose.prod.yml build --no-cache

echo -e "${YELLOW}Step 4: Stopping existing services...${NC}"
docker-compose -f docker-compose.prod.yml down

echo -e "${YELLOW}Step 5: Starting database...${NC}"
docker-compose -f docker-compose.prod.yml up -d postgres

# Wait for postgres to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 10

echo -e "${YELLOW}Step 6: Running database migrations...${NC}"
docker-compose -f docker-compose.prod.yml run --rm backend alembic upgrade head

echo -e "${YELLOW}Step 7: Starting all services...${NC}"
docker-compose -f docker-compose.prod.yml up -d

echo -e "${YELLOW}Step 8: Waiting for services to start...${NC}"
sleep 5

echo -e "${YELLOW}Step 9: Health check...${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/health)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Deployment successful!${NC}"
    echo -e "${GREEN}✓ Backend is running at http://localhost${NC}"
    
    echo ""
    echo "Service Status:"
    docker-compose -f docker-compose.prod.yml ps
    
    echo ""
    echo "View logs with:"
    echo "  docker-compose -f docker-compose.prod.yml logs -f"
else
    echo -e "${RED}✗ Health check failed (HTTP $HTTP_CODE)${NC}"
    echo "Check logs with:"
    echo "  docker-compose -f docker-compose.prod.yml logs"
    exit 1
fi

echo ""
echo -e "${GREEN}Deployment complete! 🎉${NC}"
