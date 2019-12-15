#!/bin/bash
if [[ $(id -u) != 0 ]]; then
    echo Please run this script as root.
    exit 1
fi

userinput(){
echo "Hello, "$USER".  This script will help you set up a trojan-gfw server."
echo -n "Please Enter your domain and press [ENTER]: "
read domain
  if [[ -z "$domain" ]]; then
    echo
    echo -n "INPUT ERROR! Please Enter your domain again and press [ENTER]: "
    read domain
  fi
echo -n "It\'s nice to meet you $domain"
echo
echo -n "Please Enter your desired password1 and press [ENTER]: "
read password1
  if [[ -z "$password1" ]]; then
    echo
    echo -n "INPUT ERROR! Please Enter your os password1 again and press [ENTER]: "
    read password1
  fi
echo -n "Your password1 is $password1"
echo
echo -n "Please Enter your desired password2 and press [ENTER]: "
read password2
  if [[ -z "$password2" ]]; then
    echo
    echo -n "INPUT ERROR! Please Enter your password2 again and press [ENTER]: "
    read password2
  fi
echo -n "Your password2 is $password2"
}

osdist(){

set -e
 if cat /etc/*release | grep ^NAME | grep CentOS; then
    echo "==============================================="
    echo "Installing on CentOS"
    echo "==============================================="
    dist=centos
 elif cat /etc/*release | grep ^NAME | grep Red; then
    echo "==============================================="
    echo "Installing on RedHat"
    echo "==============================================="
    dist=centos
 elif cat /etc/*release | grep ^NAME | grep Fedora; then
    echo "================================================"
    echo "Installing on Fedorea"
    echo "================================================"
    dist=centos
 elif cat /etc/*release | grep ^NAME | grep Ubuntu; then
    echo "==============================================="
    echo "Installing on Ubuntu"
    echo "==============================================="
    dist=ubuntu
 elif cat /etc/*release | grep ^NAME | grep Debian; then
    echo "==============================================="
    echo "Installing on Debian"
    echo "==============================================="
    dist=debian
 else
    echo "OS NOT SUPPORTED, couldn't install Trojan-gfw"
    exit 1;
 fi
}

updatesystem(){
	if [[ $dist = centos ]]; then
    yum update
 elif [[ $dist = ubuntu ]]; then
    apt-get update
 elif [[ $dist = debian ]]; then
    apt-get update
 else
  clear
    echo "error can't update system"
    exit 1;
 fi
}

upgradesystem(){
	if [[ $dist = centos ]]; then
    yum upgrade -y
 elif [[ $dist = ubuntu ]]; then
    apt-get upgrade -y
 elif [[ $dist = debian ]]; then
    apt-get upgrade -y
 else
  clear
    echo "error can't upgrade system"
    exit 1;
 fi
}

openfirewall(){
  iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
  iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
  iptables -I OUTPUT -j ACCEPT
}

installrely(){
	echo installing trojan-gfw nginx and acme
	if [[ $dist = centos ]]; then
    yum install sudo curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 -y
 elif [[ $dist = ubuntu ]]; then
    apt-get install sudo curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 -y
 elif [[ $dist = debian ]]; then
    apt-get install sudo curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 -y
 else
  clear
    echo "error can't update system"
    exit 1;
 fi
}

installtrojan-gfw(){
	bash -c "$(wget -O- https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"
}

nginxyum(){
	yum install nginx -y
}

nginxapt(){
	wget https://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
  touch /etc/apt/sources.list.d/nginx.list
	echo "deb https://nginx.org/packages/mainline/debian/ $(lsb_release -cs) nginx" >> /etc/apt/sources.list.d/nginx.list
	echo "deb-src https://nginx.org/packages/mainline/debian/ $(lsb_release -cs) nginx" >> /etc/apt/sources.list.d/nginx.list
	apt-get update
	apt-get install nginx -y
}

nginxubuntu(){
	wget https://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
  touch /etc/apt/sources.list.d/nginx.list
	echo "deb https://nginx.org/packages/mainline/ubuntu/ $(lsb_release -cs) nginx" >> /etc/apt/sources.list.d/nginx.list
	echo "deb-src https://nginx.org/packages/mainline/ubuntu/ $(lsb_release -cs) nginx" >> /etc/apt/sources.list.d/nginx.list
	apt-get update
	apt-get install nginx -y
}

installnginx(){
	if [[ $dist = centos ]]; then
    nginxyum
 elif [[ $dist = ubuntu ]]; then
    nginxubuntu
 elif [[ $dist = debian ]]; then
    nginxapt
 else
  clear
    echo "error can't install nginx"
    exit 1;
 fi
}

installacme(){
	curl https://get.acme.sh | sh
  sudo ~/.acme.sh/acme.sh --upgrade --auto-upgrade
	mkdir /etc/trojan/
}

issuecert(){
  systemctl start nginx
	sudo ~/.acme.sh/acme.sh --issue -d $domain --webroot /usr/share/nginx/html/ -k ec-256
  systemctl stop nginx
}

renewcert(){
  sudo ~/.acme.sh/acme.sh --issue -d $domain --webroot /usr/share/nginx/html/ -k ec-256
}

installcert(){
	sudo ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/trojan/trojan.crt --keypath /etc/trojan/trojan.key --ecc
}

installkey(){
	chmod +r /etc/trojan/trojan.key
}

changepasswd(){
	sed  -i 's/path/etc/g' /usr/local/etc/trojan/config.json
	sed  -i 's/to/trojan/g' /usr/local/etc/trojan/config.json
	sed  -i 's/certificate.crt/trojan.crt/g' /usr/local/etc/trojan/config.json
	sed  -i 's/private.key/trojan.key/g' /usr/local/etc/trojan/config.json
	sed  -i "s/password1/$password1/g" /usr/local/etc/trojan/config.json
	sed  -i "s/password2/$password2/g" /usr/local/etc/trojan/config.json
}

nginxtrojan(){
rm -rf /etc/nginx/sites-available/
rm -rf /etc/nginx/sites-enabled/
rm -rf /etc/nginx/conf.d/default.conf
touch /etc/nginx/conf.d/trojan.conf
  cat > '/etc/nginx/conf.d/trojan.conf' << EOF
server {
  listen 127.0.0.1:80; #放在Trojan后面即可做伪装也可以是真正的网站
    server_name $domain;
    location / {
      root /usr/share/nginx/html/;
        index index.html;
        }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    root /usr/share/nginx/html/; #用于自动更新证书
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
}

#echo "trojan-gfw config complete!"
autostart(){
	systemctl start trojan
	systemctl start nginx
	systemctl enable nginx
	systemctl enable trojan
}

tcp-bbr(){
	echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.d/99-sysctl.conf
	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.d/99-sysctl.conf
	sysctl -p
}

iptables-persistent(){
  if [[ $dist = centos ]]; then
    yum install iptables-persistent -y
 elif [[ $dist = ubuntu ]]; then
    apt-get install iptables-persistent -y
 elif [[ $dist = debian ]]; then
    apt-get install iptables-persistent -y
 else
  clear
    echo "error can't install iptables-persistent"
    exit 1;
 fi
}

sharelink(){
  echo "Your Trojan-Gfw Share link1 is: trojan://$password1@$domain:443"
  echo "Your Trojan-Gfw Share link1 is: trojan://$password2@$domain:443"
  echo ""
}

############Set UP V2ray############
v2input(){
echo "Hello, "$USER".  This script will help you set up a trojan-gfw server."
echo -n "Please Enter your domain and press [ENTER]: "
read domain
echo -n "It\'s nice to meet you $domain"
echo
echo -n "Please Enter your desired password1 and press [ENTER]: "
read password1
echo -n "Your password1 is $password1"
echo
echo -n "Please Enter your desired password2 and press [ENTER]: "
read password2
echo -n "Your password2 is $password2"
echo -n "Please Enter your desired Websocket path and press [ENTER]: "
read path
echo -n "Your path is $path"
}
installv2ray(){
  bash <(curl -L -s https://install.direct/go.sh)
  rm -rf /etc/v2ray/config.json
  echo "generating random uuid"
  uuid=$(/usr/bin/v2ray/v2ctl uuid)
  cat > "/etc/v2ray/config.json" << EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log"
  },
  "inbounds": [
        {
            "sniffing": {
            "enabled": true,
            "destOverride": ["http","tls"]
        },
        "port": 10000,
        "listen":"127.0.0.1",
        "protocol": "vmess",
        "settings": {
            "clients": [
                {
                    "id": "$uuid",
                    "alterId": 64
                }
            ]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
        "path": "$path"
        }
        }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "ip": [
        "geoip:cn"
      ],
      "outboundTag": "blocked"
      },
      {
        "type": "field",
        "domain": [
        "baidu.com",
        "qq.com",
        "sina.com",
        "geosite:cn"
      ],
      "outboundTag": "blocked"
      },
      {
        "type" :"field",
        "outboundTag": "blocked",
        "domain": ["geosite:category-ads"]
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [
          "bittorrent"
        ]
      }
    ]
  }
}
EOF
systemctl start v2ray
systemctl enable v2ray
}

nginxv2ray(){
rm -rf /etc/nginx/sites-available/
rm -rf /etc/nginx/sites-enabled/
rm -rf /etc/nginx/conf.d/default.conf
touch /etc/nginx/conf.d/trojan.conf
  cat > '/etc/nginx/conf.d/trojan.conf' << EOF
server {
  listen 127.0.0.1:80; #放在Trojan后面即可做伪装也可以是真正的网站
    server_name $domain;
    location / {
      root /usr/share/nginx/html/;
        index index.html;
        }
    location $path {
        access_log off;
        proxy_intercept_errors on;
        proxy_redirect off;
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Early-Data @ssl_early_data;
        proxy_set_header Upgrade @http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host @http_host;
        proxy_set_header X-Real-IP @remote_addr;
        proxy_set_header X-Forwarded-For @proxy_add_x_forwarded_for;
        }
  add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
}

server {
    listen 80;
    listen [::]:80;
    server_name $domain;
    root /usr/share/nginx/html/; #用于自动更新证书
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;
    return 444;
}
EOF
sed  -i 's/@/$/g' /etc/nginx/conf.d/trojan.conf
}
###########Trojan Client Config#############
trojanclient(){
  touch /etc/trojan/client.json
    cat > '/etc/trojan/client.json' << EOF
{
    "run_type": "client",
    "local_addr": "127.0.0.1",
    "local_port": 1080,
    "remote_addr": "$domain",
    "remote_port": 443,
    "password": [
        "$password1"
    ],
    "log_level": 1,
    "ssl": {
        "verify": true,
        "verify_hostname": true,
        "cert": "",
        "cipher": "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:RSA-AES128-GCM-SHA256:RSA-AES256-GCM-SHA384:RSA-AES128-SHA:RSA-AES256-SHA:RSA-3DES-EDE-SHA",
        "sni": "",
        "alpn": [
            "h2",
            "http/1.1"
        ],
        "reuse_session": true,
        "session_ticket": false,
        "curves": ""
    },
    "tcp": {
        "no_delay": true,
        "keep_alive": true,
        "fast_open": false,
        "fast_open_qlen": 20
    }
}
EOF
}
##########V2ray Client Config################
v2rayclient(){
  touch /etc/v2ray/client.json
  cat > '/etc/v2ray/client.json' << EOF
{
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": 8001,
      "protocol": "http",
      "sniffing": {
        "enabled": true,
        "destOverride": ["http","tls"]
      }
    },
    {
      "port": 1081,
      "listen": "127.0.0.1",
      "protocol": "socks",
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      },
      "settings": {
        "auth": "noauth",
        "udp": false
      }
    }
  ],
  "outbounds": [
    {
      "tag": "proxy",
      "protocol": "vmess",
      "settings": {
        "vnext": [
          {
            "address": "$domain",
            "port": 443,
            "users": [
              {
                "id": "$uuid",
                "alterId": 0,
                "security": "none" //使用TLS则无需二次加密
              }
            ]
          }
        ]
      },
      "streamSettings": {
      "network": "ws",
      "security": "tls",
      "wsSettings": {
        "path": "$path",
        "headers": {
          "Host": "$domain"
        }
      },
      "tlsSetting": {
        "allowInsecure": false,
        "alpn": ["http/1.1","h2"],
        "serverName": "$domain",
        "allowInsecureCiphers": false,
        "disableSystemRoot": false
      },
      "mux": {
        "enabled": false
      }
    },
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "adblock",
      "protocol" : "blackhole",
      "settings": {}
    }
  ],
  "dns": {
    "servers": [
      "8.8.8.8",
      {
        "address": "114.114.114.114",
        "port": 53,
        "domains": [
          "geosite:cn"
        ]
      }
    ]
  },
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "outboundTag": "direct",
        "ip": [
          "geoip:private"
        ]
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "ip": [
          "geoip:cn"
        ]
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "domain": [
          "geosite:cn"
        ]
      },
      {
        "type": "field",
        "outboundTag": "direct",
        "protocol": [
          "bittorrent"
        ]
      },
      {
        "type" :"field",
        "outboundTag": "adblock",
        "domain": ["geosite:category-ads"]
      }
    ]
  }
}
EOF
}
##########Remove Trojan-Gfw##########
removetrojan(){
  systemctl stop trojan
  systemctl disable trojan
  rm -rf /usr/local/etc/trojan/*
  rm -rf /etc/trojan/*
  rm -rf /etc/systemd/system/trojan.service
  rm -rf ~/.acme.sh/$domain
}
##########Remove V2ray###############
removev2ray(){
  systemctl stop v2ray
  systemctl disable v2ray
  systemctl daemon-reload
  cd
  wget https://install.direct/go.sh
  sudo bash go.sh --remove
}
####################################
DELAY=3 # Number of seconds to display results

while true; do
  clear
  cat << _EOF_
This script will help you set up a trojan-gfw server in an extremely fast way.
For more Info: https://www.johnrosen1.com/trojan/
If you are not sure,Please choose option 1 !
Please Select:

1. Normal Install (new machine)
2. Extended Install (V2ray Websocket included)
3. Install Trojan-Gfw only (If you'd like to manually set up web servers other than nginx)
4. Install Nginx only (If you'd like to set up Trojan-gfw manually)
5. Force renew certificate (If you don't trust autorenew)
6. Remove Trojan-Gfw
7. Remove V2ray
0. Quit

_EOF_

  read -p "Enter selection [0-7] > "

  if [[ $REPLY =~ ^[0-7]$ ]]; then
    case $REPLY in
      1)
        userinput
        echo "Detecting OS version"
        osdist
        echo "Your os codename is $dist"
        echo "Updating system"
        updatesystem
        echo "Upgrading system"
        upgradesystem
        echo "configing firewall"
        openfirewall
        echo "installing rely"
        installrely
        clear
        echo "installing trojan-gfw"
        installtrojan-gfw
        clear
        echo "installing nginx"
        installnginx
        clear
        echo "installing acme"
        installacme
        clear
        echo "issueing let\'s encrypt certificate"
        issuecert
        clear
        echo "issue complete,installing certificate"
        installcert
        clear
        echo "certificate install complete!"
        echo "giving private key read authority"
        installkey
        clear
        echo "autoconfiging trojan-gfw"
        changepasswd
        clear
        echo "autoconfiging nginx"
        nginxtrojan
        clear
        echo "starting trojan-gfw and nginx | setting up boot autostart"
        autostart
        clear
        echo "Setting up tcp-bbr boost technology"
        tcp-bbr
        clear
        iptables-persistent
        clear
        trojanclient
        echo "Your Trojan-Gfw client config"
        cat /etc/trojan/client.json
        echo "https://github.com/trojan-gfw/trojan/wiki/Mobile-Platforms"
        echo "https://github.com/trojan-gfw/trojan/releases/latest"        
        echo "Install Success,Enjoy it!"
        break
        ;;
      2)      
        v2input
        echo "Detecting OS version"
        osdist
        echo "Your os codename is $dist"
        echo "Updating system"
        updatesystem
        echo "Upgrading system"
        upgradesystem
        echo "configing firewall"
        openfirewall
        echo "installing rely"
        installrely
        clear
        echo "installing trojan-gfw"
        installtrojan-gfw
        echo "installing nginx"
        installnginx
        echo "installing acme"
        installacme
        clear
        echo "issueing let\'s encrypt certificate"
        issuecert
        echo "issueing let\'s encrypt certificate"
        installcert
        echo "certificate install complete!"
        echo "giving private key read authority"
        installkey
        changepasswd
        echo "installing V2ray"
        installv2ray
        echo "configing v2ray vmess+tls+Websocket"
        nginxv2ray
        echo "starting trojan-gfw v2ray and nginx | setting up boot autostart"
        autostart
        echo "Setting up tcp-bbr boost technology"
        tcp-bbr
        iptables-persistent
        clear
        trojanclient
        echo "Your Trojan-Gfw client config"
        cat /etc/trojan/client.json
        echo "https://github.com/trojan-gfw/trojan/wiki/Mobile-Platforms"
        echo "https://github.com/trojan-gfw/trojan/releases/latest"
        v2rayclient
        echo "Your V2ray client config"
        cat /etc/v2ray/client.json
        echo "https://github.com/v2ray/v2ray-core/releases/latest"
        echo "Install Success,Enjoy it!"
        break
        ;;
      3)
        echo "Detecting OS version"
        osdist
        echo "Your os codename is $dist"
        echo "Updating system"
        updatesystem
        echo "Upgrading system"
        upgradesystem
        echo "configing firewall"
        openfirewall
        echo "installing rely"
        installrely
        echo "installing trojan-gfw"
        installtrojan-gfw
        break
        ;;
      4)
        echo "Detecting OS version"
        osdist
        echo "Your os codename is $dist"
        echo "Updating system"
        updatesystem
        echo "Upgrading system"
        upgradesystem
        echo "configing firewall"
        openfirewall
        echo "installing rely"
        installrely
        echo "installing nginx"
        installnginx
        break
        ;;
      5)
        userinput
        renewcert
        break
        ;;
      6)
        removetrojan
        break
        ;;
      7)
        removev2ray
        break
        ;;            
      0)
        break
        ;;
    esac
  else
    echo "Invalid entry."
    sleep $DELAY
  fi
done
echo "Program terminated."