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

# Clone bot repo to /opt
echo "📁 Cloning bot code..."
rm -rf /opt/vps-monitor-bot
git clone https://github.com/triviahelp007/vps-monitor-bot.git /opt/vps-monitor-bot
cd /opt/vps-monitor-bot || { echo "❌ Failed to enter repo directory"; exit 1; }

# Install Python requirements
pip3 install -r requirements.txt

# Replace template vars
sed "s|{{BOT_TOKEN}}|$BOT_TOKEN|g; s|{{CHAT_ID}}|$CHAT_ID|g" monitor_bot.py.template > monitor_bot.py

# Run bot in background
nohup python3 monitor_bot.py > /opt/vps-monitor-bot/bot.log 2>&1 &
echo "✅ Bot is running in the background."
echo "ℹ️ Log file: /opt/vps-monitor-bot/bot.log"

# Create systemd service
cat <<EOF > /etc/systemd/system/vpsmonitor.service
[Unit]
Description=VPS Monitor Bot
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/vps-monitor-bot/monitor_bot.py
WorkingDirectory=/opt/vps-monitor-bot
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable vpsmonitor.service
systemctl start vpsmonitor.service

echo "✅ Systemd service created and started — auto-starts on reboot!"
