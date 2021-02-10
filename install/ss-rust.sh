#!/usr/bin/env bash

## SS rust模组 SS rust moudle

install_ss_rust(){
	curl -LO https://github.com/shadowsocks/shadowsocks-rust/releases/download/v1.8.23/shadowsocks-v1.8.23.x86_64-unknown-linux-gnu.tar.xz
	tar -xvf shadowsocks*
	cp -f ssserver /usr/sbin
	mkdir /etc/ss-rust
  	cat > '/etc/ss-rust/config.json' << EOF
{
    "server": "::",
    "server_port": 8388,
    "local_port": 1080,
    "local_address": "127.0.0.1",
    "password": "${password1}",
    "timeout": 300,
    "method": "aes-128-gcm"
}
EOF
  cat > '/etc/systemd/system/ssserver.service' << EOF
[Unit]
Description=shadowsocks-rust
Documentation=https://github.com/shadowsocks/shadowsocks-rust
After=network.target

[Service]
User=root
Group=root
RemainAfterExit=yes
ExecStart=/usr/sbin/ssserver -c /etc/ss-rust/config.json
ExecReload=/usr/bin/kill -HUP \$MAINPID
ExecStop=/usr/bin/kill -s STOP \$MAINPID
LimitNOFILE=51200
LimitNPROC=51200
RestartSec=3s
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
systemctl restart ssserver
}