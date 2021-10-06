#!/usr/bin/env bash

## Nginx config模组 Nginx moudle

nginx_config(){
  set +e
  clear
TERM=ansi whiptail --title "安装中" --infobox "配置NGINX中..." 7 68
  colorEcho ${INFO} "配置(configing) nginx"
rm -rf /etc/nginx/sites-available/*
rm -rf /etc/nginx/sites-enabled/*
rm -rf /etc/nginx/conf.d/*
touch /etc/nginx/conf.d/default.conf
  cat > '/etc/nginx/conf.d/default.conf' << EOF
#!!! Do not change these settings unless you know what you are doing !!!
server {
  listen 127.0.0.1:81 fastopen=20 reuseport default_server;
  listen 127.0.0.1:82 http2 fastopen=20 reuseport default_server;
  server_name $domain _;
  #resolver 127.0.0.1;
  resolver_timeout 10s;
  #if (\$http_user_agent ~* (360|Tencent|MicroMessenger|Maxthon|TheWorld|UC|OPPO|baidu|Sogou|2345|) ) { return 403; }
  #if (\$http_user_agent ~* (wget|curl) ) { return 403; }
  #if (\$http_user_agent = "") { return 403; }
  #if (\$host != "$domain") { return 404; }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  #add_header X-Cache-Status \$upstream_cache_status;
  location / {
    #proxy_pass http://127.0.0.1:4000/;
    root /usr/share/nginx/hexo/public/;
    #error_page 404  /404.html;
    http2_push /css/main.css;
        http2_push /lib/font-awesome/css/all.min.css;
        http2_push /lib/anime.min.js;
        http2_push /lib/velocity/velocity.min.js;
        http2_push /lib/velocity/velocity.ui.min.js;
        http2_push /js/utils.js;
        http2_push /js/motion.js;
        http2_push /js/schemes/muse.js;
        http2_push /js/next-boot.js;
  }
  location /${password1}.png {
    root /usr/share/nginx/html/;
  }
  location /${password2}.png {
    root /usr/share/nginx/html/;
  }
  location /client1-${password1}.json {
    root /usr/share/nginx/html/;
  }
  location /client2-${password2}.json {
    root /usr/share/nginx/html/;
  }
EOF
if [[ $install_nextcloud == 1 ]]; then
echo "    include /etc/nginx/conf.d/nextcloud.conf;" >> /etc/nginx/conf.d/default.conf
touch /etc/nginx/conf.d/nextcloud.conf
cat << EOF > /etc/nginx/conf.d/nextcloud.conf

# https://docs.nextcloud.com/server/21/admin_manual/installation/nginx.html

# 与acme.sh路径冲突,待修复

    #location ^~ /.well-known {
        # The following 6 rules are borrowed from `.htaccess`

    #    location = /.well-known/carddav     { return 301 https://\$host:443/nextcloud/remote.php/dav/; }
    #    location = /.well-known/caldav      { return 301 https://\$host:443/nextcloud/remote.php/dav/; }
        # Anything else is dynamically handled by Nextcloud
    #    location ^~ /.well-known            { return 301 https://\$host:443/nextcloud/index.php\$uri; }

    #    try_files \$uri \$uri/ =404;
    #}

    #location /.well-known {
    #    rewrite ^/\.well-known/host-meta\.json  /nextcloud/public.php?service=host-meta-json    last;
    #    rewrite ^/\.well-known/host-meta        /nextcloud/public.php?service=host-meta         last;
    #    rewrite ^/\.well-known/webfinger        /nextcloud/public.php?service=webfinger         last;
    #    rewrite ^/\.well-known/nodeinfo         /nextcloud/public.php?service=nodeinfo          last;

    #    try_files \$uri \$uri/ =404;
    #}

    #location = /.well-known/carddav { return 301 https://\$host:443/nextcloud/remote.php/dav/; }
    #location = /.well-known/caldav { return 301 https://\$host:443/nextcloud/remote.php/dav/; }

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
fi
if [[ $install_typecho == 1 ]]; then
echo "    #location / {" >> /etc/nginx/conf.d/default.conf
echo "    #    client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "    #    index index.php index.html;" >> /etc/nginx/conf.d/default.conf
echo "    #    root /usr/share/nginx/typecho/;" >> /etc/nginx/conf.d/default.conf
echo "    #    location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "    #    fastcgi_split_path_info ^(.+\.php)(/.+)\$;" >> /etc/nginx/conf.d/default.conf
echo "    #    include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "    #    fastcgi_pass unix:/run/php/php7.4-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "    #    fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "    #    fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "    #    fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "    #    }" >> /etc/nginx/conf.d/default.conf
echo "    #    }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_jellyfin == 1 ]]; then
echo "    location /jellyfin/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:8096/jellyfin/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection "upgrade";" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_trojan_panel == 1 ]]; then
echo "    location /config/ {" >> /etc/nginx/conf.d/default.conf
echo "        expires -1;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        #http2_push /${password1}_config/css/app.css;" >> /etc/nginx/conf.d/default.conf
echo "        #http2_push /${password1}_config/js/app.js;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/trojan-panel/public/;" >> /etc/nginx/conf.d/default.conf
echo "        try_files \$uri \$uri/ @config;" >> /etc/nginx/conf.d/default.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_split_path_info ^(.+\.php)(/.+)\$;" >> /etc/nginx/conf.d/default.conf
echo "        include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_pass unix:/run/php/php7.4-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location @config {" >> /etc/nginx/conf.d/default.conf
echo "        rewrite /config/(.*)\$ /config/index.php?/\$1 last;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /config {" >> /etc/nginx/conf.d/default.conf
echo "        return 301 https://${domain}/config/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_rocketchat == 1 ]]; then
echo "    location /rocketchat {" >> /etc/nginx/conf.d/default.conf
echo "        expires -1;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_no_cache 1;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_cache_bypass 1;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection "upgrade";" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Nginx-Proxy true;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/rocketchat;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /file-upload/ {" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/rocketchat/file-upload/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /avatar/ {" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/rocketchat/avatar/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /assets/ {" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000/rocketchat/assets/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        location /home {" >> /etc/nginx/conf.d/default.conf
echo "        return 301 https://${domain}/rocketchat/home/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_mail == 1 ]]; then
echo "    location /mail/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/roundcubemail/;" >> /etc/nginx/conf.d/default.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "        include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_pass unix:/run/php/php7.4-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_dnscrypt == 1 ]]; then
echo "    location /dns-query {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:3000;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Connection "upgrade";" >> /etc/nginx/conf.d/default.conf
echo "        #error_page 502 = @errpage;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_speedtest == 1 ]]; then
echo "    location /${password1}_speedtest/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/speedtest/;" >> /etc/nginx/conf.d/default.conf
echo "        http2_push /${password1}_speedtest/speedtest.js;" >> /etc/nginx/conf.d/default.conf
echo "        http2_push /${password1}_speedtest/favicon.ico;" >> /etc/nginx/conf.d/default.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_split_path_info ^(.+\.php)(/.+)\$;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "        include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_pass   unix:/run/php/php7.4-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_rss == 1 ]]; then
echo "    location /${password1}_rsshub/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:1200/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /tt-rss/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host ${domain};" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Proto https;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:8280;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /ttrss/cache/ {" >> /etc/nginx/conf.d/default.conf
echo "        deny all;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /ttrss/config.php {" >> /etc/nginx/conf.d/default.conf
echo "        deny all;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_aria == 1 ]]; then
echo "    location $ariapath {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6800/jsonrpc;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /ariang/ {" >> /etc/nginx/conf.d/default.conf
echo "        expires -1;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        index index.html;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/ariang/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_qbt_e == 1 ]] || [[ $install_qbt_o == 1 ]]; then
echo "    location /qbt/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass              http://127.0.0.1:8080/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header        X-Forwarded-Host        \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_filebrowser == 1 ]]; then
echo "    location /file/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:8081/;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
#if [[ $install_filebrowser == 1 ]]; then
#echo "    include /etc/nginx/conf.d/filebrowser.conf;" >> /etc/nginx/conf.d/default.conf
#touch /etc/nginx/conf.d/filebrowser.conf
#cat > '/etc/nginx/conf.d/filebrowser.conf' << EOF
#location /file/ {
  #access_log off;
#  proxy_pass http://127.0.0.1:8081/;
#  client_max_body_size 0;
#}
#EOF
#fi
if [[ $install_i2pd == 1 ]]; then
echo "    location /${password1}_i2p/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:7070/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_tracker == 1 ]]; then
echo "    location /tracker/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        index index.html;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/tracker/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /tracker_stats/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6969/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location ~ ^/announce$ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6969;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_netdata == 1 ]]; then
echo "    location ~ /${password1}_netdata/(?<ndpath>.*) {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_cache off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Host \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-Server \$host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass_request_headers on;" >> /etc/nginx/conf.d/default.conf
echo '        proxy_set_header Connection "keep-alive";' >> /etc/nginx/conf.d/default.conf
echo "        proxy_store off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://netdata/\$ndpath\$is_args\$args;" >> /etc/nginx/conf.d/default.conf
echo "        gzip on;" >> /etc/nginx/conf.d/default.conf
echo "        gzip_proxied any;" >> /etc/nginx/conf.d/default.conf
echo "        gzip_types *;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
echo "}" >> /etc/nginx/conf.d/default.conf
echo "" >> /etc/nginx/conf.d/default.conf
echo "server {" >> /etc/nginx/conf.d/default.conf
echo "    listen 80 fastopen=20 reuseport;" >> /etc/nginx/conf.d/default.conf
echo "    listen [::]:80 fastopen=20 reuseport;" >> /etc/nginx/conf.d/default.conf
echo "    server_name $domain;" >> /etc/nginx/conf.d/default.conf
echo "    #if (\$http_user_agent ~* (360|Tencent|MicroMessenger|MetaSr|Xiaomi|Maxthon|TheWorld|QQ|UC|OPPO|baidu|Sogou|2345) ) { return 403; }" >> /etc/nginx/conf.d/default.conf
echo "    return 301 https://$domain\$request_uri;" >> /etc/nginx/conf.d/default.conf
echo "}" >> /etc/nginx/conf.d/default.conf
echo "" >> /etc/nginx/conf.d/default.conf
if [[ $install_netdata == 1 ]]; then
echo "server { #For Netdata only !" >> /etc/nginx/conf.d/default.conf
echo "    listen 127.0.0.1:83 fastopen=20 reuseport;" >> /etc/nginx/conf.d/default.conf
echo "    location /stub_status {" >> /etc/nginx/conf.d/default.conf
echo "    access_log off;" >> /etc/nginx/conf.d/default.conf
echo "    stub_status;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "    location ~ ^/(status|ping)\$ {" >> /etc/nginx/conf.d/default.conf
echo "    access_log off;" >> /etc/nginx/conf.d/default.conf
echo "    allow 127.0.0.1;" >> /etc/nginx/conf.d/default.conf
echo "    fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "    fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "    include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "    fastcgi_pass   unix:/run/php/php7.4-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "    }" >> /etc/nginx/conf.d/default.conf
echo "}" >> /etc/nginx/conf.d/default.conf
echo "upstream netdata {" >> /etc/nginx/conf.d/default.conf
echo "    server 127.0.0.1:19999;" >> /etc/nginx/conf.d/default.conf
echo "    keepalive 64;" >> /etc/nginx/conf.d/default.conf
echo "}" >> /etc/nginx/conf.d/default.conf
fi
chown -R nginx:nginx /usr/share/nginx/
systemctl restart nginx
}
