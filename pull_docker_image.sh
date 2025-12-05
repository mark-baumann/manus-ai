#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default values
IMAGE_REGISTRY="${IMAGE_REGISTRY:-markbaumann}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Manus AI - Docker Update Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Step 1: Pull latest images from Docker Hub
echo -e "${YELLOW}[1/4] Pulling latest images from Docker Hub...${NC}"
docker pull ${IMAGE_REGISTRY}/manus-frontend:${IMAGE_TAG}
docker pull ${IMAGE_REGISTRY}/manus-backend:${IMAGE_TAG}
docker pull ${IMAGE_REGISTRY}/manus-sandbox:${IMAGE_TAG}

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to pull images from Docker Hub${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Images pulled successfully${NC}"
echo ""

# Step 2: Stop and remove existing containers
echo -e "${YELLOW}[2/4] Stopping existing containers...${NC}"
docker compose down

# Also stop any old containers that might be running
echo -e "${YELLOW}    Checking for old containers...${NC}"
OLD_CONTAINERS=$(docker ps -a --filter "name=manus-" --filter "name=ai-manus-" -q)
if [ ! -z "$OLD_CONTAINERS" ]; then
    echo -e "${YELLOW}    Removing old containers...${NC}"
    docker stop $OLD_CONTAINERS 2>/dev/null
    docker rm $OLD_CONTAINERS 2>/dev/null
fi

echo -e "${GREEN}✓ Containers stopped and removed${NC}"
echo ""

# Step 3: Start containers with new images
echo -e "${YELLOW}[3/4] Starting containers with new images...${NC}"
docker compose up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to start containers${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Containers started${NC}"
echo ""

# Step 4: Show container status
echo -e "${YELLOW}[4/4] Container status:${NC}"
docker compose ps

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Update completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Frontend: ${BLUE}http://localhost:5173${NC}"
echo -e "Sandbox:  ${BLUE}http://localhost:8080${NC}"
echo ""
echo -e "To view logs: ${BLUE}docker compose logs -f${NC}"
