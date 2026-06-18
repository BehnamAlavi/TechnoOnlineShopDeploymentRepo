#!/bin/bash
# GitHub Actions SSH Key Setup

set -e

echo "=========================================="
echo "VPS SSH Key Setup for GitHub Actions"
echo "=========================================="
echo ""

# Check if SSH keys already exist
if [ -f ~/.ssh/deploy_key ]; then
    echo "Warning: ~/.ssh/deploy_key already exists"
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping key generation"
        exit 0
    fi
fi

# Generate SSH key
echo "Generating ed25519 SSH key..."
ssh-keygen -t ed25519 -f ~/.ssh/deploy_key -N ""
echo "✓ SSH key generated"
echo ""

# Display public key
echo "=========================================="
echo "PUBLIC KEY (add to VPS ~/.ssh/authorized_keys)"
echo "=========================================="
echo ""
cat ~/.ssh/deploy_key.pub
echo ""
echo "=========================================="
echo ""

# Instructions for GitHub Secret
echo "=========================================="
echo "PRIVATE KEY (copy to GitHub Secret)"
echo "=========================================="
echo ""
echo "1. Copy the entire key below including the BEGIN and END lines"
echo "2. Go to repository Settings → Secrets and variables → Actions"
echo "3. Create new secret: VPS_SSH_KEY"
echo "4. Paste the key content"
echo ""
echo "---BEGIN PRIVATE KEY---"
cat ~/.ssh/deploy_key
echo "---END PRIVATE KEY---"
echo ""
echo "=========================================="
echo "Next steps:"
echo "=========================================="
echo ""
echo "1. SSH to VPS and add public key:"
echo "   echo 'PUBLIC_KEY_HERE' >> ~/.ssh/authorized_keys"
echo "   chmod 600 ~/.ssh/authorized_keys"
echo ""
echo "2. Add GitHub Secrets:"
echo "   VPS_SSH_KEY = (private key above)"
echo "   VPS_HOST = 5.160.219.141"
echo "   VPS_USER = behi"
echo "   VPS_PORT = 22"
echo "   POSTGRES_PASSWORD = (secure password)"
echo ""
echo "✓ Setup complete!"
