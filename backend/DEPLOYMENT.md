# SemaSync Backend Deployment Guide

## Quick Deployment Options

### Option 1: Railway (Recommended - Free Tier)

1. **Sign up at [railway.app](https://railway.app)**
2. **Connect GitHub repository**
3. **Select backend folder**
4. **Set Environment Variables:**
   ```
   MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/semasync
   NODE_ENV=production
   PORT=5000
   JWT_SECRET=your-super-secret-jwt-key-here
   JWT_REFRESH_SECRET=your-super-secret-refresh-key-here
   JWT_EXPIRE=24h
   JWT_REFRESH_EXPIRE=7d
   ```
5. **Deploy!**

### Option 2: Render (Free Tier)

1. **Sign up at [render.com](https://render.com)**
2. **Create new Web Service**
3. **Connect GitHub repository**
4. **Configure:**
   - Build Command: `npm install && npm run build`
   - Start Command: `npm start`
   - Environment: Node
5. **Add environment variables**
6. **Deploy!**

### Option 3: Heroku

1. **Install Heroku CLI**
2. **Login:** `heroku login`
3. **Create app:** `heroku create semasync-backend`
4. **Add MongoDB:** `heroku addons:create mongolab:sandbox`
5. **Set config vars:** `heroku config:set JWT_SECRET=your-secret`
6. **Deploy:** `git push heroku main`

## Database Setup (MongoDB Atlas)

1. **Go to [mongodb.com/atlas](https://mongodb.com/atlas)**
2. **Create free cluster**
3. **Create database user**
4. **Whitelist IP addresses (0.0.0.0/0 for testing)**
5. **Get connection string**
6. **Update MONGODB_URI in deployment platform**

## Environment Variables Required

```bash
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/semasync
NODE_ENV=production
PORT=5000
JWT_SECRET=your-super-secret-jwt-key-here
JWT_REFRESH_SECRET=your-super-secret-refresh-key-here
JWT_EXPIRE=24h
JWT_REFRESH_EXPIRE=7d
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
CLIENT_URL=https://your-frontend-domain.com
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
PASSWORD_RESET_EXPIRE=3600000
```

## Testing Your Deployment

After deployment, test your API:

```bash
# Health check
curl https://your-backend-url.com/health

# Test endpoints
curl https://your-backend-url.com/api/auth/register
curl https://your-backend-url.com/api/auth/login
```

## Update Flutter App

Update your API configuration in:
`lib/core/api/api_config.dart`

Change the base URL to your deployed backend URL.

## Troubleshooting

- **Build fails:** Check Node.js version (should be 18+)
- **Database connection fails:** Verify MongoDB URI and network access
- **JWT errors:** Ensure JWT_SECRET is set and consistent
- **CORS issues:** Verify CLIENT_URL matches your frontend domain
