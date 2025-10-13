#!/bin/bash

echo "🔐 Generating Secure JWT Secrets for SemaSync Backend"
echo "======================================================"
echo ""
echo "Copy these values to your Railway/Render environment variables:"
echo ""
echo "JWT_SECRET=$(openssl rand -base64 32)"
echo ""
echo "JWT_REFRESH_SECRET=$(openssl rand -base64 32)"
echo ""
echo "✅ Done! Use these values in your deployment platform."

