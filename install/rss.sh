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
    mysql -u ttrss -p"${password1}" -D ttrss < /usr/share/nginx/tt-rss/schema/ttrss_schema_mysql.sql
  cat > '/usr/share/nginx/tt-rss/config.php' << EOF
<?php
  // *******************************************
  // *** Database configuration (important!) ***
  // *******************************************

  define('DB_TYPE', 'mysql');
  define('DB_HOST', '127.0.0.1');
  define('DB_USER', 'ttrss');
  define('DB_NAME', 'ttrss');
  define('DB_PASS', '${password1}');
  define('DB_PORT', '3306');
  define('MYSQL_CHARSET', 'UTF8');

  // ***********************************
  // *** Basic settings (important!) ***
  // ***********************************

  define('SELF_URL_PATH', 'https://${domain}/ttrss//');
  define('SINGLE_USER_MODE', false);
  define('SIMPLE_UPDATE_MODE', false);

  // *****************************
  // *** Files and directories ***
  // *****************************

  define('PHP_EXECUTABLE', '/usr/bin/php');
  define('LOCK_DIRECTORY', 'lock');
  define('CACHE_DIR', 'cache');
  define('ICONS_DIR', "feed-icons");
  define('ICONS_URL', "feed-icons");

  // **********************
  // *** Authentication ***
  // **********************

  define('AUTH_AUTO_CREATE', true);
  define('AUTH_AUTO_LOGIN', true);

  // *********************
  // *** Feed settings ***
  // *********************

  define('FORCE_ARTICLE_PURGE', 0);

  // ****************************
  // *** Sphinx search plugin ***
  // ****************************

  define('SPHINX_SERVER', 'localhost:9312');
  define('SPHINX_INDEX', 'ttrss, delta');

  // ***********************************
  // *** Self-registrations by users ***
  // ***********************************

  define('ENABLE_REGISTRATION', false);
  define('REG_NOTIFY_ADDRESS', 'root@${domain}');
  define('REG_MAX_USERS', 10);

  // **********************************
  // *** Cookies and login sessions ***
  // **********************************

  define('SESSION_COOKIE_LIFETIME', 86400);
  define('SMTP_FROM_NAME', 'Tiny Tiny RSS');
  define('SMTP_FROM_ADDRESS', 'noreply@${domain}');
  define('DIGEST_SUBJECT', '[tt-rss] New headlines for last 24 hours');

  // ***************************************
  // *** Other settings (less important) ***
  // ***************************************

  define('CHECK_FOR_UPDATES', true);
  define('ENABLE_GZIP_OUTPUT', true);
  define('PLUGINS', 'auth_internal, note, fever, af_readability');
  define('LOG_DESTINATION', 'sql');
  define('CONFIG_VERSION', 26);
  define('_SKIP_SELF_URL_PATH_CHECKS', true);
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

