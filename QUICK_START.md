# Quick Start Guide

## 5-Minute Setup

### Step 1: Generate SSH Key

```bash
bash scripts/setup-ssh.sh
```

This generates `~/.ssh/deploy_key`. Output will show:
- Public key to add to VPS
- Private key to copy to GitHub secret

### Step 2: Add GitHub Secrets

Go to repository **Settings → Secrets and variables → Actions**

Add these 5 secrets:
```
VPS_HOST = 5.160.219.141
VPS_USER = behi
VPS_PORT = 22
VPS_SSH_KEY = (paste contents of ~/.ssh/deploy_key)
POSTGRES_PASSWORD = (your secure password)
```

### Step 3: Setup VPS (SSH first time)

```bash
ssh behi@5.160.219.141

# Run VPS setup
bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/TechnoOnlineShopDeploymentRepo/main/scripts/vps-setup.sh)"

# Add SSH public key
echo "YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### Step 4: Copy Source Code

Ensure these exist in your repository:
```
repos/
├── backend/
│   └── TechnoOnlineShop.Api/Dockerfile
├── controlpanel/
│   └── ControlPanel.TechnoOnlineShop.Api/Dockerfile
└── frontend/
    └── Dockerfile
```

### Step 5: Deploy

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

Watch deployment in **repository → Actions tab**

---

## Access Services

After ~5 minutes:

```
Frontend:           http://5.160.219.141:3000
Techno API:         http://5.160.219.141:5001
ControlPanel API:   http://5.160.219.141:5002
Nginx Proxy:        http://5.160.219.141:1211
```

## Common Commands

### Check deployment status
```bash
ssh behi@5.160.219.141
cd /opt/techno-shop
docker compose ps
```

### View logs
```bash
docker compose logs -f techno-api
docker compose logs -f controlpanel-api
docker compose logs -f frontend
```

### Restart services
```bash
docker compose restart techno-api
docker compose restart controlpanel-api
docker compose restart frontend
```

### Update versions
1. Edit `docker-compose.yml` - change version numbers
2. Edit `.github/workflows/deploy.yml` - update build versions
3. Push to main

### Manual deploy without GitHub Actions
```bash
ssh behi@5.160.219.141
cd /opt/techno-shop
docker compose pull
docker compose down
docker compose up -d
docker compose ps
```

## Troubleshooting

### Services won't start
```bash
docker compose logs
docker ps -a
```

### Can't connect to VPS
```bash
# Check SSH key permissions
chmod 600 ~/.ssh/deploy_key
chmod 700 ~/.ssh

# Test SSH connection
ssh -i ~/.ssh/deploy_key -p 22 behi@5.160.219.141
```

### Images not building
- Check `.github/workflows/deploy.yml` logs
- Ensure `repos/backend`, `repos/controlpanel`, `repos/frontend` exist
- Verify Dockerfile paths are correct

### Database won't initialize
```bash
# Check if init.sql exists
ls -la init.sql

# Check database logs
docker compose logs postgres
```

## File Checklist

Before pushing to repository, verify you have:

- [ ] `.gitignore` — Prevents secrets
- [ ] `.github/workflows/deploy.yml` — Automation
- [ ] `docker-compose.yml` — Services
- [ ] `nginx.conf` — Proxy
- [ ] `.env.example` — Template
- [ ] `README.md` — Docs
- [ ] `scripts/setup-ssh.sh` — Key generation
- [ ] `scripts/vps-setup.sh` — VPS setup
- [ ] `repos/backend/` — API source
- [ ] `repos/controlpanel/` — Admin source
- [ ] `repos/frontend/` — Frontend source
- [ ] `init.sql` or `backup.text` — Database

---

**Next**: See [README.md](README.md) for detailed documentation
