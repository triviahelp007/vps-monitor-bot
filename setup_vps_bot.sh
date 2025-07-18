#!/bin/bash

echo "=============================="
echo " VPS Monitor Bot Setup Script By Debaditya Ghosh"
echo "=============================="

read -p "🔐 Enter your Telegram Bot Token: " BOT_TOKEN
read -p "👤 Enter your Telegram Chat ID: " CHAT_ID

# Install necessary packages
apt update
apt install -y python3 python3-pip git curl

# Clone the repo and move into it
git clone https://github.com/triviahelp007/vps-monitor-bot.git
cd vps-monitor-bot || exit 1

# Replace placeholders in monitor_bot.py.template
sed "s|{{BOT_TOKEN}}|$BOT_TOKEN|g; s|{{CHAT_ID}}|$CHAT_ID|g" monitor_bot.py.template > monitor_bot.py

# Install Python dependencies
pip3 install -r requirements.txt

# Start the bot in background
nohup python3 monitor_bot.py > bot.log 2>&1 &

echo "✅ Bot is running in the background."
echo "ℹ️ Log file: $(pwd)/bot.log"

# Create systemd service
cat <<EOF > /etc/systemd/system/vpsmonitor.service
[Unit]
Description=VPS Monitor Bot
After=network.target

[Service]
ExecStart=/usr/bin/python3 $(pwd)/monitor_bot.py
WorkingDirectory=$(pwd)
Restart=always
User=root

[Install]
WantedBy=multi-user.tar
