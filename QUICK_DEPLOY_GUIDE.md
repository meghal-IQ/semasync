# 🚀 Quick Deploy Guide - SemaSync Backend

## Step 1: MongoDB Database Setup (5 minutes)

1. **Go to:** https://www.mongodb.com/cloud/atlas/register
2. **Create a FREE account**
3. **Create a FREE cluster:**
   - Click "Build a Database"
   - Choose "FREE" (M0 Sandbox)
   - Choose any cloud provider and region
   - Click "Create Cluster"

4. **Create Database User:**
   - Go to "Database Access" in left menu
   - Click "Add New Database User"
   - Username: `semasync_admin`
   - Password: Generate a secure password (SAVE THIS!)
   - Database User Privileges: "Read and write to any database"
   - Click "Add User"

5. **Allow Network Access:**
   - Go to "Network Access" in left menu
   - Click "Add IP Address"
   - Click "Allow Access from Anywhere" (0.0.0.0/0)
   - Click "Confirm"

6. **Get Connection String:**
   - Go to "Database" in left menu
   - Click "Connect" button on your cluster
   - Choose "Connect your application"
   - Copy the connection string (looks like: `mongodb+srv://semasync_admin:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority`)
   - Replace `<password>` with your actual password
   - SAVE THIS CONNECTION STRING!

---

## Step 2: Deploy to Railway (10 minutes)

1. **Go to:** https://railway.app
2. **Sign up with GitHub** (this is important!)
3. **Click "New Project"**
4. **Select "Deploy from GitHub repo"**
5. **Select your repository:** `meghal-IQ/semasync`
6. **Configure the service:**
   - Railway might ask you to select a service
   - Click "Add variables" or go to "Variables" tab

7. **Add Environment Variables:**
   Click "Add Variable" and add each of these:

   ```
   MONGODB_URI=mongodb+srv://semasync_admin:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/semasync?retryWrites=true&w=majority
   NODE_ENV=production
   PORT=5000
   JWT_SECRET=your-super-secret-jwt-key-min-32-chars-long
   JWT_REFRESH_SECRET=your-super-secret-refresh-key-min-32-chars-long
   JWT_EXPIRE=24h
   JWT_REFRESH_EXPIRE=7d
   RATE_LIMIT_WINDOW_MS=900000
   RATE_LIMIT_MAX_REQUESTS=100
   PASSWORD_RESET_EXPIRE=3600000
   CLIENT_URL=*
   ```

   **For JWT secrets, use strong random strings. You can generate them with:**
   ```bash
   openssl rand -base64 32
   ```

8. **Set Root Directory:**
   - Go to "Settings" tab
   - Find "Root Directory"
   - Set to: `backend`
   - Click "Update"

9. **Deploy:**
   - Railway will automatically deploy!
   - Wait for build to complete (2-3 minutes)
   - You'll see a green checkmark when ready

10. **Get your API URL:**
    - Go to "Settings" tab
    - Click "Generate Domain" under "Networking"
    - Your API will be accessible at: `https://your-app-name.up.railway.app`

---

## Step 3: Test Your API

Once deployed, test it:

```bash
# Replace with your actual Railway URL
curl https://your-app-name.up.railway.app/health

# You should see:
# {"status":"ok","timestamp":"...","uptime":"...","database":"connected"}
```

---

## Step 4: Update Flutter App

Update your Flutter app to use the deployed API:

1. **Open:** `lib/core/api/api_config.dart`
2. **Change the baseUrl to your Railway URL:**
   ```dart
   static const String baseUrl = 'https://your-app-name.up.railway.app';
   ```
3. **Save and restart your app!**

---

## 🎉 Done! Your APIs are now live!

### Available Endpoints:

- Health Check: `GET /health`
- Register: `POST /api/auth/register`
- Login: `POST /api/auth/login`
- Get Profile: `GET /api/users/profile`
- Log Food: `POST /api/logs/food`
- Get Logs: `GET /api/logs`
- And many more!

---

## Alternative: Deploy to Render

If you prefer Render instead:

1. **Go to:** https://render.com
2. **Sign up with GitHub**
3. **Click "New +" → "Web Service"**
4. **Connect your GitHub repo:** `meghal-IQ/semasync`
5. **Configure:**
   - Name: `semasync-backend`
   - Root Directory: `backend`
   - Environment: `Node`
   - Build Command: `npm install && npm run build`
   - Start Command: `npm start`
6. **Add same environment variables as above**
7. **Click "Create Web Service"**

---

## Need Help?

If you encounter any issues:
- Check the deployment logs in Railway/Render dashboard
- Verify MongoDB connection string is correct
- Ensure all environment variables are set
- Check that backend folder structure is correct

Your backend is now running 24/7 and accessible from anywhere! 🚀

