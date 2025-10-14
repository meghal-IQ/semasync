# Running SemaSync Backend in Production (AWS)

## Problem
When you close the AWS terminal, your server disconnects and APIs stop working.

## Solution: Use PM2 Process Manager

### 1. Install PM2 globally on your AWS server
```bash
npm install -g pm2
```

### 2. Start your server with PM2
```bash
# Navigate to backend directory
cd /path/to/semasync_new/backend

# Build the project
npm run build

# Start with PM2
pm2 start dist/index.js --name semasync-backend

# Or start with ecosystem file (recommended)
pm2 start ecosystem.config.js
```

### 3. Useful PM2 Commands
```bash
# View running processes
pm2 list

# View logs
pm2 logs semasync-backend

# Monitor CPU/Memory usage
pm2 monit

# Restart the app
pm2 restart semasync-backend

# Stop the app
pm2 stop semasync-backend

# Delete from PM2
pm2 delete semasync-backend

# Save current process list
pm2 save

# Resurrect processes after server reboot
pm2 resurrect
```

### 4. Setup Auto-Restart on Server Reboot
```bash
# Generate startup script
pm2 startup

# Copy and run the command it generates (will look like):
# sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu

# Save the process list so it starts on reboot
pm2 save
```

### 5. Environment Variables with PM2
PM2 can load environment variables from your .env file automatically when using ecosystem.config.js

---

## Alternative Solutions

### Option 2: Using nohup (Simple)
```bash
# Build first
npm run build

# Start with nohup
nohup npm start > server.log 2>&1 &

# View the process ID
echo $!

# View logs
tail -f server.log

# To stop (find process and kill)
ps aux | grep node
kill <PID>
```

### Option 3: Using screen (Terminal Multiplexer)
```bash
# Install screen
sudo apt-get install screen  # Ubuntu/Debian
sudo yum install screen       # Amazon Linux/CentOS

# Start a new screen session
screen -S semasync-backend

# Run your server
npm run build && npm start

# Detach from screen: Press Ctrl+A then D

# Reattach to screen
screen -r semasync-backend

# List all screens
screen -ls

# Kill a screen session
screen -X -S semasync-backend quit
```

### Option 4: Using tmux (Alternative to screen)
```bash
# Install tmux
sudo apt-get install tmux  # Ubuntu/Debian
sudo yum install tmux      # Amazon Linux/CentOS

# Start a new tmux session
tmux new -s semasync-backend

# Run your server
npm run build && npm start

# Detach from tmux: Press Ctrl+B then D

# Reattach to tmux
tmux attach -t semasync-backend

# List all sessions
tmux ls

# Kill a session
tmux kill-session -t semasync-backend
```

---

## Recommended Setup Steps for AWS

1. **Install PM2**
   ```bash
   npm install -g pm2
   ```

2. **Navigate to backend and build**
   ```bash
   cd /path/to/backend
   npm install
   npm run build
   ```

3. **Start with PM2**
   ```bash
   pm2 start ecosystem.config.js
   ```

4. **Setup auto-restart**
   ```bash
   pm2 startup
   # Run the generated command
   pm2 save
   ```

5. **Verify it's running**
   ```bash
   pm2 status
   curl http://localhost:5000/health
   ```

6. **Now you can safely close the terminal!**

---

## Monitoring and Logs

### With PM2:
```bash
# Real-time logs
pm2 logs

# Last 200 lines
pm2 logs --lines 200

# Only errors
pm2 logs --err

# Flush logs
pm2 flush
```

### With nohup:
```bash
tail -f server.log
```

### With screen/tmux:
- Reattach to see live output
- Or redirect output to a log file

---

## Security Tips

1. **Use environment variables** - Never hardcode secrets
2. **Set up firewall rules** - Only allow necessary ports
3. **Use NGINX as reverse proxy** - Better performance and security
4. **Enable HTTPS** - Use Let's Encrypt for free SSL
5. **Regular updates** - Keep Node.js and dependencies updated

---

## Troubleshooting

### Server not starting with PM2?
```bash
# Check logs
pm2 logs semasync-backend --lines 50

# Check if port is already in use
sudo lsof -i :5000
```

### PM2 not restarting after reboot?
```bash
# Re-run startup
pm2 unstartup
pm2 startup
# Run the generated command
pm2 save
```

### Memory issues?
```bash
# Set memory limit
pm2 start dist/index.js --name semasync-backend --max-memory-restart 500M
```

