# 🚀 SemaSync Backend Setup - DO THIS NOW

I've opened 3 tabs in your browser. Follow these steps in order:

---

## ✅ STEP 1: Create GitHub Repository (2 minutes)

**Tab 1: GitHub** (https://github.com/new)

1. **If not logged in:** Sign up with your email (free)
2. **Repository name:** `semasync`
3. **Description:** `SemaSync - Health tracking app for GLP-1 medication management`
4. **Visibility:** Choose **Private** (recommended) or Public
5. **DON'T** check any boxes (no README, no .gitignore, no license)
6. **Click:** "Create repository"

7. **After creation, you'll see commands.** Copy the one that looks like:
   ```
   git remote add origin https://github.com/YOUR_USERNAME/semasync.git
   ```

8. **Run this in Terminal:**
   ```bash
   cd /Users/meghal/development/Iqlytika/semasync_new
   git remote add origin https://github.com/YOUR_USERNAME/semasync.git
   git push -u origin main
   ```
   *(Replace YOUR_USERNAME with your actual GitHub username)*

---

## ✅ STEP 2: Create MongoDB Database (3 minutes)

**Tab 2: MongoDB Atlas** (https://www.mongodb.com/cloud/atlas/register)

1. **Sign up:** Click "Sign up with Google" (easiest)
2. **Goal:** Select "Learn MongoDB" or "Build a new application"
3. **Click:** "Continue"

### Create Database:
4. **Click:** "Build a Database"
5. **Choose:** **M0 FREE** (should be pre-selected)
6. **Provider:** AWS (default is fine)
7. **Region:** Choose closest to you (e.g., US East, Oregon, etc.)
8. **Cluster Name:** Leave as "Cluster0" or name it "semasync"
9. **Click:** "Create"

### Security Setup:
10. **Username:** `semasync`
11. **Password:** Click "Autogenerate Secure Password"
12. **⚠️ IMPORTANT:** Click "Copy" and **save this password somewhere safe!**
13. **Click:** "Create User"

### Network Access:
14. **Click:** "Add IP Address"
15. **Click:** "ALLOW ACCESS FROM ANYWHERE" (adds 0.0.0.0/0)
16. **Click:** "Confirm"

### Get Connection String:
17. **Click:** "Finish and Close"
18. **Click:** "Connect"
19. **Choose:** "Drivers"
20. **Driver:** Node.js
21. **Copy** the connection string (looks like):
    ```
    mongodb+srv://semasync:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
    ```
22. **Replace** `<password>` with the password you saved
23. **Change** `/?retryWrites` to `/semasync?retryWrites`

**Final connection string should look like:**
```
mongodb+srv://semasync:YOUR_ACTUAL_PASSWORD@cluster0.xxxxx.mongodb.net/semasync?retryWrites=true&w=majority
```

**SAVE THIS - you'll need it in Step 3!**

---

## ✅ STEP 3: Deploy to Render (5 minutes)

**Tab 3: Render** (https://render.com)

### Sign Up:
1. **Click:** "Get Started for Free"
2. **Click:** "Sign in with GitHub"
3. **Authorize** Render to access your GitHub

### Create Web Service:
4. **Click:** "New +" (top right)
5. **Choose:** "Web Service"
6. **Find** your `semasync` repository
7. **Click:** "Connect"

### Configure:
8. **Name:** `semasync-backend` (or any name you like)
9. **Root Directory:** `backend`
10. **Environment:** `Node`
11. **Region:** Oregon (US West) or closest to you
12. **Branch:** `main`
13. **Build Command:** `npm install && npm run build`
14. **Start Command:** `npm start`
15. **Instance Type:** `Free`

### Environment Variables:
16. **Click:** "Advanced"
17. **Click:** "Add Environment Variable" for each:

```
Key: NODE_ENV
Value: production

Key: PORT
Value: 5000

Key: MONGODB_URI
Value: [PASTE YOUR MONGODB CONNECTION STRING FROM STEP 2]

Key: JWT_SECRET
Value: 9k2mP8xL4qR7vT5nW3jY6uH1sF0gD2bN8mK5pX7wQ9zA4cV1eT3rY6hU8jI0oL2m

Key: JWT_REFRESH_SECRET
Value: 3xZ7bN1mK9qP4wR6tY2uI5oL8sF0vC3eH6jG9nM2kX7aD4pQ1rT8yW5hU0zV6iB3

Key: JWT_EXPIRE
Value: 24h

Key: JWT_REFRESH_EXPIRE
Value: 7d

Key: RATE_LIMIT_WINDOW_MS
Value: 900000

Key: RATE_LIMIT_MAX_REQUESTS
Value: 100

Key: PASSWORD_RESET_EXPIRE
Value: 3600000
```

18. **Click:** "Create Web Service"

### Wait for Deploy:
19. **Wait 2-3 minutes** - You'll see a build log
20. **When done**, you'll see "Live" with a green dot
21. **Copy your URL** - Something like: `https://semasync-backend.onrender.com`

### Test It:
22. **Click on the URL** and add `/health` at the end
23. **You should see:**
    ```json
    {"success":true,"message":"SemaSync API is running","timestamp":"...","environment":"production"}
    ```

**SAVE YOUR BACKEND URL!**

---

## ✅ STEP 4: Update Flutter App (1 minute)

**In your code editor:**

1. **Open:** `lib/core/api/api_config.dart`

2. **Find lines 9-25** and replace with:
   ```dart
   static String get baseUrl {
     // Production backend URL
     return 'https://semasync-backend.onrender.com'; // ← PASTE YOUR RENDER URL HERE
   }
   ```

3. **Save the file**

4. **Run in Terminal:**
   ```bash
   cd /Users/meghal/development/Iqlytika/semasync_new
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 🎉 YOU'RE DONE!

Your app now connects to a live backend that works from any device with internet!

---

## 📝 Save These URLs:

- **Backend API:** https://semasync-backend.onrender.com
- **Health Check:** https://semasync-backend.onrender.com/health
- **API Docs:** https://semasync-backend.onrender.com/api-docs
- **GitHub Repo:** https://github.com/YOUR_USERNAME/semasync
- **MongoDB Atlas:** https://cloud.mongodb.com

---

## ⚠️ Important Notes:

1. **Render Free Tier:** App sleeps after 15 min of inactivity
   - First request after sleep takes ~30 seconds
   - This is normal for free tier!

2. **MongoDB Free Tier:** 512MB storage (plenty for testing)

3. **GitHub:** Your code is now backed up in the cloud

---

## 🆘 Troubleshooting:

### Backend won't deploy:
- Check build logs in Render dashboard
- Verify all environment variables are set

### Database connection fails:
- Verify MongoDB connection string in Render env vars
- Check that IP whitelist includes 0.0.0.0/0
- Make sure you replaced <password> with actual password

### App can't connect:
- Test backend URL in browser: add /health
- Verify you updated api_config.dart with correct URL
- Run flutter clean && flutter pub get

---

## 📞 Need Help?

If you get stuck:
1. Check the build logs in Render dashboard
2. Check MongoDB connection in Atlas dashboard
3. Test backend URL directly in browser

**READY? START WITH STEP 1! 🚀**

