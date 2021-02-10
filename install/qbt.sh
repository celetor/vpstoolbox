#!/usr/bin/env bash

## Qbittorrnet-enhanced-version模组 Qbittorrnet-enhanced-version moudle

clear
TERM=ansi whiptail --title "安装中" --infobox "安装Qbt加强版中..." 7 68
colorEcho ${INFO} "安装增强版Qbittorrent(Install Qbittorrent ing)"
apt-get remove qbittorrent-nox -y
cd
mkdir qbt
cd qbt
qbtver=$(curl -s "https://api.github.com/repos/c0re100/qBittorrent-Enhanced-Edition/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
wget https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/${qbtver}/qbittorrent-nox_x86_64-linux-musl_static.zip
unzip -o qbittorrent*.zip
cp -f qbittorrent-nox /usr/bin/
chmod +x /usr/bin/qbittorrent-nox
cd
rm -rf qbt
  cat > '/etc/systemd/system/qbittorrent.service' << EOF
[Unit]
Description=qBittorrent Daemon Service
Documentation=https://github.com/c0re100/qBittorrent-Enhanced-Edition
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=/usr/bin/qbittorrent-nox --profile=/usr/share/nginx/
TimeoutStopSec=infinity
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable qbittorrent.service
mkdir /usr/share/nginx/qBittorrent/
mkdir /usr/share/nginx/qBittorrent/downloads/
mkdir /usr/share/nginx/qBittorrent/data/
mkdir /usr/share/nginx/qBittorrent/data/GeoIP/
cd /usr/share/nginx/qBittorrent/data/GeoIP/
curl -LO --progress-bar https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/binary/GeoLite2-Country.mmdb
cd
chmod 755 /usr/share/nginx/
chown -R nginx:nginx /usr/share/nginx/
systemctl restart qbittorrent.service
