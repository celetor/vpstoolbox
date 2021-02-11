#!/usr/bin/env bash

## Nextcloud模组 Nectcloud moudle

install_nextcloud(){
  set +e
  TERM=ansi whiptail --title "安装中" --infobox "安装nextcloud中..." 7 68
  apt-get install php7.4-redis -y
  cd /usr/share/nginx
  cloudver=$(curl -s "https://api.github.com/repos/nextcloud/server/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  cloudver1=$(curl -s "https://api.github.com/repos/nextcloud/server/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -c2-20)
  if [[ -d /usr/share/nginx/nextcloud/ ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新nextcloud中..." 7 68
    wget https://github.com/nextcloud/server/releases/download/${cloudver}/nextcloud-${cloudver1}.zip
    unzip -o nextcloud*
    rm nextcloud*.zip
    cd
  else
  mysql -u root -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  mysql -u root -e "create user 'nextcloud'@'localhost' IDENTIFIED BY '${password1}';"
  mysql -u root -e "GRANT ALL PRIVILEGES ON nextcloud.* to nextcloud@'localhost';"
  mysql -u root -e "flush privileges;"
  wget https://github.com/nextcloud/server/releases/download/${cloudver}/nextcloud-${cloudver1}.zip
  unzip -o nextcloud*
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
  echo "*/5 * * * * sudo -u nginx php -f /usr/share/nginx/nextcloud/cron.php" >> mycron
  crontab mycron
  rm mycron
  chmod +x /usr/share/nginx/nextcloud/occ
  cd
  #sudo -u nginx ./occ db:add-missing-indices
  #sudo -u nginx ./occ db:convert-filecache-bigint
fi

mkdir /usr/share/nginx/tmp/

cd /etc/nginx/conf.d/

cat > 'nextcloud.conf' << EOF
    location /.well-known {
        rewrite ^/\.well-known/host-meta\.json  /nextcloud/public.php?service=host-meta-json    last;
        rewrite ^/\.well-known/host-meta        /nextcloud/public.php?service=host-meta         last;
        rewrite ^/\.well-known/webfinger        /nextcloud/public.php?service=webfinger         last;
        rewrite ^/\.well-known/nodeinfo         /nextcloud/public.php?service=nodeinfo          last;

        try_files \$uri \$uri/ =404;
    }

    location = /.well-known/carddav { return 301 https://\$host:443/nextcloud/remote.php/dav; }
    location = /.well-known/caldav { return 301 https://\$host:443/nextcloud/remote.php/dav; }

    location ^~ /nextcloud/ {
        root /usr/share/nginx/;
        client_body_temp_path /usr/share/nginx/tmp/ 1 2;
        client_max_body_size 0;
        fastcgi_buffers 64 4K;
        add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;" always;
        add_header Referrer-Policy                      "no-referrer"   always;
        add_header X-Content-Type-Options               "nosniff"       always;
        add_header X-Download-Options                   "noopen"        always;
        add_header X-Frame-Options                      "SAMEORIGIN"    always;
        add_header X-Permitted-Cross-Domain-Policies    "none"          always;
        add_header X-Robots-Tag                         "none"          always;
        add_header X-XSS-Protection                     "1; mode=block" always;
        #fastcgi_hide_header X-Powered-By;
        index index.php index.html /nextcloud/index.php\$request_uri;

        expires 1m;

        location = /nextcloud/ {
            if ( \$http_user_agent ~ ^DavClnt ) {
                return 302 /nextcloud/remote.php/webdav/\$is_args\$args;
            }
        }

        location ~ ^/nextcloud/(?:build|tests|config|lib|3rdparty|templates|data)(?:\$|/)    { return 404; }
        location ~ ^/nextcloud/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

        location ~ \.php(?:\$|/) {
            fastcgi_split_path_info ^(.+?\.php)(/.*)\$;
            set \$path_info \$fastcgi_path_info;

            try_files \$fastcgi_script_name =404;

            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME \$request_filename;
            fastcgi_param PATH_INFO \$path_info;
            fastcgi_param HTTPS on;

            fastcgi_param modHeadersAvailable true;
            fastcgi_param front_controller_active true;
            fastcgi_pass unix:/run/php/php7.4-fpm.sock;

            fastcgi_intercept_errors on;
            fastcgi_request_buffering off;
            fastcgi_read_timeout 600s;
        }

        location ~ \.(?:css|js|svg|gif)\$ {
            try_files \$uri /nextcloud/index.php\$request_uri;
            expires 6M;
            access_log off;
        }

        location ~ \.woff2?\$ {
            try_files \$uri /nextcloud/index.php\$request_uri;
            expires 7d;
            access_log off;
        }

        location /nextcloud/ {
            try_files \$uri \$uri/ /nextcloud/index.php\$request_uri;
        }
    }
EOF
cd
}