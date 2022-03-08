#!/usr/bin/env bash

## Qbittorrnet-enhanced-version模组 Qbittorrnet-enhanced-version moudle

set +e

install_qbt_e(){
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Qbt加强版中..." 7 68
colorEcho ${INFO} "安装增强版Qbittorrent(Install Qbittorrent ing)"
apt-get install unzip -y
apt-get remove qbittorrent-nox -y
cd
mkdir qbt
cd qbt
qbtver=$(curl --retry 5 -s "https://api.github.com/repos/c0re100/qBittorrent-Enhanced-Edition/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -LO https://github.com/c0re100/qBittorrent-Enhanced-Edition/releases/download/${qbtver}/qbittorrent-enhanced-nox_x86_64-linux-musl_static.zip
unzip -o qb*.zip
rm qb*.zip
cp -f qb* /usr/bin/
chmod +x /usr/bin/qbittorrent-nox
chmod +x /usr/bin/qb*
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
LimitNOFILE=65536
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

cd /usr/share/nginx/qBittorrent/
curl -LO https://github.com/CzBiX/qb-web/releases/download/nightly-20210808/qb-web-nightly-20210808.zip
unzip qb-web-nightly-20210808.zip
rm qb-web-nightly-20210808.zip
mv dist web
cd

qbtcookie=$(curl -i --header 'Referer: http://localhost:8080' --data 'username=admin&password=adminadmin' http://localhost:8080/api/v2/auth/login | grep set-cookie | cut -c13-48)
#curl http://localhost:8080/api/v2/app/version  --cookie "${qbtcookie}"
#curl http://localhost:8080/api/v2/app/preferences  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22preallocate_all%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22add_trackers_enabled%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22announce_to_all_tiers%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22announce_to_all_trackers%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22announce_to_all_trackers%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22limit_utp_rate%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22limit_tcp_overhead%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22limit_lan_peers%22:false%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22enable_os_cache%22:false%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22alternative_webui_enabled%22:false%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22alternative_webui_path%22:%22%2fusr%2fshare%2fnginx%2fqBittorrent%2fweb%2f%22%7D  --cookie "${qbtcookie}"
}
