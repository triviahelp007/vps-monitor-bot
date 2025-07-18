#!/bin/bash

echo "=============================="
echo " VPS Monitor Bot Setup Script"
echo "=============================="

read -p "🔐 Enter your Telegram Bot Token: " TOKEN
read -p "👤 Enter your Telegram Chat ID: " CHAT_ID

apt update && apt install -y python3 python3-pip git curl

echo "📁 Setting up bot code..."
cd "$(dirname "$0")" || exit 1

# Replace placeholders
sed "s|YOUR_BOT_TOKEN|$TOKEN|g; s|YOUR_CHAT_ID|$CHAT_ID|g" monitor_bot.py.template > monitor_bot.py

# Install Python dependencies
pip3 install --break-system-packages -r requirements.txt

# Run bot in background
nohup python3 monitor_bot.py > bot.log 2>&1 &

echo "✅ Bot is running in the background."
echo "ℹ️ Log file: $(pwd)/bot.log"
