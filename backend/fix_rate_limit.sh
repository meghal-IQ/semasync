#!/bin/bash

# Quick Rate Limit Fix Script
# This script increases rate limits to prevent "Too many requests" errors

echo "🔧 Fixing Rate Limiting Issue..."
echo "================================="

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "Please create .env file first:"
    echo "  cp env.example .env"
    echo "  nano .env"
    exit 1
fi

echo "📝 Current rate limit settings:"
grep -E "RATE_LIMIT|NODE_ENV" .env || echo "No rate limit settings found"

echo ""
echo "🔧 Updating rate limits..."

# Backup current .env
cp .env .env.backup
echo "✅ Backed up .env to .env.backup"

# Update rate limits
sed -i 's/RATE_LIMIT_MAX_REQUESTS=.*/RATE_LIMIT_MAX_REQUESTS=1000/' .env
sed -i 's/AUTH_RATE_LIMIT_MAX_REQUESTS=.*/AUTH_RATE_LIMIT_MAX_REQUESTS=200/' .env

# Add rate limit settings if they don't exist
if ! grep -q "RATE_LIMIT_MAX_REQUESTS" .env; then
    echo "RATE_LIMIT_MAX_REQUESTS=1000" >> .env
fi

if ! grep -q "AUTH_RATE_LIMIT_MAX_REQUESTS" .env; then
    echo "AUTH_RATE_LIMIT_MAX_REQUESTS=200" >> .env
fi

echo "✅ Updated rate limits:"
echo "  - General API: 1000 requests per 15 minutes"
echo "  - Auth API: 200 requests per 15 minutes"

echo ""
echo "🔄 Restarting backend..."

# Check if PM2 is running
if command -v pm2 &> /dev/null; then
    echo "Using PM2 to restart..."
    pm2 restart semasync-backend
    echo "✅ Backend restarted with PM2"
    
    echo ""
    echo "📊 Checking status..."
    pm2 status
    
    echo ""
    echo "📝 Recent logs:"
    pm2 logs semasync-backend --lines 10
else
    echo "PM2 not found. Please restart your backend manually:"
    echo "  npm run build"
    echo "  npm start"
fi

echo ""
echo "✅ Rate limit fix complete!"
echo ""
echo "📋 New settings:"
echo "  - General API: 1000 requests per 15 minutes"
echo "  - Auth API: 200 requests per 15 minutes"
echo "  - Window: 15 minutes"
echo ""
echo "🧪 Test your API:"
echo "  curl http://localhost:5000/health"
echo ""
echo "📚 For more info, see: RATE_LIMIT_FIX.md"

