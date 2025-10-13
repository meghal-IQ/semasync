# 🚀 Deploy Your SemaSync Backend (Complete Guide)

## You Have 2 Options:

### ✅ **Option 1: Deploy with GitHub (Recommended)**
### ✅ **Option 2: Deploy without GitHub (Manual)**

---

## 📋 **OPTION 1: Deploy with GitHub**

### Step 1: Create GitHub Account & Repository

1. **Create GitHub account** (if you don't have one):
   - Go to: https://github.com/signup
   - Sign up (free, no credit card)

2. **Create new repository**:
   - Go to: https://github.com/new
   - Repository name: `semasync`
   - Make it **Private** (recommended)
   - Don't initialize with README
   - Click "Create repository"

### Step 2: Push Your Code to GitHub

Open Terminal and run these commands:

```bash
# Navigate to your project
cd /Users/meghal/development/Iqlytika/semasync_new

# Initialize git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit - SemaSync app"

# Add your GitHub repository (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/semasync.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 3: Deploy to Render

1. **Go to Render**: https://render.com
2. **Sign up with GitHub** (click "Get Started for Free" → "Sign in with GitHub")
3. **Authorize Render** to access your repositories
4. **Create Web Service**:
   - Click "New +" → "Web Service"
   - Find your `semasync` repository
   - Click "Connect"
5. **Configure**:
   - Name: `semasync-backend`
   - Root Directory: `backend`
   - Environment: `Node`
   - Build Command: `npm install && npm run build`
   - Start Command: `npm start`
   - Instance Type: `Free`
6. **Add Environment Variables** (see below)
7. **Click "Create Web Service"**

---

## 📋 **OPTION 2: Deploy without GitHub (Manual)**

### Alternative A: Use Render CLI

1. **Install Render CLI**:
   ```bash
   npm install -g render
   ```

2. **Login to Render**:
   ```bash
   render login
   ```

3. **Deploy**:
   ```bash
   cd /Users/meghal/development/Iqlytika/semasync_new/backend
   render deploy
   ```

### Alternative B: Use Cyclic.sh (Even Easier!)

1. **Go to**: https://www.cyclic.sh
2. **Sign up** (free, no credit card)
3. **Click "Deploy" → "From Local Directory"**
4. **Drag & drop your `backend` folder**
5. **Add environment variables**
6. **Deploy!**

---

## 🗄️ **MongoDB Setup (Required for All Options)**

1. **Go to**: https://www.mongodb.com/cloud/atlas/register
2. **Sign up with Google** (free, no credit card)
3. **Create FREE cluster**:
   - Click "Build a Database"
   - Choose "FREE" (M0 Sandbox)
   - Provider: AWS
   - Region: Closest to you
   - Click "Create"
4. **Create Database User**:
   - Username: `semasync`
   - Password: Click "Autogenerate Secure Password" (save this!)
   - Click "Create User"
5. **Add IP Whitelist**:
   - Click "Add IP Address"
   - Click "Allow Access from Anywhere" (0.0.0.0/0)
   - Click "Confirm"
6. **Get Connection String**:
   - Click "Connect"
   - Choose "Connect your application"
   - Copy the connection string
   - Replace `<password>` with your password
   - Should look like: `mongodb+srv://semasync:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/semasync`

---

## 🔐 **Environment Variables (Copy These)**

Add these in Render dashboard (or your chosen platform):

```
NODE_ENV=production
PORT=5000
MONGODB_URI=mongodb+srv://semasync:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/semasync
JWT_SECRET=9k2mP8xL4qR7vT5nW3jY6uH1sF0gD2bN8mK5pX7wQ9zA4cV1eT3rY6hU8jI0oL2m
JWT_REFRESH_SECRET=3xZ7bN1mK9qP4wR6tY2uI5oL8sF0vC3eH6jG9nM2kX7aD4pQ1rT8yW5hU0zV6iB3
JWT_EXPIRE=24h
JWT_REFRESH_EXPIRE=7d
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
PASSWORD_RESET_EXPIRE=3600000
```

**Important**: Replace `YOUR_PASSWORD` in MONGODB_URI with your actual MongoDB password!

---

## 🧪 **Test Your Deployment**

After deployment, you'll get a URL like: `https://semasync-backend.onrender.com`

Test it:

```bash
# Test health endpoint
curl https://semasync-backend.onrender.com/health

# Should return:
{"success":true,"message":"SemaSync API is running"...}
```

Or just open it in your browser!

---

## 📱 **Update Flutter App**

After your backend is deployed:

1. **Open**: `lib/core/api/api_config.dart`

2. **Update the baseUrl** to return your deployed URL:
   ```dart
   static String get baseUrl {
     // Production backend URL
     return 'https://semasync-backend.onrender.com';  // ← Your URL here
   }
   ```

3. **Save and run**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## ✅ **You're Done!**

Now your app can connect to the backend from any device with internet!

---

## ⏱️ **Time Estimate**
- MongoDB setup: 3 minutes
- GitHub setup (if needed): 5 minutes
- Render deployment: 3 minutes
- **Total: ~11 minutes**

---

## 🆘 **Need Help?**

Check the detailed guide: `backend/QUICK_DEPLOY.md`

Or these resources:
- Render Docs: https://render.com/docs/web-services
- MongoDB Docs: https://www.mongodb.com/docs/atlas/
- GitHub Docs: https://docs.github.com/en/get-started

