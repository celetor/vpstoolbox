#!/usr/bin/env bash

## Nextcloud模组 Nectcloud moudle

install_nextcloud(){
  set +e
  TERM=ansi whiptail --title "安装中" --infobox "安装nextcloud中..." 7 68
  apt-get install php7.4-redis -y
  apt-get install smbclient -y
  apt-get install libmagickcore-6.q16-6-extra -y
  cd /usr/share/nginx
  cloudver=$(curl -s "https://api.github.com/repos/nextcloud/server/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  cloudver1=$(curl -s "https://api.github.com/repos/nextcloud/server/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-20)
  if [[ -d /usr/share/nginx/nextcloud/ ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新nextcloud中..." 7 68
    curl -LO https://download.nextcloud.com/server/releases/nextcloud-${cloudver1}.zip
    unzip -o nextcloud*.zip
    rm nextcloud*.zip
    chown -R nginx:nginx /usr/share/nginx/nextcloud/
    chmod +x /usr/share/nginx/nextcloud/occ
    cd
  else
  mysql -u root -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  mysql -u root -e "create user 'nextcloud'@'localhost' IDENTIFIED BY '${password1}';"
  mysql -u root -e "GRANT ALL PRIVILEGES ON nextcloud.* to nextcloud@'localhost';"
  mysql -u root -e "flush privileges;"
  curl -LO https://download.nextcloud.com/server/releases/nextcloud-${cloudver1}.zip
  unzip -o nextcloud*.zip
  rm nextcloud*.zip
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
  #sudo -u nginx ./occ db:add-missing-indices
  #sudo -u nginx ./occ db:convert-filecache-bigint
fi

mkdir /usr/share/nginx/tmp/

cd
}
