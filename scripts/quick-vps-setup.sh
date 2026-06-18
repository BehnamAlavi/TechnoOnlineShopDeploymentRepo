#!/bin/bash
# Quick VPS Setup - Run this on your VPS

set -e

echo "=========================================="
echo "TechnoShop Online - VPS Quick Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Update System
echo -e "${YELLOW}[1/6] Updating system...${NC}"
sudo apt-get update > /dev/null 2>&1
sudo apt-get upgrade -y > /dev/null 2>&1
echo -e "${GREEN}✓ System updated${NC}"

# Step 2: Install Docker
echo -e "${YELLOW}[2/6] Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh > /dev/null 2>&1
    sudo sh get-docker.sh > /dev/null 2>&1
    rm get-docker.sh
    sudo usermod -aG docker $USER > /dev/null 2>&1
    echo -e "${GREEN}✓ Docker installed${NC}"
else
    echo -e "${GREEN}✓ Docker already installed${NC}"
fi

# Step 3: Install Docker Compose
echo -e "${YELLOW}[3/6] Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose > /dev/null 2>&1
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✓ Docker Compose installed${NC}"
else
    echo -e "${GREEN}✓ Docker Compose already installed${NC}"
fi

# Step 4: Create directories
echo -e "${YELLOW}[4/6] Creating application directories...${NC}"
mkdir -p /opt/techno-shop
mkdir -p /opt/techno-shop/data/categories
mkdir -p /opt/techno-shop/data/products
mkdir -p /opt/techno-shop/data/productalbum
echo -e "${GREEN}✓ Directories created${NC}"

# Step 5: Verify installations
echo -e "${YELLOW}[5/6] Verifying installations...${NC}"
DOCKER_VERSION=$(docker --version)
COMPOSE_VERSION=$(docker compose --version)
echo "  $DOCKER_VERSION"
echo "  $COMPOSE_VERSION"
echo -e "${GREEN}✓ Verified${NC}"

# Step 6: Display next steps
echo -e "${YELLOW}[6/6] Setup complete!${NC}"
echo ""
echo -e "${GREEN}=========================================="
echo "✓ VPS Setup Complete"
echo "==========================================${NC}"
echo ""
echo "Next steps:"
echo ""
echo "1. Transfer files to /opt/techno-shop:"
echo "   - docker-compose.yml"
echo "   - nginx.conf"
echo "   - init.sql"
echo ""
echo "2. Create .env file:"
echo "   cat > /opt/techno-shop/.env << 'EOF'"
echo "   POSTGRES_PASSWORD=your_password"
echo "   REGISTRY_OWNER=your_github_username"
echo "   TECHNO_API_VERSION=1.0.0"
echo "   CONTROLPANEL_API_VERSION=1.0.0"
echo "   FRONTEND_VERSION=1.0.0"
echo "   VPS_HOST=5.160.219.141"
echo "   NODE_ENV=production"
echo "   ASPNETCORE_ENVIRONMENT=Production"
echo "   EOF"
echo ""
echo "3. Login to GHCR:"
echo "   echo 'YOUR_GITHUB_TOKEN' | docker login -u your_username --password-stdin ghcr.io"
echo ""
echo "4. Pull and start services:"
echo "   cd /opt/techno-shop"
echo "   docker compose pull"
echo "   docker compose up -d"
echo ""
echo "5. Verify services:"
echo "   docker compose ps"
echo ""
echo "Services will be available at:"
echo "  Frontend:        http://5.160.219.141:3000"
echo "  Techno API:      http://5.160.219.141:5001"
echo "  ControlPanel:    http://5.160.219.141:5002"
echo "  Nginx:           http://5.160.219.141:1211"
echo ""
