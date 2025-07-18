#!/bin/bash

echo "=============================="
echo " VPS Monitor Bot Setup Script By Debaditya Ghosh"
echo "=============================="

# 🔐 Gather Telegram credentials
read -p "🔐 Enter your Telegram Bot Token: " BOT_TOKEN
read -p "👤 Enter your Telegram Chat ID: " CHAT_ID

# 🔧 Install system dependencies
apt update -y
apt install -y python3 python3-venv git curl

# 🗂 Clone the bot code into /opt
rm -rf /opt/vps-monitor-bot
git clone https://github.com/triviahelp007/vps-monitor-bot.git /opt/vps-monitor-bot
cd /opt/vps-monitor-bot || exit 1

# 🛠 Create virtual environment and install dependencies
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 🔄 Replace placeholders and generate final script
sed "s|{{BOT_TOKEN}}|$BOT_TOKEN|g; s|{{CHAT_ID}}|$CHAT_ID|g" monitor_bot.py.template > monitor_bot.py

# 🚀 Launch the bot in background
nohup ./venv/bin/python monitor_bot.py > /opt/vps-monitor-bot/bot.log 2>&1 &

# 🧩 Setup systemd service with virtualenv
cat <<EOF > /etc/systemd/system/vpsmonitor.service
[Unit]
Description=VPS Monitor Bot
After=network.target

[Service]
ExecStart=/opt/vps-monitor-bot/venv/bin/python /opt/vps-monitor-bot/monitor_bot.py
WorkingDirectory=/opt/vps-monitor-bot
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable vpsmonitor.service
systemctl restart vpsmonitor.service

echo "✅ VPS Monitor Bot is installed, running, and set to auto-start."
echo "📄 To view live logs: journalctl -u vpsmonitor.service -f"
