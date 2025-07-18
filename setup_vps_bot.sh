#!/bin/bash

echo "=============================="
echo " VPS Monitor Bot Setup Script by Debaditya Ghosh"
echo "=============================="

# 🔐 Get credentials
read -p "🔐 Enter your Telegram Bot Token: " TOKEN
read -p "👤 Enter your Telegram Chat ID: " CHAT_ID

# 📦 Install dependencies
apt update && apt install -y python3 python3-pip git curl

echo "📁 Setting up bot code..."
cd "$(dirname "$0")" || exit 1

# 🛠️ Generate actual bot script with credentials
sed "s|{{BOT_TOKEN}}|$TOKEN|g; s|{{CHAT_ID}}|$CHAT_ID|g" monitor_bot.py.template > monitor_bot.py

echo "📦 Installing Python dependencies..."
pip3 install --break-system-packages -r requirements.txt

# 🚀 Launch initial background run (won’t re-run if systemd is working)
nohup python3 monitor_bot.py > bot.log 2>&1 &

echo "✅ Bot is running in the background."
echo "ℹ️ Log file: $(pwd)/bot.log"

# ⚙️ Setting up systemd service
SERVICE_PATH="/etc/systemd/system/vpsmonitor.service"
cat <<EOF > $SERVICE_PATH
[Unit]
Description=VPS Monitor Bot
After=network.target

[Service]
ExecStart=/usr/bin/python3 $(pwd)/monitor_bot.py
WorkingDirectory=$(pwd)
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "🔧 Enabling and starting systemd service..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable vpsmonitor.service
systemctl restart vpsmonitor.service

echo "✅ Service 'vpsmonitor' is running and will auto-start on reboot!"
echo "📄 Logs: journalctl -u vpsmonitor.service -f"
