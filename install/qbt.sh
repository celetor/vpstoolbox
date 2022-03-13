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

sleep 5s;

cpu_thread_count=$(nproc --all)
io_thread=$((${cpu_thread_count}*4))

qbtcookie=$(curl -s -i --header 'Referer: http://localhost:8080' --data 'username=admin&password=adminadmin' http://localhost:8080/api/v2/auth/login | grep set-cookie | cut -c13-48)
#curl http://localhost:8080/api/v2/app/version  --cookie "${qbtcookie}"
#curl http://localhost:8080/api/v2/app/preferences  --cookie "${qbtcookie}" | jq
## 修改性能设置
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22async_io_threads%22:${io_thread}%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22preallocate_all%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22customize_trackers_list_url%22:%22https:%2f%2ftrackerslist.com%2fall.txt%22%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22auto_update_trackers_enabled%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22enable_multi_connections_from_same_ip%22:true%7D  --cookie "${qbtcookie}"
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
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22max_connec%22:-1%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22max_connec_per_torrent%22:-1%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22web_ui_address%22:%22127.0.0.1%22%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22validate_https_tracker_certificate%22:false%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22peer_tos%22:0%7D  --cookie "${qbtcookie}"
## 设置自动管理以及默认下载位置
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22auto_tmm_enabled%22:true%7D  --cookie "${qbtcookie}"
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22save_path%22:%22%2fusr%2fshare%2fnginx%2fdata%2ftorrents%2f%22%7D  --cookie "${qbtcookie}"
## 新增分类以及下载位置
mkdir /usr/share/nginx/data/
mkdir /usr/share/nginx/data/torrents/
mkdir /usr/share/nginx/data/media/
mkdir /usr/share/nginx/data/torrents/animes/
mkdir /usr/share/nginx/data/media/animes/
curl -X POST -F 'category=animes' -F 'savePath=/usr/share/nginx/data/media/animes/' http://localhost:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
mkdir /usr/share/nginx/data/torrents/music/
mkdir /usr/share/nginx/data/media/music/
curl -X POST -F 'category=music' -F 'savePath=/usr/share/nginx/data/media/music/' http://localhost:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
mkdir /usr/share/nginx/data/torrents/18_plus/
mkdir /usr/share/nginx/data/media/18_plus/
curl -X POST -F 'category=18_plus' -F 'savePath=/usr/share/nginx/data/media/18_plus/' http://localhost:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
mkdir /usr/share/nginx/data/torrents/documentary/
mkdir /usr/share/nginx/data/media/documentary/
curl -X POST -F 'category=documentary' -F 'savePath=/usr/share/nginx/data/media/documentary/' http://localhost:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
mkdir /usr/share/nginx/data/torrents/tv/
mkdir /usr/share/nginx/data/media/tv/
curl -X POST -F 'category=tv' -F 'savePath=/usr/share/nginx/data/media/tv/' http://localhost:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
mkdir /usr/share/nginx/data/torrents/movies/
mkdir /usr/share/nginx/data/media/movies/
curl -X POST -F 'category=movies' -F 'savePath=/usr/share/nginx/data/media/movies/' http://localhost:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
mkdir /usr/share/nginx/data/torrents/others/
mkdir /usr/share/nginx/data/media/others/
curl -X POST -F 'category=others' -F 'savePath=/usr/share/nginx/data/media/others/' http://localhost:8080/api/v2/torrents/createCategory --cookie "${qbtcookie}"
## 修改密码，锁定配置
curl http://localhost:8080/api/v2/app/setPreferences?json=%7B%22web_ui_password%22:%22${password1}%22%7D  --cookie "${qbtcookie}"
}
