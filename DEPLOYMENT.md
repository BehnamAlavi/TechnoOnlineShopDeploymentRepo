# GitHub Actions Deployment Configuration

## Setup Steps

### 1. Generate SSH key pair (on your local machine, Windows PowerShell)
```powershell
ssh-keygen -t rsa -b 4096 -f $env:USERPROFILE\.ssh\vps_deploy_key -N ""
```

### 2. Add public key to VPS
```bash
# On VPS as root or with sudo
cat ~/.ssh/vps_deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 3. Create GitHub repository
- Push your code to GitHub (including compose.yaml, Dockerfiles, nginx.conf, etc.)
- Make sure `.github/workflows/deploy.yml` is in the repo

### 4. Add GitHub Secrets
Go to: Settings → Secrets and variables → Actions → New repository secret

Add these secrets:
- **VPS_HOST**: Your VPS IP address (e.g., `192.168.1.100` or `vps.example.com`)
- **VPS_USER**: SSH username (e.g., `ubuntu`, `root`, `deployer`)
- **VPS_PORT**: SSH port (usually `22`, or custom like `2222`)
- **VPS_SSH_KEY**: Content of `~/.ssh/vps_deploy_key` (private key - keep it secret!)

To get the private key content (PowerShell):
```powershell
Get-Content $env:USERPROFILE\.ssh\vps_deploy_key | Set-Clipboard
```

### 5. VPS Prerequisites
Install Docker and Docker Compose on your VPS:

```bash
# SSH into VPS
ssh user@your-vps-ip

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Log out and back in for group changes to take effect
```

### 6. Repository Structure
Your GitHub repo should look like:
```
techno-shop/
├── .github/
│   └── workflows/
│       └── deploy.yml
├── scripts/
│   ├── transform-compose.sh
│   └── transfer-files.sh
├── compose.yaml
├── nginx.conf
├── backup.text
└── (your source code repos or submodules)
```

### 7. Deploy
Simply push to main branch:
```bash
git push origin main
```

GitHub Actions will automatically:
1. Transform compose.yaml for Linux
2. Transfer files to your VPS
3. Deploy containers
4. Verify deployment

### 8. Monitor Deployment
- Go to GitHub → Actions tab
- Click on the workflow run to see logs
- Troubleshoot if needed

## Customization

### For build contexts (API source code)
If your API Dockerfiles reference local contexts like:
```yaml
build:
  context: C:\Users\ASUS\source\repos\BehnamAlavi\TechnoOnlineShop\backend
```

Option A: Add submodules to your GitHub repo
```bash
cd your-techno-shop-repo
git submodule add https://github.com/your-org/TechnoOnlineShop.git backend
git submodule add https://github.com/your-org/TechnoOnlineShop.ControlPanel.git controlpanel
```

Option B: Pre-build images and push to Docker Hub, then pull on VPS
```bash
docker build -t your-docker-hub/techno-api:latest ./backend
docker push your-docker-hub/techno-api:latest
```

Then update compose.yaml to use `image: your-docker-hub/techno-api:latest` instead of `build:`

### For environment variables
Create a `.env.prod` file and transfer it:
```bash
# .env.prod
POSTGRES_PASSWORD=your-secure-password
ASPNETCORE_URLS=http://+:5000
```

Then update compose file to use `env_file: .env.prod`

## Troubleshooting

**SSH key permission denied:**
- Ensure private key is in ~/.ssh/deploy_key with chmod 600
- Verify public key is in VPS ~/.ssh/authorized_keys

**SCP transfer fails:**
- Check directory permissions on VPS
- Ensure SCP paths use forward slashes on Linux

**Containers fail to start:**
- SSH to VPS and run: `docker compose logs`
- Check if ports are already in use: `sudo netstat -tlnp | grep LISTEN`

**Database backup not restoring:**
- Verify backup.text is copied to VPS
- Check postgres container logs: `docker logs postgres`
