# GitLab CI/CD Deployment to VPS

Complete automated deployment pipeline from GitLab to your Linux VPS.

## Prerequisites

### 1. VPS Setup (one-time)
SSH into your VPS and run:

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker compose --version

# Log out and back in for group changes
exit
```

### 2. Generate SSH Key for GitLab (on your local machine)

**Windows PowerShell:**
```powershell
ssh-keygen -t rsa -b 4096 -f "$env:USERPROFILE\.ssh\gitlab_vps_deploy" -N ""
```

**Linux/Mac:**
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/gitlab_vps_deploy -N ""
```

### 3. Add SSH Key to VPS

Copy the public key to your VPS:
```bash
# Get your public key content
cat ~/.ssh/gitlab_vps_deploy.pub

# SSH to VPS and add it
ssh user@your-vps-ip
mkdir -p ~/.ssh
echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 4. Create GitLab Repository

1. Go to [GitLab.com](https://gitlab.com) and create a new project
2. Clone it locally:
   ```bash
   git clone https://gitlab.com/your-username/techno-shop.git
   cd techno-shop
   ```

3. Copy your project files:
   ```bash
   # From your existing C:\techonline directory
   cp compose.yaml .
   cp nginx.conf .
   cp backup.text .
   cp -r scripts/ .
   cp .gitlab-ci.yml .
   ```

4. Commit and push:
   ```bash
   git add .
   git commit -m "Initial commit with Docker Compose setup"
   git push origin main
   ```

### 5. Add GitLab CI/CD Variables

Go to your GitLab repo → Settings → CI/CD → Variables

Add the following **masked** variables:

| Variable | Value | Example |
|----------|-------|---------|
| `VPS_HOST` | Your VPS IP or domain | `192.168.1.100` or `vps.example.com` |
| `VPS_USER` | SSH username | `ubuntu` or `root` |
| `VPS_PORT` | SSH port | `22` or custom like `2222` |
| `VPS_SSH_KEY` | Private key content | (paste entire content of `~/.ssh/gitlab_vps_deploy`) |

**To get the private key content:**

**Windows PowerShell:**
```powershell
Get-Content "$env:USERPROFILE\.ssh\gitlab_vps_deploy" | Set-Clipboard
```

**Linux/Mac:**
```bash
cat ~/.ssh/gitlab_vps_deploy | pbcopy  # macOS
cat ~/.ssh/gitlab_vps_deploy | xclip -selection clipboard  # Linux
```

Then paste into GitLab CI/CD variables.

## Repository Structure

Your GitLab repo should look like:
```
techno-shop/
├── .gitlab-ci.yml              # CI/CD pipeline definition
├── scripts/
│   ├── transform-compose.sh    # Transform Windows paths to Linux
│   ├── transfer-files.sh       # Transfer files to VPS
│   └── deploy-vps.sh           # Deploy containers
├── compose.yaml                # Your docker-compose file
├── nginx.conf                  # Nginx configuration
├── backup.text                 # Database backup
└── README.md
```

## How It Works

**Pipeline Flow:**

1. **Transform Config** — Converts Windows paths to Linux paths in compose.yaml
2. **Transfer Files** — Copies all files to VPS via SCP
3. **Deploy to VPS** — Starts Docker Compose containers
4. **Verify Deployment** — Checks that containers are running

## Deployment

### Automatic Deployment (on push to main)
```bash
git add .
git commit -m "Update service"
git push origin main
```

GitLab automatically triggers the pipeline. Monitor at:
**Project → CI/CD → Pipelines**

### Manual Deployment (on-demand)
```bash
git tag deploy-v1.0.0
git push origin deploy-v1.0.0
```

Or trigger manually in GitLab:
**CI/CD → Pipelines → Run Pipeline**

## Monitor Deployment

1. **GitLab CI/CD Logs:**
   - Go to Project → CI/CD → Pipelines
   - Click the pipeline run
   - View logs for each stage

2. **SSH to VPS to check status:**
   ```bash
   ssh user@your-vps-ip
   docker ps
   docker compose -f /opt/techno-shop/docker-compose.yml ps
   docker compose -f /opt/techno-shop/docker-compose.yml logs postgres
   ```

3. **Check services:**
   - Nginx: `http://your-vps-ip:1211`
   - Frontend: `http://your-vps-ip:3000`
   - Techno API: `http://your-vps-ip:5001`
   - ControlPanel API: `http://your-vps-ip:5002`

## Troubleshooting

### SSH Connection Fails
- Verify VPS_HOST, VPS_USER, VPS_PORT in GitLab variables
- Test locally:
  ```bash
  ssh -i ~/.ssh/gitlab_vps_deploy -p 22 ubuntu@192.168.1.100
  ```
- Check VPS firewall: `sudo ufw status`
- Allow SSH: `sudo ufw allow 22`

### SCP Transfer Fails
- Check file permissions on GitLab runner
- Verify SSH key has correct permissions: `chmod 600 ~/.ssh/gitlab_vps_deploy`
- Ensure VPS user owns /opt/techno-shop

### Docker Compose Fails on VPS
```bash
# SSH to VPS
ssh user@your-vps-ip
cd /opt/techno-shop

# Check logs
docker compose logs postgres
docker compose logs techno-api

# Restart services
docker compose down
docker compose up -d
```

### Database Not Restoring
- Verify backup.text is in /opt/techno-shop
- Check postgres container logs: `docker logs postgres`
- Manually restore:
  ```bash
  docker exec postgres psql -U postgres -d technoshopdb -f /docker-entrypoint-initdb.d/init.sql
  ```

## Advanced: Using Build Contexts

If you want to build images on the VPS instead of pulling pre-built ones, your Dockerfiles need to be in the repo:

```
techno-shop/
├── backend/
│   ├── TechnoOnlineShop.Api/
│   └── Dockerfile
├── controlpanel/
│   └── Dockerfile
├── frontend/
│   └── Dockerfile
└── compose.yaml
```

Update compose.yaml to use `build:` instead of `image:`:
```yaml
techno-api-service:
  build:
    context: ./backend
    dockerfile: TechnoOnlineShop.Api/Dockerfile
  image: techno-api:latest
```

## Environment Variables for Production

Create `.env.prod` in repo root:
```
POSTGRES_PASSWORD=secure-password-here
POSTGRES_DB=technoshopdb
POSTGRES_USER=postgres
```

Update compose.yaml to reference it:
```yaml
postgres:
  env_file:
    - .env.prod
```

Then add to GitLab variables:
- `POSTGRES_PASSWORD`: Your secure password (marked as **masked**)

## Rollback

To revert to previous version:
```bash
# SSH to VPS
ssh user@your-vps-ip
cd /opt/techno-shop

# View git history (if you stored it)
docker compose down

# Restore from backup or use git tags
git checkout deploy-v1.0.0
docker compose up -d
```

## Next Steps

1. Set up all VPS variables in GitLab
2. Push code to main branch
3. Monitor CI/CD pipeline
4. Verify services are running on VPS
5. Set up SSL/HTTPS with Let's Encrypt
6. Configure firewall rules and backups
