#!/bin/bash

echo "=============================="
echo " VPS Monitor Bot Setup Script By Debaditya Ghosh"
echo "=============================="

read -p "🔐 Enter your Telegram Bot Token: " BOT_TOKEN
read -p "👤 Enter your Telegram Chat ID: " CHAT_ID

# Install necessary packages
apt update
apt install -y python3 python3-pip git curl

# Clone the repo
REPO_DIR="vps-monitor-bot"
if [ ! -d "$REPO_DIR" ]; then
    git clone https://github.com/triviahelp007/vps-monitor-bot.git "$REPO_DIR"
fi
cd "$REPO_DIR" || exit 1

# Replace template and generate final monitor bot script
sed "s|{{BOT_TOKEN}}|$BOT_TOKEN|g; s|{{CHAT_ID}}|$CHAT_ID|g" monitor_bot.py.template > monitor_bot.py

# Install Python dependencies
pip3 install -r requirements.txt

# Run the bot in background
nohup python3 monitor_bot.py > bot.log 2>&1 &

echo "✅ Bot is running in the background."
echo "ℹ️ Log file: $(pwd)/bot.log"

# Create a systemd service
SERVICE_PATH="/etc/systemd/system/vpsmonitor.service"
cat <<EOF > "$SERVICE_PATH"
[Unit]
Description=VPS Monitor Bot
After=network.target

[Service]
ExecStart=/usr/bin/python3 $(pwd)/monitor_bot.py
WorkingDirectory=$(pwd)
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable vpsmonitor.service
systemctl restart vpsmonitor.service

echo "✅ Systemd service created and started — auto-starts on reboot!"
