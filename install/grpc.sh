#!/usr/bin/env bash

## grpc模组 grpc moudle

set +e

install_grpc(){

mkdir /etc/tmp/
cd /etc/tmp/
curl -LO https://github.com/XTLS/Xray-core/releases/download/v1.5.3/Xray-linux-64.zip
unzip Xray-linux-64.zip
rm Xray-linux-64.zip
cp -f xray /usr/bin/xray
chmod +X /usr/bin/xray
cd /root
rm -rf /etc/tmp
mkdir /etc/grpc
cd /etc/grpc
  cat > 'server.json' << "EOF"
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 2002,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "49ec002d-ca69-4325-aea5-dbef18dd6f42"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "/grpc"
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    }
  ]
}
EOF

uuid_new=$(/usr/bin/xray uuid -i "${password1}")
sed -i "s/49ec002d-ca69-4325-aea5-dbef18dd6f42/${uuid_new}/g" server.json
sed -i "s/\/grpc/\/${uuid_new}/g" server.json

  cat > '/etc/systemd/system/grpc.service' << EOF
[Unit]
Description=Vless(Grpc) Service
Wants=network-online.target
After=network-online.target nss-lookup.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/xray -c /etc/grpc/server.json
TimeoutStopSec=infinity
LimitNOFILE=65536
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable grpc.service
systemctl restart grpc.service

cd /root
}
