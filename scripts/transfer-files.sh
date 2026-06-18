#!/bin/bash
# Transfer files to VPS via SCP

set -e

VPS_HOST=${VPS_HOST}
VPS_USER=${VPS_USER}
VPS_PORT=${VPS_PORT:-22}
VPS_APP_PATH=${VPS_APP_PATH:-/opt/techno-shop}
DEPLOY_KEY=~/.ssh/deploy_key

echo "=========================================="
echo "Creating application directory on VPS..."
echo "=========================================="

ssh -i $DEPLOY_KEY -p $VPS_PORT $VPS_USER@$VPS_HOST "
  mkdir -p $VPS_APP_PATH
  mkdir -p $VPS_APP_PATH/repos/backend
  mkdir -p $VPS_APP_PATH/repos/controlpanel
  mkdir -p $VPS_APP_PATH/frontend
"

echo "✓ Directories created"

echo ""
echo "=========================================="
echo "Transferring Docker Compose file..."
echo "=========================================="

scp -i $DEPLOY_KEY -P $VPS_PORT compose.prod.yaml $VPS_USER@$VPS_HOST:$VPS_APP_PATH/docker-compose.yml

echo "✓ docker-compose.yml transferred"

echo ""
echo "=========================================="
echo "Transferring configuration files..."
echo "=========================================="

scp -i $DEPLOY_KEY -P $VPS_PORT nginx.conf $VPS_USER@$VPS_HOST:$VPS_APP_PATH/

echo "✓ nginx.conf transferred"

echo ""
echo "=========================================="
echo "Transferring database backup..."
echo "=========================================="

scp -i $DEPLOY_KEY -P $VPS_PORT backup.text $VPS_USER@$VPS_HOST:$VPS_APP_PATH/init.sql

echo "✓ backup.text transferred as init.sql"

echo ""
echo "=========================================="
echo "All files transferred successfully!"
echo "=========================================="
