# Files to Push - Complete Checklist

## ✅ ALWAYS PUSH THESE FILES

### Configuration Files
- [x] **docker-compose.yml** — Production Docker Compose (required)
- [x] **.github/workflows/deploy.yml** — GitHub Actions pipeline (required)
- [x] **nginx.conf** — Nginx reverse proxy configuration (required)
- [x] **.env.example** — Environment template (required)

### Documentation
- [x] **README.md** — Full deployment documentation
- [x] **QUICK_START.md** — Quick setup guide
- [x] **PUSH_CHECKLIST.md** — This file

### Git Configuration
- [x] **.gitignore** — Prevents secrets from being committed (CRITICAL)

### Scripts
- [x] **scripts/setup-ssh.sh** — SSH key generation
- [x] **scripts/vps-setup.sh** — VPS environment setup
- [x] **scripts/deploy-vps.sh** — Manual deployment script

### Database Initialization (Choose One)
- [x] **init.sql** — Database schema (if available)
  OR
- [x] **backup.text** — Database backup (used as init.sql)
  OR
- [x] **technoshopdb.sql** — Original database file (if applicable)

### Source Code Repositories (via Git Submodules or Direct Copy)
- [x] **repos/backend/** — Techno API source code with Dockerfile
- [x] **repos/controlpanel/** — ControlPanel API source code with Dockerfile
- [x] **repos/frontend/** — React frontend source code with Dockerfile

---

## ❌ NEVER PUSH THESE FILES

### Secrets & Credentials
- ❌ **.env** — Contains secrets (use .env.example instead)
- ❌ **.env.local** — Local environment overrides
- ❌ **.env.production** — Production secrets
- ❌ `deploy_key` — SSH private key
- ❌ `deploy_key.pub` — SSH public key
- ❌ `*.pem` — Certificate files
- ❌ `*.ppk` — PuTTY keys
- ❌ `id_rsa`, `id_ed25519` — SSH keys

### IDE & Editor Files
- ❌ **.vs/** — Visual Studio cache
- ❌ **.idea/** — IntelliJ IDEA settings
- ❌ **.vscode/settings.json** — VSCode user settings
- ❌ *.swp, *.swo, *~ — Editor temp files
- ❌ .DS_Store — macOS files

### Build Artifacts & Dependencies
- ❌ **node_modules/** — NPM dependencies
- ❌ **dist/** — Build output
- ❌ **build/** — Build output
- ❌ **obj/**, **bin/** — C# build output
- ❌ **.next/** — Next.js build
- ❌ `package-lock.json` — Lock files (or use with caution)

### Log Files
- ❌ **.log** — Log files
- ❌ **logs/** — Log directory
- ❌ `npm-debug.log*` — NPM logs
- ❌ `yarn-error.log*` — Yarn logs

### Data & Backups
- ❌ **postgres_data/** — Database volume
- ❌ **redis_data/** — Redis volume
- ❌ **data/** — Data directory (local)
- ❌ Database backups in root (only keep init.sql)
- ❌ **.backup**, **.bak**, **.orig** — Backup files

### Miscellaneous
- ❌ **compose.yaml** — Old local Windows version
- ❌ **.gitlab-ci.yml** — Old CI configuration
- ❌ **DEPLOYMENT.md** — Old documentation
- ❌ **GITLAB_DEPLOYMENT.md** — Old documentation
- ❌ **transform-compose.sh** — Old migration script (not needed)
- ❌ **transfer-files.sh** — Old transfer script (not needed)

---

## 📋 Pre-Push Verification

Before running `git push`, verify:

### Passwords & Secrets
- [ ] No passwords in any file
- [ ] No API keys in any file
- [ ] No SSH private keys in any file
- [ ] `.env` file is in `.gitignore`
- [ ] `.gitignore` is in repository

### Configuration Files
- [ ] `docker-compose.yml` uses `${VARIABLE}` for secrets
- [ ] `docker-compose.yml` references GHCR images
- [ ] `.env.example` template matches expected variables
- [ ] `nginx.conf` is correct for your setup

### Scripts
- [ ] `scripts/setup-ssh.sh` is executable
- [ ] `scripts/vps-setup.sh` is executable
- [ ] `scripts/deploy-vps.sh` is executable

### GitHub Actions
- [ ] `.github/workflows/deploy.yml` references correct repos
- [ ] Workflow expects correct secrets (VPS_HOST, VPS_USER, etc.)
- [ ] Build paths match your source structure

### Documentation
- [ ] README.md mentions your VPS details correctly
- [ ] QUICK_START.md has accurate instructions
- [ ] All links are correct

---

## 🚀 Git Push Commands

### Clean up old/unnecessary files first

```bash
# Remove old files from git history (don't delete locally yet)
git rm --cached compose.yaml
git rm --cached .gitlab-ci.yml
git rm --cached DEPLOYMENT.md
git rm --cached GITLAB_DEPLOYMENT.md
git rm --cached scripts/transform-compose.sh
git rm --cached scripts/transfer-files.sh
git rm --cached backup.sql  # if it's a directory

# Or just commit the new files and leave old ones
```

### Stage files for commit

```bash
# Add all files in .gitignore
git add . -f  # force add if needed

# Or selectively add files
git add docker-compose.yml
git add .github/workflows/deploy.yml
git add nginx.conf
git add .env.example
git add .gitignore
git add README.md
git add QUICK_START.md
git add PUSH_CHECKLIST.md
git add scripts/
git add init.sql  # or backup.text

# Add repos if using direct copy (not submodules)
git add repos/backend
git add repos/controlpanel
git add repos/frontend
```

### Verify what will be pushed

```bash
git status
git diff --cached
```

### Commit and push

```bash
git commit -m "feat: Add production deployment configuration with GitHub Actions"
git push origin main
```

---

## 📂 Final Repository Structure

After push, your repository should look like:

```
TechnoOnlineShopDeploymentRepo/
├── .gitignore                      ✓ Pushed
├── .github/
│   └── workflows/
│       └── deploy.yml              ✓ Pushed
├── docker-compose.yml              ✓ Pushed
├── nginx.conf                      ✓ Pushed
├── init.sql                        ✓ Pushed (or backup.text)
├── .env.example                    ✓ Pushed
├── README.md                       ✓ Pushed
├── QUICK_START.md                  ✓ Pushed
├── PUSH_CHECKLIST.md               ✓ Pushed
├── scripts/
│   ├── setup-ssh.sh               ✓ Pushed
│   ├── vps-setup.sh               ✓ Pushed
│   └── deploy-vps.sh              ✓ Pushed
├── repos/
│   ├── backend/                   ✓ Pushed
│   │   └── TechnoOnlineShop.Api/Dockerfile
│   ├── controlpanel/              ✓ Pushed
│   │   └── ControlPanel.TechnoOnlineShop.Api/Dockerfile
│   └── frontend/                  ✓ Pushed
│       └── Dockerfile
├── .env                            ✗ NOT pushed (in .gitignore)
├── .ssh/                           ✗ NOT pushed (in .gitignore)
├── deploy_key*                     ✗ NOT pushed (in .gitignore)
├── *.log                           ✗ NOT pushed (in .gitignore)
└── node_modules/                  ✗ NOT pushed (in .gitignore)
```

---

## ⚠️ Critical Security Checks

Before pushing, run these checks:

```bash
# Check for secrets in staged files
git diff --cached | grep -i "password\|secret\|token\|api[_-]key" || echo "No secrets found"

# Check .gitignore is included
git ls-files | grep "^\.gitignore$" && echo ".gitignore is tracked" || echo "ERROR: .gitignore not tracked"

# Verify .env files are not tracked
git ls-files | grep "\.env" | grep -v "\.env\.example" && echo "ERROR: .env files are tracked!" || echo ".env files properly ignored"

# Check for private keys
git ls-files | grep -E "id_rsa|id_ed25519|deploy_key|\.pem" && echo "ERROR: Private keys found!" || echo "No private keys found"
```

---

## 📝 Commit Message Suggestions

```bash
git commit -m "feat: Add production deployment with GitHub Actions and GHCR

- Add docker-compose.yml with versioned services
- Add GitHub Actions workflow for automated deployment
- Add nginx reverse proxy configuration
- Add VPS setup scripts
- Add environment template and documentation
- Services: techno-api:1.0.0, controlpanel-api:1.0.0, frontend:1.0.0"
```

---

## 🔄 After Push

Once pushed:

1. **Verify on GitHub**
   - Go to repository
   - Check that all files are visible
   - Verify `.gitignore` is present
   - Check that `.env` is NOT visible

2. **Set up GitHub Secrets**
   - Settings → Secrets and variables → Actions
   - Add: VPS_HOST, VPS_USER, VPS_PORT, VPS_SSH_KEY, POSTGRES_PASSWORD

3. **Trigger Deployment**
   - Push any change to main (or use workflow_dispatch)
   - Monitor Actions tab
   - Verify deployment to VPS

---

**Status**: Ready to push  
**Last Updated**: 2024
