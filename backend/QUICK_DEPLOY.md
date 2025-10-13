# 🚀 Quick Deploy Guide (5 Minutes)

## Step 1: Create MongoDB Database (Free - 2 minutes)

1. Go to: https://www.mongodb.com/cloud/atlas/register
2. Sign up with Google (no credit card needed)
3. Create FREE cluster (M0 Sandbox)
4. Click "Create User" - remember username/password
5. Click "Add IP Address" → Click "Allow Access from Anywhere" (0.0.0.0/0)
6. Click "Connect" → "Connect your application"
7. Copy connection string like: `mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/semasync`

**Replace `<password>` with your actual password!**

---

## Step 2: Deploy Backend to Render (Free - 3 minutes)

### Option A: Using GitHub (Recommended)

1. **Push your code to GitHub** (if not already):
   ```bash
   cd /Users/meghal/development/Iqlytika/semasync_new
   git add .
   git commit -m "Ready for deployment"
   git push
   ```

2. **Go to Render.com**:
   - Visit: https://render.com
   - Click "Get Started for Free"
   - Sign up with GitHub

3. **Create Web Service**:
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Select `semasync_new` repository
   - Root Directory: `backend`
   - Name: `semasync-backend` (or any name you like)
   - Environment: `Node`
   - Region: `Oregon (US West)` or closest to you
   - Branch: `main` (or `master`)

4. **Configure Build Settings**:
   - Build Command: `npm install && npm run build`
   - Start Command: `npm start`
   - Instance Type: `Free`

5. **Add Environment Variables** (click "Advanced" → "Add Environment Variable"):
   ```
   NODE_ENV=production
   PORT=5000
   MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/semasync
   JWT_SECRET=super-secret-key-make-it-long-and-random-123456789
   JWT_REFRESH_SECRET=another-super-secret-key-make-it-different-987654321
   JWT_EXPIRE=24h
   JWT_REFRESH_EXPIRE=7d
   ```

6. **Click "Create Web Service"**

7. **Wait 2-3 minutes** - Render will build and deploy your app

8. **Copy your URL** - Something like: `https://semasync-backend.onrender.com`

### Option B: Deploy Without GitHub

If you don't want to use GitHub, you can use Render's manual deployment.

---

## Step 3: Test Your Backend

Open in browser or use curl:

```bash
# Test health endpoint
curl https://your-backend-url.onrender.com/health

# Should return:
# {"success":true,"message":"SemaSync API is running","timestamp":"...","environment":"production"}
```

---

## Step 4: Update Flutter App

1. Open: `lib/core/api/api_config.dart`

2. Update line 9-10:
   ```dart
   // Production backend URL
   return 'https://your-backend-url.onrender.com';
   ```

3. Comment out the development code (lines 13-24):
   ```dart
   /*
   // Development URL (current)
   if (Platform.isAndroid) {
     return 'http://$_computerIp:3000';
   } else if (Platform.isIOS) {
     return 'http://$_computerIp:3000';
   } else {
     return 'http://localhost:3000';
   }
   */
   ```

4. Run your app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## ✅ Done! 

Your app should now connect to your deployed backend from any device with internet!

---

## 🐛 Troubleshooting

### Backend won't start
- Check logs in Render dashboard
- Verify MONGODB_URI is correct
- Make sure MongoDB IP whitelist includes 0.0.0.0/0

### App can't connect
- Test backend URL in browser: `https://your-url.onrender.com/health`
- Check if you updated api_config.dart correctly
- Run `flutter clean && flutter pub get`

### Database connection fails
- Verify MongoDB connection string
- Make sure you replaced `<password>` with actual password
- Check IP whitelist in MongoDB Atlas

---

## 📌 Important Notes

**Render Free Tier Limitations:**
- App sleeps after 15 min of inactivity
- First request after sleep takes ~30 seconds to wake up
- 750 hours/month free (unlimited if you verify email)

**To avoid sleeping:**
- Upgrade to paid tier ($7/month)
- OR use a service like UptimeRobot to ping your API every 14 minutes

---

## 🎯 Your Deployed URLs

After deployment, save these:

- **Backend API**: https://your-backend-url.onrender.com
- **API Docs**: https://your-backend-url.onrender.com/api-docs
- **Health Check**: https://your-backend-url.onrender.com/health
- **MongoDB Atlas**: https://cloud.mongodb.com

---

Need help? Check the logs in Render dashboard or MongoDB Atlas monitoring.

