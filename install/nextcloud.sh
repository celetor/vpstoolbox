#!/usr/bin/env bash

## Nextcloud模组 Nextcloud moudle

install_nextcloud(){
  set +e
  TERM=ansi whiptail --title "安装中" --infobox "安装nextcloud中..." 7 68
  apt-get install php8.0-redis -y
  apt-get install unzip -y
  apt-get install libmagickcore-6.q16-6-extra -y
  cd /usr/share/nginx
  if [[ -d /usr/share/nginx/nextcloud/ ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新nextcloud中..." 7 68
    curl -LO https://download.nextcloud.com/server/releases/latest.zip
    unzip -o latest.zip
    rm latest.zip
    chown -R nginx:nginx /usr/share/nginx/nextcloud/
    chmod +x /usr/share/nginx/nextcloud/occ
    cd
  else
  mysql -u root -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  mysql -u root -e "create user 'nextcloud'@'localhost' IDENTIFIED BY '${password1}';"
  mysql -u root -e "GRANT ALL PRIVILEGES ON nextcloud.* to nextcloud@'localhost';"
  mysql -u root -e "flush privileges;"
  curl -LO https://download.nextcloud.com/server/releases/latest.zip
  unzip -o latest.zip
  rm latest.zip
  mkdir /usr/share/nginx/nextcloud_data
  cd /usr/share/nginx/nextcloud/config
  cat > "autoconfig.php" << EOF
<?php
\$AUTOCONFIG = array(
  "dbtype"        => "mysql",
  "dbname"        => "nextcloud",
  "dbuser"        => "nextcloud",
  "dbpass"        => "${password1}",
  "dbhost"        => "localhost:/run/mysqld/mysqld.sock",
  "dbtableprefix" => "",
  "adminlogin"    => "admin",
  "adminpass"     => "${password1}",
  "directory"     => "/usr/share/nginx/nextcloud_data",
);
EOF
  chown -R nginx:nginx /usr/share/nginx/
  chown -R nginx:nginx /etc/nginx/
  crontab -l > mycron
  echo "*/5 * * * * sudo -u nginx php --define apc.enable_cli=1 -f /usr/share/nginx/nextcloud/cron.php &> /dev/null" >> mycron
  crontab mycron
  rm mycron
  chmod +x /usr/share/nginx/nextcloud/occ
  cd
fi

mkdir /usr/share/nginx/tmp/

cd

## Nextcloud 全自动配置 && 配置完成后全自动删除

    cat > '/root/nextcloud_autoconfig.sh' << EOF
#!/usr/bin/env bash

set +e

sleep 200s;

while [[ -f /usr/share/nginx/nextcloud/config/autoconfig.php ]] && [[ ! -f /usr/share/nginx/nextcloud/config/config.php ]]
do
  echo "no auto config required" &> /root/nextcloud_autoconfig.log
  sleep 5s;
done

sed '\$d' /usr/share/nginx/nextcloud/config/config.php ## delete last line

echo "  'memcache.local' => '\\OC\\Memcache\\APCu'," >> /usr/share/nginx/nextcloud/config/config.php
echo "  'memcache.distributed' => '\\OC\\Memcache\\Redis'," >> /usr/share/nginx/nextcloud/config/config.php
echo "  'memcache.locking' => '\\OC\\Memcache\\Redis'," >> /usr/share/nginx/nextcloud/config/config.php
echo "  'redis' => [" >> /usr/share/nginx/nextcloud/config/config.php
echo "     'host'     => '/var/run/redis/redis.sock'," >> /usr/share/nginx/nextcloud/config/config.php
echo "     'port'     => 0," >> /usr/share/nginx/nextcloud/config/config.php
echo "     'timeout'  => 1.0," >> /usr/share/nginx/nextcloud/config/config.php
echo "  ]," >> /usr/share/nginx/nextcloud/config/config.php
echo "  'default_phone_region' => 'CN'," >> /usr/share/nginx/nextcloud/config/config.php
echo ");" >> /usr/share/nginx/nextcloud/config/config.php

sudo -u nginx php --define apc.enable_cli=1 /usr/share/nginx/nextcloud/occ db:add-missing-indices
sudo -u nginx php --define apc.enable_cli=1 /usr/share/nginx/nextcloud/occ db:convert-filecache-bigint

#rm -rf /root/nextcloud_autoconfig.log
rm -rf /root/nextcloud_autoconfig.sh
systemctl disable nextcloud --now

exit 0
EOF

  cat > '/etc/systemd/system/nextcloud.service' << EOF
[Unit]
Description=Nextcloud auto config service

[Service]
Type=oneshot
User=root
ExecStart=/root/nextcloud_autoconfig.sh
ExecStop=/usr/bin/rm -rf /etc/systemd/system/nextcloud.service
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

chmod +x /root/nextcloud_autoconfig.sh

systemctl daemon-reload
systemctl enable nextcloud

}
