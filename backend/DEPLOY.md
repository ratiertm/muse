# Muse Backend Deployment Guide

This guide covers deploying the Muse backend to Oracle Cloud Infrastructure (OCI) Free Tier in Chuncheon (춘천).

---

## Prerequisites

### 1. Oracle Cloud Account
- Sign up at https://cloud.oracle.com
- Choose Free Tier (항상 무료 계정)
- Select Chuncheon (춘천) region: `ap-chuncheon-1`

### 2. Create Compute Instance
**Specs (Free Tier):**
- Shape: VM.Standard.A1.Flex (ARM-based)
- OCPU: 2 (or max available in free tier)
- Memory: 12 GB (or max available)
- OS: Ubuntu 22.04 LTS
- Boot Volume: 50 GB

**Networking:**
- Create or use existing VCN
- Assign public IP
- Configure security list:
  - Ingress: Port 22 (SSH), 80 (HTTP), 443 (HTTPS)
  - Egress: All traffic allowed

### 3. SSH Access
```bash
ssh -i ~/.ssh/oci_key ubuntu@<PUBLIC_IP>
```

---

## Installation Steps

### Step 1: Update System
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl build-essential postgresql-client
```

### Step 2: Install Docker & Docker Compose
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify
docker --version
docker-compose --version
```

### Step 3: Clone Repository
```bash
cd ~
git clone https://github.com/YOUR_USERNAME/charbot.git
cd charbot/backend
```

### Step 4: Configure Environment
```bash
# Copy production environment template
cp .env.production.example .env.production

# Edit with your values
nano .env.production
```

**Required changes:**
- `POSTGRES_PASSWORD`: Strong random password
- `DATABASE_URL`: Use same password
- `OPENAI_API_KEY`: Your OpenAI API key
- `ANTHROPIC_API_KEY`: Your Anthropic API key
- `SECRET_KEY`: Generate with `openssl rand -hex 32`

### Step 5: Generate SSL Certificate (Optional)

#### Option A: Self-Signed (for internal use)
```bash
mkdir -p nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem \
  -subj "/C=KR/ST=Seoul/L=Seoul/O=Muse/CN=muse.local"
```

#### Option B: Let's Encrypt (for public domain)
```bash
# Install certbot
sudo apt install -y certbot

# Get certificate (requires domain pointing to your IP)
sudo certbot certonly --standalone -d your-domain.com

# Link certificates
mkdir -p nginx/ssl
sudo ln -s /etc/letsencrypt/live/your-domain.com/fullchain.pem nginx/ssl/cert.pem
sudo ln -s /etc/letsencrypt/live/your-domain.com/privkey.pem nginx/ssl/key.pem

# Auto-renewal
sudo crontab -e
# Add: 0 3 * * * certbot renew --quiet
```

### Step 6: Deploy
```bash
# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

The script will:
1. Build Docker images
2. Start PostgreSQL
3. Run database migrations
4. Start backend and Nginx
5. Verify health

### Step 7: Verify Deployment
```bash
# Check service status
docker-compose -f docker-compose.prod.yml ps

# Check health endpoint
curl http://localhost/health

# View logs
docker-compose -f docker-compose.prod.yml logs -f backend
```

---

## Configuration for Mobile App

### Get Server IP
```bash
curl ifconfig.me
```

### Update Flutter App
In `frontend/lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://YOUR_SERVER_IP';
// or with domain:
// static const String baseUrl = 'https://your-domain.com';
```

---

## Maintenance

### Update Application
```bash
cd ~/charbot/backend
./deploy.sh
```

### View Logs
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f backend
docker-compose -f docker-compose.prod.yml logs -f postgres
docker-compose -f docker-compose.prod.yml logs -f nginx
```

### Restart Services
```bash
docker-compose -f docker-compose.prod.yml restart

# Specific service
docker-compose -f docker-compose.prod.yml restart backend
```

### Stop Services
```bash
docker-compose -f docker-compose.prod.yml down

# Keep data volumes
docker-compose -f docker-compose.prod.yml down --volumes
```

### Database Backup
```bash
# Backup
docker exec charbot-postgres-prod pg_dump -U charbot charbot > backup_$(date +%Y%m%d).sql

# Restore
cat backup_20250320.sql | docker exec -i charbot-postgres-prod psql -U charbot -d charbot
```

### Check Resource Usage
```bash
# Disk space
df -h

# Memory
free -h

# Docker resource usage
docker stats

# Clean up old images
docker system prune -a
```

---

## Alternative: Systemd Service (without Docker)

If you prefer running directly with systemd instead of Docker:

### 1. Install Poetry
```bash
curl -sSL https://install.python-poetry.org | python3 -
export PATH="/home/ubuntu/.local/bin:$PATH"
```

### 2. Install Dependencies
```bash
cd ~/charbot/backend
poetry install --no-dev
```

### 3. Install PostgreSQL
```bash
sudo apt install -y postgresql postgresql-contrib
sudo -u postgres createuser charbot
sudo -u postgres createdb charbot
sudo -u postgres psql -c "ALTER USER charbot PASSWORD 'your_password';"
```

### 4. Run Migrations
```bash
poetry run alembic upgrade head
```

### 5. Install Systemd Service
```bash
sudo cp charbot-backend.service /etc/systemd/system/
sudo mkdir -p /var/log/charbot
sudo chown ubuntu:ubuntu /var/log/charbot
sudo systemctl daemon-reload
sudo systemctl enable charbot-backend
sudo systemctl start charbot-backend
```

### 6. Check Status
```bash
sudo systemctl status charbot-backend
sudo journalctl -u charbot-backend -f
```

---

## Firewall Configuration

### OCI Security List
In OCI Console → Networking → Virtual Cloud Networks → Your VCN → Security Lists:

**Ingress Rules:**
| Source CIDR | Protocol | Port Range | Description |
|-------------|----------|------------|-------------|
| 0.0.0.0/0   | TCP      | 22         | SSH         |
| 0.0.0.0/0   | TCP      | 80         | HTTP        |
| 0.0.0.0/0   | TCP      | 443        | HTTPS       |

### UFW (Ubuntu Firewall)
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
sudo ufw status
```

---

## Troubleshooting

### Backend won't start
```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs backend

# Check environment variables
docker-compose -f docker-compose.prod.yml config

# Rebuild
docker-compose -f docker-compose.prod.yml build --no-cache backend
```

### Database connection error
```bash
# Check PostgreSQL is running
docker-compose -f docker-compose.prod.yml ps postgres

# Check connection from backend container
docker-compose -f docker-compose.prod.yml exec backend \
  python -c "from app.db.database import engine; print(engine)"
```

### Nginx 502 Bad Gateway
```bash
# Check backend is running
docker-compose -f docker-compose.prod.yml ps backend

# Check backend health
curl http://localhost:8000/health

# Check nginx config
docker-compose -f docker-compose.prod.yml exec nginx nginx -t
```

### Out of Memory
```bash
# Check memory usage
free -h
docker stats

# Reduce workers in docker-compose.prod.yml:
# --workers 1 (instead of 2)

# Or increase swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### SSL Certificate Issues
```bash
# Check certificate validity
openssl x509 -in nginx/ssl/cert.pem -text -noout

# Test HTTPS
curl -k https://localhost/health

# Renew Let's Encrypt
sudo certbot renew
```

---

## Monitoring

### Simple Uptime Monitor
Add to crontab (`crontab -e`):
```bash
*/5 * * * * curl -sf http://localhost/health || echo "Backend down!" | mail -s "Muse Alert" your@email.com
```

### Disk Space Alert
```bash
# Add to crontab
0 * * * * [ $(df / | tail -1 | awk '{print $5}' | sed 's/%//') -gt 80 ] && echo "Disk usage > 80%" | mail -s "Muse Alert" your@email.com
```

---

## Cost Optimization

Oracle Cloud Free Tier includes:
- 2 VM.Standard.A1.Flex instances (up to 4 OCPU, 24 GB RAM total)
- 200 GB total block volume
- 10 TB outbound data transfer/month

**Muse usage (estimated):**
- Backend: 1 GB RAM, 1 OCPU
- PostgreSQL: 512 MB RAM
- Nginx: 128 MB RAM
- **Total: ~1.6 GB RAM** (well within free tier)

**LLM API costs (estimated):**
- GPT-4o-mini: ~$0.15 per 1M input tokens, $0.60 per 1M output
- Claude Sonnet: ~$3 per 1M input, $15 per 1M output
- **Monthly estimate (2 users, moderate use):** $5-15

---

## Next Steps

1. Deploy backend to Oracle Cloud
2. Configure firewall and SSL
3. Update Flutter app with production URL
4. Build and install APK
5. Test all features end-to-end
6. Set up backups and monitoring

---

## Support

For issues or questions:
- Check logs: `docker-compose -f docker-compose.prod.yml logs -f`
- GitHub Issues: https://github.com/YOUR_USERNAME/charbot/issues
- Email: your@email.com
