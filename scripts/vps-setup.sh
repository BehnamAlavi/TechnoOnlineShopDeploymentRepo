#!/bin/bash
# VPS Pre-deployment setup script

set -e

echo "=========================================="
echo "TechnoShop Online VPS Pre-deployment Setup"
echo "=========================================="
echo ""

# Update system
echo "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y
echo "✓ System updated"
echo ""

# Install Docker
echo "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    rm get-docker.sh
    echo "✓ Docker installed"
else
    echo "✓ Docker already installed"
fi
echo ""

# Add user to docker group
echo "Adding current user to docker group..."
sudo usermod -aG docker $USER
echo "✓ User added to docker group (may require re-login)"
echo ""

# Install Docker Compose
echo "Installing Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
    sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "✓ Docker Compose installed"
else
    echo "✓ Docker Compose already installed"
fi
echo ""

# Verify installations
echo "=========================================="
echo "Verifying Installations"
echo "=========================================="
docker --version
docker-compose --version
echo ""

# Setup SSH authorized_keys
echo "Setting up SSH authorization..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "⚠ Add your public key to ~/.ssh/authorized_keys"
echo "✓ SSH directory ready"
echo ""

# Create app directory
echo "Creating application directory..."
mkdir -p /opt/techno-shop
mkdir -p /opt/techno-shop/data/categories
mkdir -p /opt/techno-shop/data/products
mkdir -p /opt/techno-shop/data/productalbum
echo "✓ Application directories created"
echo ""

# Configure firewall if UFW is installed
if command -v ufw &> /dev/null; then
    echo "Configuring firewall..."
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
    sudo ufw allow 443/tcp
    sudo ufw allow 1211/tcp
    sudo ufw allow 3000/tcp
    sudo ufw allow 5001/tcp
    sudo ufw allow 5002/tcp
    echo "✓ Firewall configured"
fi
echo ""

echo "=========================================="
echo "✓ VPS Pre-deployment Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Add your SSH public key to ~/.ssh/authorized_keys"
echo "  2. Set up GitHub Secrets with VPS details"
echo "  3. Push to main branch to trigger deployment"
echo ""
