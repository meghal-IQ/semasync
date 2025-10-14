# 🚀 Quick AWS Setup - Keep APIs Running Forever

## ⚡ TL;DR - What You Need to Do

Your server disconnects when you close the terminal because the process dies with the session. 
**Solution**: Use PM2 process manager to run your server in the background forever.

---

## 📝 Quick Commands for AWS

### On Your AWS EC2 Instance:

```bash
# 1. Connect to AWS
ssh -i your-key.pem ubuntu@your-ec2-ip

# 2. Navigate to your backend
cd ~/semasync/backend

# 3. Pull latest code from GitHub
git pull origin main

# 4. Run the automated setup (ONE COMMAND!)
bash aws_setup.sh
```

**That's it! Your server will now run forever.** 🎉

---

## 🔑 Key PM2 Commands (Your New Best Friends)

```bash
# View all running processes
pm2 status

# View real-time logs
pm2 logs

# Restart server (after code changes)
pm2 restart semasync-backend

# Stop server
pm2 stop semasync-backend

# Start server again
pm2 start semasync-backend

# Monitor CPU/Memory
pm2 monit

# Save current setup (important!)
pm2 save
```

---

## 📋 Complete Setup Checklist

### On GitHub (Already Done ✅):
- [x] Committed production files
- [x] Pushed to GitHub

### On AWS EC2:

1. **Connect to Your EC2 Instance**
   ```bash
   ssh -i /path/to/your-key.pem ubuntu@your-ec2-ip
   ```

2. **First Time Setup** (if not done already):
   ```bash
   # Install Node.js
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # Clone your repo
   cd ~
   git clone https://github.com/meghal-IQ/semasync.git
   cd semasync/backend
   ```

3. **Create .env File**:
   ```bash
   nano .env
   ```
   
   Add your configuration:
   ```
   MONGODB_URI=your-mongodb-connection-string
   NODE_ENV=production
   PORT=5000
   JWT_SECRET=your-secret-key-min-32-chars
   JWT_REFRESH_SECRET=your-refresh-secret-key
   ```

4. **Run Setup Script**:
   ```bash
   bash aws_setup.sh
   ```

5. **Setup Auto-Restart on Server Reboot**:
   - After running `aws_setup.sh`, PM2 will show a command
   - Copy and run that command (it starts with `sudo env PATH=...`)
   - Then run: `pm2 save`

6. **Test Your API**:
   ```bash
   curl http://localhost:5000/health
   ```

7. **Close Terminal and Test**:
   - Exit your SSH session: `exit`
   - From your local machine: `curl http://your-ec2-ip:5000/health`
   - It should still work! 🎉

---

## 🔄 Deploying Updates

Every time you make changes and push to GitHub:

```bash
# On AWS EC2:
cd ~/semasync/backend
git pull origin main
npm install              # Only if dependencies changed
npm run deploy          # This builds and restarts PM2
```

Or use individual commands:
```bash
npm run build
pm2 restart semasync-backend
```

---

## 🔍 Debugging

If something goes wrong:

```bash
# 1. Check if PM2 process is running
pm2 status

# 2. View error logs
pm2 logs semasync-backend --err

# 3. View all logs (last 50 lines)
pm2 logs semasync-backend --lines 50

# 4. Check if port 5000 is in use
sudo lsof -i :5000

# 5. Restart everything
pm2 restart all

# 6. If completely broken, start fresh:
pm2 delete semasync-backend
npm run build
pm2 start ecosystem.config.js
pm2 save
```

---

## 📊 Monitoring

### Check if server is running:
```bash
pm2 status
```

### See resource usage:
```bash
pm2 monit
```

### View logs in real-time:
```bash
pm2 logs semasync-backend
```

---

## 🎯 What Changed?

### Files Added to Your Repo:
1. **`START_PRODUCTION.md`** - Detailed PM2 documentation
2. **`AWS_DEPLOYMENT.md`** - Complete AWS deployment guide
3. **`aws_setup.sh`** - Automated setup script
4. **`ecosystem.config.js`** - PM2 configuration
5. **`package.json`** - Updated with PM2 scripts

### New npm Scripts Available:
```bash
npm run pm2:start     # Start with PM2
npm run pm2:stop      # Stop server
npm run pm2:restart   # Restart server
npm run pm2:logs      # View logs
npm run pm2:monit     # Monitor resources
npm run deploy        # Build and restart
```

---

## ✅ Success Indicators

Your setup is working correctly when:

1. ✅ `pm2 status` shows your app as "online"
2. ✅ `curl http://localhost:5000/health` returns success
3. ✅ You can close the terminal and API still works
4. ✅ Server auto-restarts if it crashes
5. ✅ Server auto-starts when EC2 reboots

---

## 🆘 Need Help?

### Common Issues:

**Issue**: PM2 says "command not found"
```bash
# Solution: Install PM2 globally
npm install -g pm2
```

**Issue**: Server won't start after reboot
```bash
# Solution: Setup startup script
pm2 startup
# Run the command it shows
pm2 save
```

**Issue**: Can't connect to MongoDB
```bash
# Solution: Check your .env file
cat .env | grep MONGODB_URI
# Make sure it's correct
```

**Issue**: Port 5000 already in use
```bash
# Solution: Find and kill the process
sudo lsof -i :5000
kill -9 <PID>
# Then restart PM2
pm2 restart semasync-backend
```

---

## 📚 Documentation Files

- **`QUICK_AWS_SETUP.md`** (this file) - Quick reference
- **`AWS_DEPLOYMENT.md`** - Complete deployment guide
- **`START_PRODUCTION.md`** - PM2 and process management
- **`DEPLOYMENT.md`** - Alternative deployment options

---

## 🎉 Final Steps

1. Pull latest code on AWS: `git pull origin main`
2. Run setup: `bash aws_setup.sh`
3. Setup auto-restart: Copy and run the PM2 startup command
4. Save: `pm2 save`
5. Test: Close terminal and verify API still works
6. Update Flutter app with your EC2 IP or domain

**Your backend will now run forever!** 🚀

---

## 📞 Quick Test

```bash
# From anywhere in the world:
curl http://your-ec2-public-ip:5000/health

# Expected response:
{"status":"OK","timestamp":"2025-10-14T...","uptime":123}
```

If you see this, you're all set! 🎊

