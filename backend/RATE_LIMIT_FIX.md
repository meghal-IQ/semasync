# Rate Limiting Configuration Fix

## Problem
Getting "Too many requests from this IP, please try again later." error

## Current Rate Limits
- **General API**: 100 requests per 15 minutes (900,000ms)
- **Auth API**: 50 requests per 15 minutes

## Solutions

### Solution 1: Increase Rate Limits (Recommended)

Update your `.env` file on AWS:

```bash
# Current (too restrictive)
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100

# New (more generous)
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=1000
AUTH_RATE_LIMIT_WINDOW_MS=900000
AUTH_RATE_LIMIT_MAX_REQUESTS=200
```

### Solution 2: Disable Rate Limiting (Development)

If you're testing locally, set:
```bash
NODE_ENV=development
```

Rate limiting is disabled in development mode.

### Solution 3: Reset Rate Limit Counter

The rate limit is per IP address. To reset:
1. Wait 15 minutes, OR
2. Restart your backend server

## Quick Fix Commands

### On AWS Server:
```bash
# 1. Edit .env file
nano .env

# 2. Update these lines:
RATE_LIMIT_MAX_REQUESTS=1000
AUTH_RATE_LIMIT_MAX_REQUESTS=200

# 3. Restart backend
pm2 restart semasync-backend

# 4. Check logs
pm2 logs semasync-backend
```

### For Development (Local):
```bash
# Set environment to development
NODE_ENV=development

# Restart backend
npm run dev
```

## Rate Limit Details

**Current Settings:**
- Window: 15 minutes (900,000ms)
- General API: 100 requests per window
- Auth API: 50 requests per window

**Recommended Settings:**
- Window: 15 minutes (900,000ms) 
- General API: 1000 requests per window
- Auth API: 200 requests per window

## Why This Happens

Rate limiting prevents:
- API abuse
- DDoS attacks
- Resource exhaustion

But can be too restrictive during:
- Development/testing
- Heavy app usage
- Multiple users from same IP

## Environment Variables Reference

```bash
# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000          # 15 minutes in milliseconds
RATE_LIMIT_MAX_REQUESTS=1000         # Max requests per window
AUTH_RATE_LIMIT_WINDOW_MS=900000     # Auth window (same as general)
AUTH_RATE_LIMIT_MAX_REQUESTS=200     # Max auth requests per window

# Environment
NODE_ENV=production                   # Enables rate limiting
# NODE_ENV=development               # Disables rate limiting
```

## Testing the Fix

After updating, test with:
```bash
# Check if rate limiting is working
curl http://your-aws-ip:5000/health

# Should return success without rate limit error
```

## Production Considerations

For production, consider:
- **Higher limits**: 1000+ requests per 15 minutes
- **User-based limiting**: Instead of IP-based
- **Whitelist**: For trusted IPs
- **Monitoring**: Track rate limit hits

## Emergency Fix

If you need immediate access:
```bash
# Temporarily disable rate limiting
NODE_ENV=development

# Restart
pm2 restart semasync-backend
```

Then fix the limits properly and set back to production.

