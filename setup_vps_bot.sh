#!/bin/bash

echo "=============================="
echo " VPS Monitor Bot Setup Script By Debaditya Ghosh"
echo "=============================="

# User inputs
read -p "🔐 Enter your Telegram Bot Token: " BOT_TOKEN
read -p "👤 Enter your Telegram Chat ID: " CHAT_ID

# Install dependencies
apt update -y
apt install -y python3 python3-pip git curl

# Clone bot repo
echo "📁 Cloning bot code..."
git clone https://github.com/triviahelp007/vps-monitor-bot.git /opt/vps-monitor-bot
cd /opt/vps-monitor-bot || exit 1

# Install Python packages
pip3 install -r requirements.txt

# Inject credentials
sed "s|{{BOT_TOKEN}}|$BOT_TOKEN|g; s|{{CHAT_ID}}|$CHAT_ID|g" monitor_bot.py.template > monitor_bot.py

# Start bot
nohup python3 monitor_bot.py > bot.log 2>&1 &
echo "✅ Bot is running in the background."
echo "ℹ️ Log file: /opt/vps-monitor-bot/bot.log"

# Setup systemd service
cat <<EOF > /etc/systemd/system/vpsmonitor.service
[Unit]
Description=VPS Monitor Bot
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/vps-monitor-bot/monitor_bot.py
WorkingDirector
