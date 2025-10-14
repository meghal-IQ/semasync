# Fix Git Conflict on AWS

## Problem
```
error: Your local changes to the following files would be overwritten by merge:
        backend/package.json
Please commit your changes or stash them before you merge.
```

## Solution - Choose One:

### Option 1: Stash Changes and Pull (Recommended)

This saves your local changes temporarily, pulls the latest code, then you can decide what to do:

```bash
# Save your local changes temporarily
git stash

# Pull latest code from GitHub
git pull origin main

# See what was stashed (optional)
git stash show -p

# If you need those changes back:
git stash pop

# Or if you don't need them:
git stash drop
```

### Option 2: Overwrite Local Changes (If local changes aren't important)

This discards your local changes and uses the GitHub version:

```bash
# Discard local changes to package.json
git checkout -- backend/package.json

# Now pull
git pull origin main
```

### Option 3: Commit Local Changes First

If your local changes are important:

```bash
# See what changed locally
git diff backend/package.json

# Commit the local changes
git add backend/package.json
git commit -m "Local package.json changes"

# Pull and merge
git pull origin main

# If there's a conflict, resolve it manually
```

### Option 4: Hard Reset (Nuclear Option - USE WITH CAUTION)

This completely discards ALL local changes:

```bash
# ⚠️ WARNING: This will delete ALL local changes!
git reset --hard HEAD

# Pull latest
git pull origin main
```

## Recommended Steps for Your Situation:

Since we just pushed updated `package.json` with PM2 scripts from your local machine:

```bash
# 1. See what's different locally on AWS
git diff backend/package.json

# 2. Stash the local changes
git stash

# 3. Pull the latest (has PM2 scripts)
git pull origin main

# 4. Verify package.json has PM2 scripts
cat package.json | grep pm2

# 5. Continue with setup
bash aws_setup.sh
```

## Quick Fix (One-liner):

```bash
git stash && git pull origin main && bash aws_setup.sh
```

This will:
1. Save your local changes
2. Pull latest code with PM2 setup
3. Run the automated setup

---

## Understanding the Issue

This happened because:
- We updated `package.json` on your local machine (added PM2 scripts)
- Pushed it to GitHub
- Your AWS server had a different version of `package.json`
- Git won't let you pull because it would overwrite your local changes

The stash command safely saves your changes so you can pull the updates.

