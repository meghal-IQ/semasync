#!/bin/bash

# Push SemaSync to GitHub
# Run this AFTER creating the repository on GitHub

echo "🚀 Pushing SemaSync to GitHub..."

cd /Users/meghal/development/Iqlytika/semasync_new

# Add GitHub remote (replace YOUR_REPO_NAME with actual repository name)
# Example: git remote add origin https://github.com/meghalShah45/semasync.git
git remote add origin https://github.com/meghalShah45/semasync.git

# Push to GitHub
git push -u origin main

echo "✅ Done! Your code is now on GitHub!"
echo "📍 Visit: https://github.com/meghalShah45/semasync"

