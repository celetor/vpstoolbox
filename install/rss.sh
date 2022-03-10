#!/usr/bin/env bash

## RSS模组 RSS moudle

install_rss(){
set +e
cd /usr/share/nginx/
if [[ -d /usr/share/nginx/RSSHub ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新rsshub中..." 7 68
    cd /usr/share/nginx/RSSHub
    git pull
    npm update
    npm ci --production
    npm prune
    npm audit fix
  else
    git clone https://github.com/DIYgod/RSSHub.git
    cd /usr/share/nginx/RSSHub
    npm update
    npm ci --production
    npm prune
    npm audit fix
    touch .env
cat > '.env' << EOF
CACHE_TYPE=redis
REDIS_URL=redis://127.0.0.1:6379/
#REDIS_URL=/var/run/redis/redis.sock
CACHE_EXPIRE=600
LISTEN_INADDR_ANY=0
EOF

cat > '/etc/systemd/system/rsshub.service' << EOF
[Unit]
Description=Rsshub
Documentation=https://docs.rsshub.app/
After=network.target
Wants=network.target

[Service]
Type=simple
WorkingDirectory=/usr/share/nginx/RSSHub
ExecStart=/bin/bash -c 'npm start'
Restart=on-failure
LimitNOFILE=65536
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF
systemctl enable rsshub
systemctl restart rsshub
fi

## Install Miniflux

cd /usr/share/nginx/
mkdir miniflux
cd /usr/share/nginx/miniflux
cat > "/usr/share/nginx/miniflux/docker-compose.yml" << EOF
version: '3.4'
services:
  miniflux:
    image: miniflux/miniflux:latest
    restart: unless-stopped
    ports:
      - "8280:8080"
    depends_on:
      - db
    environment:
      - DATABASE_URL=postgres://miniflux:secret@db/miniflux?sslmode=disable
      - BASE_URL=https://${domain}/miniflux/
      - RUN_MIGRATIONS=1
      - CREATE_ADMIN=1
      - ADMIN_USERNAME=admin
      - ADMIN_PASSWORD=test123
  db:
    image: postgres:latest
    restart: unless-stopped
    environment:
      - POSTGRES_USER=miniflux
      - POSTGRES_PASSWORD=secret
    volumes:
      - miniflux-db:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "miniflux"]
      interval: 10s
      start_period: 30s
volumes:
  miniflux-db:
EOF
sed -i "s/test123/${password1}/g" docker-compose.yml
docker-compose up -d
cd
}

