#!/usr/bin/env bash

## RSS模组 RSS moudle

install_rss(){
set +e
cd /usr/share/nginx/
apt-get install php7.4-mysql -y
apt-get install php7.4-pgsql -y
apt-get install php7.4-sqlite -y
if [[ -d /usr/share/nginx/RSSHub ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新rsshub中..." 7 68
    cd /usr/share/nginx/RSSHub
    git pull
    npm update
    npm install --production
    npm prune
  else
    git clone https://github.com/DIYgod/RSSHub.git
    cd /usr/share/nginx/RSSHub
    npm update
    npm install --production
    npm prune
    touch .env
cat > '.env' << EOF
CACHE_TYPE=redis
#REDIS_URL=redis://127.0.0.1:6379/
REDIS_URL=/var/run/redis/redis.sock
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

cd /usr/share/nginx/
if [[ -d /usr/share/nginx/tt-rss/ ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新tt-rss中..." 7 68
    cd /usr/share/nginx/tt-rss/
    git pull
  else
    TERM=ansi whiptail --title "安装中" --infobox "安装tt-rss中..." 7 68
    git clone https://git.tt-rss.org/fox/tt-rss.git tt-rss
    mysql -u root -e "CREATE DATABASE ttrss CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -u root -e "create user 'ttrss'@'localhost' IDENTIFIED BY '${password1}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON ttrss.* to ttrss@'localhost';"
    mysql -u root -e "flush privileges;"
    mysql -u ttrss -p"${password1}" -D ttrss < /usr/share/nginx/tt-rss/sql/mysql/schema.sql
  cat > '/usr/share/nginx/tt-rss/config.php' << EOF
<?php
    putenv('TTRSS_DB_TYPE=mysql'); // pgsql or mysql
    putenv('TTRSS_DB_HOST=127.0.0.1');
    putenv('TTRSS_SELF_URL_PATH=https://${domain}/ttrss/');
    putenv('TTRSS_DB_USER=ttrss');
    putenv('TTRSS_DB_NAME=ttrss');
    putenv('TTRSS_DB_PASS=${password1}');
    putenv('TTRSS_DB_PORT=3306'); // usually 5432 for PostgreSQL, 3306 for MySQL
    putenv('TTRSS_MYSQL_CHARSET=UTF-8');

EOF
cd
#rm -rf /usr/share/nginx/tt-rss/install
cd /usr/share/nginx/tt-rss/plugins.local/
git clone https://github.com/DigitalDJ/tinytinyrss-fever-plugin fever
cd
  cat > '/etc/systemd/system/rssfeed.service' << EOF
[Unit]
Description=ttrss_backend
Documentation=https://tt-rss.org/
After=network.target mysql.service

[Service]
User=nginx
ExecStart=/usr/share/nginx/tt-rss/update_daemon2.php
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl enable rssfeed
systemctl restart rssfeed
#tt-rss themes
mkdir /usr/share/nginx/themes/
cd /usr/share/nginx/themes/
git clone https://github.com/levito/tt-rss-feedly-theme.git feedly
cd /usr/share/nginx/themes/feedly/
cp -r feedly* /usr/share/nginx/tt-rss/themes.local
cd
fi
}

