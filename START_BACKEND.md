# 🚀 Start Backend with ngrok (Local MongoDB)

This guide helps you run your backend locally and make it accessible from any device.

## 📋 **What You Need:**

1. MongoDB running locally
2. Backend server running
3. ngrok to expose it to the internet

---

## **Step 1: Start MongoDB (if not running)**

```bash
# If you have MongoDB installed locally:
brew services start mongodb-community

# Or start manually:
mongod --config /opt/homebrew/etc/mongod.conf --fork
```

---

## **Step 2: Start Backend Server**

Open a new terminal and run:

```bash
cd /Users/meghal/development/Iqlytika/semasync_new/backend
npm run dev
```

You should see:
```
Server is running on port 3000
MongoDB Connected: localhost
```

---

## **Step 3: Expose Backend with ngrok**

Open ANOTHER terminal and run:

```bash
ngrok http 3000
```

You'll see output like:
```
Forwarding    https://abc123.ngrok.io -> http://localhost:3000
```

**Copy the https URL** (something like `https://abc123.ngrok.io`)

---

## **Step 4: Update Flutter App**

1. Open: `lib/core/api/api_config.dart`

2. Replace the baseUrl with your ngrok URL:
   ```dart
   static String get baseUrl {
     return 'https://abc123.ngrok.io'; // Your ngrok URL
   }
   ```

3. Save and run:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## **✅ Done!**

Your app can now connect to your local backend from any device!

---

## **⚠️ Important Notes:**

1. **ngrok free tier:** URL changes every time you restart ngrok
2. **Keep terminals open:** You need 2 terminals running:
   - Terminal 1: Backend server (`npm run dev`)
   - Terminal 2: ngrok (`ngrok http 3000`)
3. **Update URL:** Every time you restart ngrok, update the URL in `api_config.dart`

---

## **💡 Pro Tip:**

To get a **permanent ngrok URL** (doesn't change):
1. Sign up at https://ngrok.com (free)
2. Get your authtoken
3. Run: `ngrok config add-authtoken YOUR_TOKEN`
4. Run: `ngrok http 3000 --domain=your-static-domain.ngrok.io`

---

## **🆘 Troubleshooting:**

### MongoDB won't start:
```bash
brew services list
brew services restart mongodb-community
```

### Backend won't start:
```bash
cd backend
rm -rf node_modules
npm install
npm run dev
```

### ngrok connection failed:
- Check if port 3000 is in use
- Make sure backend is running first
- Try a different port: `ngrok http 8080`

