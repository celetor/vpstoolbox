#!/usr/bin/env bash

## Socat模组 Socat moudle

## 仅用于流量转发

remoteip="1.1.1."
remoteport="8388"
localport="12345"

install_socat(){
	apt-get install -y socat
  cat > '/etc/systemd/system/socat-tcp.service' << EOF
[Unit]
Description=Socat Service
Documentation=https://github.com/c0re100/qBittorrent-Enhanced-Edition
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=ExecStart=/usr/bin/socat -u TCP4-LISTEN:${localport},reuseaddr,fork TCP4:${remoteip}:${remoteport}
TimeoutStopSec=infinity
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
  cat > '/etc/systemd/system/socat-udp.service' << EOF
[Unit]
Description=Socat Service
Documentation=https://github.com/c0re100/qBittorrent-Enhanced-Edition
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
RemainAfterExit=yes
ExecStart=ExecStart=/usr/bin/socat -u UDP4-LISTEN:${localport},reuseaddr,fork UDP4:${remoteip}:${remoteport}
TimeoutStopSec=infinity
LimitNOFILE=51200
LimitNPROC=51200
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl enable socat-tcp
systemctl enable socat-udp
systemctl start socat-tcp
systemctl start socat-udp
systemctl status socat-tcp
systemctl status socat-udp
}

install_socat