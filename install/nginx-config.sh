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
  resolver 127.0.0.1;
  resolver_timeout 10s;
  #if (\$http_user_agent ~* (360|Tencent|MicroMessenger|Maxthon|TheWorld|UC|OPPO|baidu|Sogou|2345|) ) { return 403; }
  #if (\$http_user_agent ~* (wget|curl) ) { return 403; }
  #if (\$http_user_agent = "") { return 403; }
  #if (\$host != "$domain") { return 404; }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
  add_header X-Cache-Status \$upstream_cache_status;
  location / {
    proxy_pass http://127.0.0.1:4000/;
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
fi
if [[ $install_tjp == 1 ]]; then
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
if [[ $install_chat == 1 ]]; then
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
if [[ $dnsmasq_install == 1 ]]; then
echo "    #location /dns-query {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_pass https://127.0.0.1:3001/dns-query;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_set_header Upgrade \$http_upgrade;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_set_header Connection "upgrade";" >> /etc/nginx/conf.d/default.conf
echo "        #error_page 502 = @errpage;" >> /etc/nginx/conf.d/default.conf
echo "        #}" >> /etc/nginx/conf.d/default.conf
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
if [[ $install_rsshub == 1 ]]; then
echo "    location /${password1}_rsshub/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:1200/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /ttrss/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/tt-rss/;" >> /etc/nginx/conf.d/default.conf
echo "        location ~ \.php\$ {" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_split_path_info ^(.+\.php)(/.+)\$;" >> /etc/nginx/conf.d/default.conf
echo "        include fastcgi_params;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_pass unix:/run/php/php7.4-fpm.sock;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_index index.php;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param HTTPS on;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param modHeadersAvailable true;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param front_controller_active true;" >> /etc/nginx/conf.d/default.conf
echo "        fastcgi_param SCRIPT_FILENAME \$request_filename;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /${password1}_ttrss/cache/ {" >> /etc/nginx/conf.d/default.conf
echo "        deny all;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /${password1}_ttrss/config.php {" >> /etc/nginx/conf.d/default.conf
echo "        deny all;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_aria == 1 ]]; then
echo "    location $ariapath {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_redirect off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6800/jsonrpc;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_qbt == 1 ]]; then
echo "    location $qbtpath {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass              http://127.0.0.1:8080/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header        X-Forwarded-Host        \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_file == 1 ]]; then
echo "    include /etc/nginx/conf.d/filebrowser.conf;" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_i2p == 1 ]]; then
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
echo "    location ~ $netdatapath(?<ndpath>.*) {" >> /etc/nginx/conf.d/default.conf
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
echo "    if (\$http_user_agent ~* (360|Tencent|MicroMessenger|MetaSr|Xiaomi|Maxthon|TheWorld|QQ|UC|OPPO|baidu|Sogou|2345) ) { return 403; }" >> /etc/nginx/conf.d/default.conf
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