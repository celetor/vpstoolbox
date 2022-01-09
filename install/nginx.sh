#!/usr/bin/env bash

## NGINX模组 NGINX moudle

## 基础模组

install_nginx(){
  clear
  TERM=ansi whiptail --title "安装中" --infobox "安装NGINX中..." 7 68
  colorEcho ${INFO} "Install Nginx ing"
  apt-get install ca-certificates lsb-release -y
  apt-get install gnupg gnupg2 -y
  apt-get install gpg-agent -y
  touch /etc/apt/sources.list.d/nginx.list
  cat > '/etc/apt/sources.list.d/nginx.list' << EOF
deb https://nginx.org/packages/mainline/${dist}/ $(lsb_release -cs) nginx
#deb-src https://nginx.org/packages/mainline/${dist}/ $(lsb_release -cs) nginx
EOF
  curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
  #apt-key fingerprint ABF5BD827BD9BF62
  #apt-get purge nginx -qq -y
  apt-get update
  #apt-get install nginx -q -y
  sh -c 'echo "y\n\ny\ny\ny\n" | apt-get install nginx -y'
  id -u nginx
if [[ $? != 0 ]]; then
useradd -r nginx --shell=/usr/sbin/nologin
apt-get install nginx -y
fi
  cat > '/lib/systemd/system/nginx.service' << EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
Before=netdata.service trojan.service
After=syslog.target network.target remote-fs.target nss-lookup.target

[Service]
Type=forking
PIDFile=/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT \$MAINPID
PrivateTmp=true
LimitNOFILE=65536
Restart=on-failure
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable nginx
mkdir /usr/share/nginx/cache
mkdir /usr/share/nginx/php_cache
  cat > '/etc/nginx/nginx.conf' << EOF
user nginx;
worker_processes auto;

error_log /var/log/nginx/error.log warn;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;
events {
  #worker_connections 51200;
  use epoll;
  multi_accept on;
}

http {

  #proxy_cache_path /usr/share/nginx/cache levels=1:2 keys_zone=my_cache:10m max_size=100m inactive=60m use_temp_path=off;
  #proxy_cache_valid 200 302 10m;
  #proxy_cache_valid 404      1m;
  #proxy_cache_bypass \$http_pragma    \$http_authorization    \$http_cache_control;
  #proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
  #proxy_cache_revalidate on;
  #proxy_cache_background_update on;
  #proxy_cache_lock on;
  #proxy_cache my_cache;

  #fastcgi_cache_path /usr/share/nginx/php_cache levels=1:2 keys_zone=phpcache:10m max_size=100m inactive=60m use_temp_path=off;
  #fastcgi_cache_valid 200 302 10m;
  #fastcgi_cache_valid 404      1m;
  #fastcgi_cache_bypass \$http_pragma    \$http_authorization    \$http_cache_control;
  #fastcgi_cache_use_stale error timeout updating invalid_header http_500 http_503;
  #fastcgi_cache_revalidate on;
  #fastcgi_cache_background_update on;
  #fastcgi_cache_lock on;
  #fastcgi_cache phpcache;
  #fastcgi_cache_key "\$scheme\$proxy_host\$request_uri";

  autoindex_exact_size off;
  http2_push_preload on;
  aio threads;
  charset UTF-8;
  tcp_nodelay on;
  tcp_nopush on;
  server_tokens off;
  
  proxy_intercept_errors on;
  proxy_http_version 1.1;
  proxy_ssl_protocols TLSv1.2 TLSv1.3;
  proxy_set_header Host \$http_host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  access_log /var/log/nginx/access.log;

  log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
    '\$status \$body_bytes_sent "\$http_referer" '
    '"\$http_user_agent" "\$http_x_forwarded_for"';

  sendfile on;
  gzip on;
  gzip_proxied any;
  gzip_types *;
  gzip_comp_level 9;

  include /etc/nginx/conf.d/default.conf;
}
EOF
clear
}
