# Repository Verification & Push Instructions

## Pre-Push Checklist

Run these commands in your repository directory to verify everything is ready:

### 1. Check Git Status
```bash
cd C:\Users\ASUS\source\repos\TechnoOnlineShopDeploymentRepo
git status
```

**Expected output**: Should show `On branch main` and new/modified files

### 2. Verify .gitignore Exists
```bash
git ls-files | grep "\.gitignore"
```

**Expected output**: `.gitignore` should be listed

### 3. Verify .env NOT Tracked
```bash
git ls-files | grep "\.env"
```

**Expected output**: Only `.env.example` should appear (not `.env` or `.env.production`)

### 4. Check for Secrets
```bash
git diff --cached | findstr /i "password secret token api_key" || echo "No secrets found"
```

**Expected output**: No passwords in output

### 5. List Files to Push
```bash
git status --short
```

**Expected output**: Should show files starting with `??` or `M` (modified)

---

## Files Ready to Push

✅ **Configuration Files** (Must include):
```
docker-compose.yml
nginx.conf
.github/workflows/deploy.yml
.env.example
.gitignore
```

✅ **Documentation** (Should include):
```
README.md
QUICK_START.md
PUSH_CHECKLIST.md
```

✅ **Scripts** (Should include):
```
scripts/setup-ssh.sh
scripts/vps-setup.sh
scripts/deploy-vps.sh
```

✅ **Database** (Choose one):
```
init.sql  (preferred)
OR
backup.text
```

✅ **Source Code** (Must include):
```
repos/backend/
repos/controlpanel/
repos/frontend/
```

---

## Step-by-Step Push Instructions

### Step 1: Stage All Files
```bash
git add .
```

### Step 2: Verify Staged Files
```bash
git status
```

### Step 3: Review Changes
```bash
git diff --cached --stat
```

### Step 4: Create Commit
```bash
git commit -m "feat: Add production deployment configuration

- Add docker-compose.yml with versioned services (1.0.0)
- Add GitHub Actions CI/CD workflow for automated deployment
- Add nginx reverse proxy configuration
- Add VPS setup and deployment scripts
- Add environment template and comprehensive documentation
- Services: techno-api, controlpanel-api, frontend with GHCR integration"
```

### Step 5: Push to Repository
```bash
git push origin main
```

### Step 6: Verify on GitHub
- Open https://github.com/YOUR_USERNAME/TechnoOnlineShopDeploymentRepo
- Verify all files are visible
- Check that `.env` is NOT visible

---

## Files NOT to Push (Should be in .gitignore)

```
.env                          ✗ Contains secrets
.ssh/                         ✗ SSH keys
deploy_key                    ✗ SSH private key
deploy_key.pub               ✗ SSH public key
.vs/                         ✗ Visual Studio cache
.idea/                       ✗ IDE settings
node_modules/                ✗ Dependencies
postgres_data/               ✗ Database volume
redis_data/                  ✗ Redis volume
*.log                        ✗ Log files
dist/, build/                ✗ Build output
```

---

## GitHub Secrets Setup (After Push)

Once files are pushed, add GitHub Secrets:

1. Go to repository → Settings → Secrets and variables → Actions
2. Create 5 new repository secrets:

### Secret 1: VPS_HOST
```
Name: VPS_HOST
Value: 5.160.219.141
```

### Secret 2: VPS_USER
```
Name: VPS_USER
Value: behi
```

### Secret 3: VPS_PORT
```
Name: VPS_PORT
Value: 22
```

### Secret 4: VPS_SSH_KEY
```
Name: VPS_SSH_KEY
Value: (paste contents of ~/.ssh/deploy_key from setup-ssh.sh)
```

### Secret 5: POSTGRES_PASSWORD
```
Name: POSTGRES_PASSWORD
Value: (your secure database password)
```

---

## Post-Push: Trigger Deployment

### Option A: Automatic (on next push)
```bash
git add .
git commit -m "Trigger deployment"
git push origin main
```

### Option B: Manual (use workflow_dispatch)
1. Go to repository → Actions tab
2. Click "Deploy to VPS" workflow
3. Click "Run workflow"
4. Select main branch
5. Click "Run workflow"

---

## Monitor Deployment

### View Workflow Status
1. Go to repository → Actions tab
2. Click on the workflow run
3. Monitor build-and-push and deploy jobs
4. Check logs if any step fails

### Expected Workflow Duration
- **Build & Push**: 5-10 minutes
- **Deploy**: 3-5 minutes
- **Total**: ~15 minutes

### Deployment Complete When
- All workflow jobs show ✅ green checkmark
- Last step shows "Deployment completed successfully!"
- Services are accessible at http://5.160.219.141:3000, etc.

---

## Verification on VPS

After deployment succeeds, verify from VPS:

```bash
ssh behi@5.160.219.141

cd /opt/techno-shop

# Check running containers
docker compose ps

# Check service health
docker ps --format "table {{.Names}}\t{{.Status}}"

# View logs
docker compose logs -f

# Test API endpoint
curl http://localhost:5001/health
curl http://localhost:5002/health
```

---

## Troubleshooting

### Issue: "Git tracking denied because path is ignored"
```bash
# Solution: Update .gitignore or force add
git add -f repos/
```

### Issue: ".env file committed"
```bash
# Solution: Remove from git history
git rm --cached .env
git commit -m "Remove .env from tracking"
git push origin main
```

### Issue: "Permission denied" on scripts
```bash
# Solution: Make scripts executable on Windows/Git
git update-index --chmod=+x scripts/setup-ssh.sh
git update-index --chmod=+x scripts/vps-setup.sh
git update-index --chmod=+x scripts/deploy-vps.sh
git commit -m "Make scripts executable"
git push origin main
```

### Issue: Workflow fails at "Build and push Techno API"
- Check if `repos/backend/TechnoOnlineShop.Api/Dockerfile` exists
- Check if paths in `.github/workflows/deploy.yml` are correct
- Verify GitHub token has `packages: write` permission

### Issue: SSH key authentication fails
- Verify private key is added to `VPS_SSH_KEY` secret (with BEGIN/END lines)
- Verify public key is in VPS `~/.ssh/authorized_keys`
- Test locally: `ssh -i ~/.ssh/deploy_key behi@5.160.219.141`

---

## Quick Reference

### List files to be committed
```bash
git status
```

### Show what will be pushed
```bash
git diff origin/main
```

### Undo staging (if needed)
```bash
git reset
```

### See commit history
```bash
git log --oneline
```

### View GitHub Actions logs
```
https://github.com/YOUR_USERNAME/TechnoOnlineShopDeploymentRepo/actions
```

---

## Summary

**To Deploy:**

1. ✅ Verify files ready: `git status`
2. ✅ Stage all files: `git add .`
3. ✅ Commit: `git commit -m "..."`
4. ✅ Push: `git push origin main`
5. ✅ Set GitHub Secrets (5 values)
6. ✅ Monitor Actions tab
7. ✅ Verify on VPS: `docker compose ps`

**Total Time**: ~30 minutes (first time setup)

---

**Repository**: TechnoOnlineShopDeploymentRepo  
**Status**: Ready for production  
**Last Updated**: 2024
