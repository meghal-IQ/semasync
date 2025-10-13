#!/bin/bash

echo "🧪 Testing ngrok URL..."

# Test local backend
echo "1. Testing local backend..."
curl -s http://localhost:3000/health | head -1

echo -e "\n2. Testing ngrok URL..."
# Test ngrok URL
curl -H "ngrok-skip-browser-warning: true" -s https://807d27122274.ngrok-free.app/health | head -1

echo -e "\n3. Current ngrok status:"
curl -s http://localhost:4040/api/tunnels | grep -o '"public_url":"[^"]*"'

echo -e "\n✅ If you see JSON responses above, both are working!"
echo -e "📱 In Flutter app, press 'r' for hot reload or 'R' for hot restart"
