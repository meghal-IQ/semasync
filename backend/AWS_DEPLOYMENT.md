# AWS Deployment Guide - SemaSync Backend

## 📋 Prerequisites
- AWS Account
- SSH key pair for EC2
- Domain name (optional, but recommended)

---

## 🚀 Step-by-Step Deployment

### Step 1: Launch EC2 Instance

1. **Go to AWS EC2 Dashboard**
   - Navigate to https://console.aws.amazon.com/ec2/

2. **Launch Instance**
   - Click "Launch Instance"
   - **Name**: `semasync-backend`
   - **AMI**: Ubuntu Server 22.04 LTS (Free tier eligible)
   - **Instance type**: t2.micro (Free tier) or t2.small (recommended for production)
   - **Key pair**: Create new or select existing
   - **Network settings**: 
     - Allow SSH (port 22)
     - Allow HTTP (port 80)
     - Allow HTTPS (port 443)
     - Allow Custom TCP (port 5000) - for your backend

3. **Configure Storage**
   - 20 GB gp3 (recommended)

4. **Launch Instance**

### Step 2: Connect to Your EC2 Instance

```bash
# SSH into your instance
ssh -i /path/to/your-key.pem ubuntu@your-ec2-public-ip

# Or use EC2 Instance Connect from AWS Console
```

### Step 3: Install Node.js and npm

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 20.x (LTS)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version

# Install build essentials (needed for some npm packages)
sudo apt-get install -y build-essential
```

### Step 4: Install Git

```bash
sudo apt install git -y
git --version
```

### Step 5: Clone Your Repository

```bash
# Navigate to home directory
cd ~

# Clone your repository
git clone https://github.com/meghal-IQ/semasync.git

# Navigate to backend
cd semasync/backend
```

### Step 6: Setup Environment Variables

```bash
# Create .env file
nano .env
```

**Add the following (replace with your actual values):**

```bash
# Database
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/semasync

# Server
NODE_ENV=production
PORT=5000

# JWT
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters-long
JWT_REFRESH_SECRET=your-super-secret-refresh-key-minimum-32-characters
JWT_EXPIRE=24h
JWT_REFRESH_EXPIRE=7d

# Email (optional)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password

# Frontend URL
CLIENT_URL=https://your-frontend-domain.com

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# Password Reset
PASSWORD_RESET_EXPIRE=3600000
```

**Save and exit**: Press `Ctrl+X`, then `Y`, then `Enter`

### Step 7: Run the Setup Script

```bash
# Make sure you're in the backend directory
cd ~/semasync/backend

# Run the setup script
bash aws_setup.sh
```

**IMPORTANT**: When PM2 shows the startup command, copy and run it!

Example output:
```bash
[PM2] You have to run this command as root. Execute the following command:
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ubuntu --hp /home/ubuntu
```

Copy and paste that command to enable auto-restart on server reboot.

### Step 8: Verify Server is Running

```bash
# Check PM2 status
pm2 status

# View logs
pm2 logs semasync-backend

# Test the API
curl http://localhost:5000/health
```

Expected response:
```json
{"status":"OK","timestamp":"...","uptime":...}
```

### Step 9: Configure Security Group (Firewall)

1. Go to EC2 Dashboard → Security Groups
2. Find your instance's security group
3. Edit Inbound Rules:

   | Type       | Protocol | Port Range | Source    | Description           |
   |------------|----------|------------|-----------|-----------------------|
   | SSH        | TCP      | 22         | My IP     | SSH access            |
   | HTTP       | TCP      | 80         | 0.0.0.0/0 | HTTP traffic          |
   | HTTPS      | TCP      | 443        | 0.0.0.0/0 | HTTPS traffic         |
   | Custom TCP | TCP      | 5000       | 0.0.0.0/0 | Backend API (temporary)|

⚠️ **Security Note**: Don't expose port 5000 directly in production. Use NGINX reverse proxy (see Step 11).

### Step 10: Test External Access

```bash
# From your local machine
curl http://your-ec2-public-ip:5000/health

# Test specific endpoints
curl http://your-ec2-public-ip:5000/api/auth/health
```

### Step 11: Setup NGINX Reverse Proxy (Recommended)

```bash
# Install NGINX
sudo apt install nginx -y

# Create NGINX configuration
sudo nano /etc/nginx/sites-available/semasync
```

**Add this configuration:**

```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

**Enable the configuration:**

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/semasync /etc/nginx/sites-enabled/

# Remove default configuration
sudo rm /etc/nginx/sites-enabled/default

# Test NGINX configuration
sudo nginx -t

# Restart NGINX
sudo systemctl restart nginx

# Enable NGINX to start on boot
sudo systemctl enable nginx
```

### Step 12: Setup SSL with Let's Encrypt (Free HTTPS)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Follow the prompts:
# - Enter your email
# - Agree to terms
# - Choose to redirect HTTP to HTTPS (recommended)

# Auto-renewal is set up automatically, verify with:
sudo certbot renew --dry-run
```

Now your API will be accessible at:
- `https://your-domain.com/health`
- `https://your-domain.com/api/auth/login`

### Step 13: Update Flutter App Configuration

Update your Flutter app's API configuration:

**File**: `lib/core/api/api_config.dart`

```dart
static const String baseUrl = 'https://your-domain.com';
```

Or if not using NGINX:
```dart
static const String baseUrl = 'http://your-ec2-public-ip:5000';
```

---

## 🔄 Updating Your Backend

When you make changes and push to GitHub:

```bash
# SSH into your EC2 instance
ssh -i /path/to/your-key.pem ubuntu@your-ec2-public-ip

# Navigate to backend directory
cd ~/semasync/backend

# Pull latest changes
git pull origin main

# Install any new dependencies
npm install

# Build the project
npm run build

# Restart PM2
pm2 restart semasync-backend

# Or use the deploy script
npm run deploy
```

---

## 📊 Monitoring and Maintenance

### View Logs
```bash
# Real-time logs
pm2 logs semasync-backend

# Last 100 lines
pm2 logs semasync-backend --lines 100

# Only errors
pm2 logs semasync-backend --err
```

### Monitor Performance
```bash
# CPU and Memory usage
pm2 monit

# Process status
pm2 status

# Detailed info
pm2 info semasync-backend
```

### Restart/Stop Server
```bash
# Restart
pm2 restart semasync-backend

# Stop
pm2 stop semasync-backend

# Start again
pm2 start semasync-backend

# Delete from PM2
pm2 delete semasync-backend
```

### System Resources
```bash
# Check disk space
df -h

# Check memory
free -h

# Check CPU
top

# Or use htop (install with: sudo apt install htop)
htop
```

---

## 🔒 Security Best Practices

1. **Keep System Updated**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Use Environment Variables**
   - Never commit `.env` to git
   - Keep secrets secure

3. **Enable Firewall (UFW)**
   ```bash
   sudo ufw enable
   sudo ufw allow OpenSSH
   sudo ufw allow 'Nginx Full'
   sudo ufw status
   ```

4. **Regular Backups**
   - Backup your MongoDB database regularly
   - Use AWS snapshots for EC2 volumes

5. **Monitor Logs**
   - Check PM2 logs regularly: `pm2 logs`
   - Check NGINX logs: `sudo tail -f /var/log/nginx/error.log`

6. **Use Strong Passwords**
   - For MongoDB
   - For JWT secrets
   - For EC2 key pairs

---

## 🐛 Troubleshooting

### Server Not Starting
```bash
# Check PM2 logs
pm2 logs semasync-backend --lines 50

# Check if port 5000 is in use
sudo lsof -i :5000

# Check environment variables
pm2 env 0
```

### MongoDB Connection Issues
```bash
# Verify MONGODB_URI in .env
cat .env | grep MONGODB_URI

# Test MongoDB connection
mongo "your-mongodb-uri"
```

### NGINX Issues
```bash
# Check NGINX status
sudo systemctl status nginx

# View NGINX error logs
sudo tail -f /var/log/nginx/error.log

# Test configuration
sudo nginx -t
```

### PM2 Not Starting on Reboot
```bash
# Re-run startup script
pm2 unstartup
pm2 startup

# Run the command it generates
# Then save
pm2 save
```

### Out of Memory
```bash
# Check memory usage
free -h

# Set memory limit for PM2
pm2 delete semasync-backend
pm2 start ecosystem.config.js --max-memory-restart 400M
pm2 save
```

---

## 📞 Support

If you encounter issues:

1. Check PM2 logs: `pm2 logs`
2. Check NGINX logs: `sudo tail -f /var/log/nginx/error.log`
3. Verify environment variables: `cat .env`
4. Test MongoDB connection
5. Check security group settings in AWS

---

## 🎉 You're Done!

Your backend is now:
- ✅ Running on AWS EC2
- ✅ Will auto-restart if it crashes
- ✅ Will auto-start on server reboot
- ✅ Running forever, even after you close the terminal
- ✅ Accessible via HTTPS (if you set up SSL)
- ✅ Behind NGINX reverse proxy (if configured)

**Your API is accessible at:**
- With NGINX: `https://your-domain.com`
- Without NGINX: `http://your-ec2-public-ip:5000`

**Test it:**
```bash
curl https://your-domain.com/health
```

🚀 Happy coding!

