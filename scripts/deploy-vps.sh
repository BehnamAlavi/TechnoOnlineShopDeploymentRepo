#!/bin/bash
# Manual VPS deployment script (alternative to GitHub Actions)

set -e

# Configuration
VPS_HOST=${1:-}
VPS_USER=${2:-behi}
VPS_PORT=${3:-22}
VPS_APP_PATH="/opt/techno-shop"
DEPLOY_KEY=~/.ssh/deploy_key

# Validation
if [ -z "$VPS_HOST" ]; then
    echo "Usage: bash deploy-vps.sh <VPS_HOST> [VPS_USER] [VPS_PORT]"
    echo "Example: bash deploy-vps.sh 5.160.219.141 behi 22"
    exit 1
fi

if [ ! -f "$DEPLOY_KEY" ]; then
    echo "Error: SSH key not found at $DEPLOY_KEY"
    echo "Run: bash scripts/setup-ssh.sh"
    exit 1
fi

echo "=========================================="
echo "TechnoShop Online Manual VPS Deployment"
echo "=========================================="
echo "VPS Host: $VPS_HOST"
echo "VPS User: $VPS_USER"
echo "VPS Port: $VPS_PORT"
echo "=========================================="
echo ""

# Check local files
echo "Checking required files..."
[ -f docker-compose.yml ] || { echo "Error: docker-compose.yml not found"; exit 1; }
[ -f nginx.conf ] || { echo "Error: nginx.conf not found"; exit 1; }
echo "✓ Required files found"
echo ""

# Create VPS directories
echo "=========================================="
echo "Creating directories on VPS..."
echo "=========================================="
ssh -i $DEPLOY_KEY -p $VPS_PORT $VPS_USER@$VPS_HOST << 'EOF'
set -e
mkdir -p /opt/techno-shop
mkdir -p /opt/techno-shop/data/categories
mkdir -p /opt/techno-shop/data/products
mkdir -p /opt/techno-shop/data/productalbum
echo "✓ Directories created"
EOF
echo ""

# Transfer files
echo "=========================================="
echo "Transferring files to VPS..."
echo "=========================================="

echo "Transferring docker-compose.yml..."
scp -i $DEPLOY_KEY -P $VPS_PORT docker-compose.yml $VPS_USER@$VPS_HOST:$VPS_APP_PATH/
echo "✓ docker-compose.yml transferred"

echo "Transferring nginx.conf..."
scp -i $DEPLOY_KEY -P $VPS_PORT nginx.conf $VPS_USER@$VPS_HOST:$VPS_APP_PATH/
echo "✓ nginx.conf transferred"

if [ -f init.sql ]; then
    echo "Transferring init.sql..."
    scp -i $DEPLOY_KEY -P $VPS_PORT init.sql $VPS_USER@$VPS_HOST:$VPS_APP_PATH/
    echo "✓ init.sql transferred"
elif [ -f backup.text ]; then
    echo "Transferring backup.text as init.sql..."
    scp -i $DEPLOY_KEY -P $VPS_PORT backup.text $VPS_USER@$VPS_HOST:$VPS_APP_PATH/init.sql
    echo "✓ backup.text transferred"
fi

if [ -f .env ]; then
    echo "Transferring .env..."
    scp -i $DEPLOY_KEY -P $VPS_PORT .env $VPS_USER@$VPS_HOST:$VPS_APP_PATH/
    echo "✓ .env transferred"
fi

echo ""

# Pull images and deploy
echo "=========================================="
echo "Pulling images and deploying services..."
echo "=========================================="

ssh -i $DEPLOY_KEY -p $VPS_PORT $VPS_USER@$VPS_HOST << 'EOF'
set -e

cd /opt/techno-shop

echo "Pulling images..."
docker compose pull

echo "Stopping old containers..."
docker compose down || true

echo "Starting new containers..."
docker compose up -d

sleep 5

echo "✓ Services deployed"
EOF
echo ""

# Verify deployment
echo "=========================================="
echo "Deployment Summary"
echo "=========================================="

ssh -i $DEPLOY_KEY -p $VPS_PORT $VPS_USER@$VPS_HOST << 'EOF'
set -e

cd /opt/techno-shop

echo ""
echo "Running Containers:"
docker ps

echo ""
echo "Docker Compose Status:"
docker compose ps

echo ""
echo "Service Health:"
docker ps --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "=========================================="
echo "Deployment completed successfully!"
echo "=========================================="
echo ""
echo "Access services at:"
echo "  Frontend:           http://${VPS_HOST}:3000"
echo "  Techno API:         http://${VPS_HOST}:5001"
echo "  ControlPanel API:   http://${VPS_HOST}:5002"
echo "  Nginx Proxy:        http://${VPS_HOST}:1211"
EOF
