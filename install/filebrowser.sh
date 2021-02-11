#!/usr/bin/env bash

## Filebrowser模组 Filebrowser moudle

install_filebrowser(){
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Filebrowser中..." 7 68
colorEcho ${INFO} "Install Filebrowser ing"
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
  cat > '/etc/systemd/system/filebrowser.service' << EOF
[Unit]
Description=filebrowser browser
Documentation=https://github.com/filebrowser/filebrowser
After=network.target

[Service]
User=root
Group=root
RemainAfterExit=yes
ExecStart=/usr/local/bin/filebrowser -r /usr/share/nginx/ -d /etc/filebrowser/database.db -b /file/ -p 8081
ExecReload=/usr/bin/kill -HUP \$MAINPID
ExecStop=/usr/bin/kill -s STOP \$MAINPID
LimitNOFILE=51200
LimitNPROC=51200
RestartSec=3s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable filebrowser
systemctl restart filebrowser
mkdir /etc/filebrowser/
touch /etc/filebrowser/database.db
chmod -R 755 /etc/filebrowser/
cd
}