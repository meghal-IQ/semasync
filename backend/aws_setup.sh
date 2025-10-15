#!/bin/bash

# SemaSync Backend - AWS Production Setup Script
# This script sets up your backend to run forever on AWS

echo "🚀 SemaSync Backend - Production Setup"
echo "======================================="
echo ""

# Check if running on AWS/Linux
if [[ ! -f /etc/os-release ]]; then
    echo "⚠️  Warning: This script is designed for Linux servers (AWS EC2, etc.)"
fi

# Step 1: Install PM2 globally
echo "📦 Step 1: Installing PM2 globally..."
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
    echo "✅ PM2 installed successfully"
else
    echo "✅ PM2 already installed"
fi

# Step 2: Create logs directory
echo ""
echo "📁 Step 2: Creating logs directory..."
mkdir -p logs
echo "✅ Logs directory created"

# Step 3: Install dependencies
echo ""
echo "📦 Step 3: Installing dependencies..."
npm install
echo "✅ Dependencies installed"

# Step 4: Build the project
echo ""
echo "🔨 Step 4: Building the project..."
npm run build
echo "✅ Build completed"

# Step 5: Check if .env exists
echo ""
echo "🔍 Step 5: Checking environment variables..."
if [ ! -f .env ]; then
    echo "⚠️  Warning: .env file not found!"
    echo "Please create a .env file with the required variables."
    echo "You can copy from env.example:"
    echo "  cp env.example .env"
    echo "  nano .env  # Edit with your values"
    echo ""
    read -p "Do you want to continue without .env? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✅ .env file found"
fi

# Step 6: Stop existing PM2 process (if any)
echo ""
echo "🛑 Step 6: Stopping existing PM2 process (if any)..."
pm2 delete semasync-backend 2>/dev/null || echo "No existing process found"

# Step 7: Start with PM2
echo ""
echo "🚀 Step 7: Starting server with PM2..."
pm2 start ecosystem.config.js
echo "✅ Server started with PM2"

# Step 8: Save PM2 process list
echo ""
echo "💾 Step 8: Saving PM2 process list..."
pm2 save
echo "✅ PM2 process list saved"

# Step 9: Setup auto-restart on server reboot
echo ""
echo "🔄 Step 9: Setting up auto-restart on server reboot..."
echo "Running: pm2 startup"
echo ""
echo "⚠️  IMPORTANT: PM2 will generate a command for you."
echo "You MUST copy and run that command to enable auto-restart on reboot!"
echo ""
pm2 startup

echo ""
echo "======================================="
echo "✅ Setup Complete!"
echo "======================================="
echo ""
echo "Your server is now running in the background."
echo "You can safely close this terminal."
echo ""
echo "📊 Useful Commands:"
echo "  npm run pm2:logs     - View logs"
echo "  npm run pm2:monit    - Monitor CPU/Memory"
echo "  pm2 status           - Check status"
echo "  pm2 restart all      - Restart server"
echo "  pm2 stop all         - Stop server"
echo ""
echo "🔗 Test your API:"
echo "  curl http://localhost:5000/health"
echo ""
echo "📚 For more info, see: START_PRODUCTION.md"
echo ""

