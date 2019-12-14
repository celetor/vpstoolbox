#!/bin/bash
if [[ $(id -u) != 0 ]]; then
    echo Please run this script as root.
    exit 1
fi

userinput(){
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
    echo "OS NOT DETECTED, couldn't install package $PACKAGE"
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
    echo "error can't upgrade system"
    exit 1;
 fi
}

openfirewall(){
  iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
  iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
}

installrely(){
	echo installing trojan-gfw nginx and acme
	if [[ $dist = centos ]]; then
    yum install sudo curl socat xz-utils wget apt-transport-https -y
 elif [[ $dist = ubuntu ]]; then
    apt-get install sudo curl socat xz-utils wget apt-transport-https -y
 elif [[ $dist = debian ]]; then
    apt-get install sudo curl socat xz-utils wget apt-transport-https -y
 else
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
  code=$(cat /etc/*release | grep ^VERSION_CODENAME | tr -d 'VERSION_CODENAME="')
	wget https://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
	echo "deb https://nginx.org/packages/mainline/debian/ $code nginx" >> /etc/apt/sources.list
	echo "deb-src https://nginx.org/packages/mainline/debian/ $code nginx" >> /etc/apt/sources.list
	apt-get update
	apt-get install nginx -y
}

nginxubuntu(){
  code=$(cat /etc/*release | grep ^VERSION_CODENAME | tr -d 'VERSION_CODENAME="')
	wget https://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
	echo "deb https://nginx.org/packages/mainline/ubuntu/ $code nginx" >> /etc/apt/sources.list
	echo "deb-src https://nginx.org/packages/mainline/ubuntu/ $code nginx" >> /etc/apt/sources.list
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
    echo "error can't install nginx"
    exit 1;
 fi
}

installacme(){
	curl https://get.acme.sh | sh
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
    echo "error can't install nginx"
    exit 1;
 fi
}

sharelink(){
  echo "Your Trojan-Gfw Share link1 is: trojan://$password1@$domain:443"
  echo "Your Trojan-Gfw Share link1 is: trojan://$password2@$domain:443"
  echo ""
}

############Set UP V2ray############
installv2ray(){
  bash <(curl -L -s https://install.direct/go.sh)
  rm -rf /etc/v2ray/config.json
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
                    "id": "7bd655f7-bfd1-0739-c874-630d8f4939db",
                    "alterId": 0
                }
            ]
        },
        "streamSettings": {
            "network": "ws",
            "wsSettings": {
        "path": "/ray"
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
    location /ray {
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
##########Remove Trojan-Gfw##########
removetrojan(){
  systemctl stop trojan
  systemctl disable trojan
  rm -rf /usr/local/etc/trojan/*
  rm -rf /etc/trojan/*
}
#####################################
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
0. Quit

_EOF_

  read -p "Enter selection [0-6] > "

  if [[ $REPLY =~ ^[0-5]$ ]]; then
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
        echo "installing trojan-gfw"
        installtrojan-gfw
        echo "installing nginx"
        installnginx
        echo "installing acme"
        installacme
        echo "issueing let\'s encrypt certificate"
        issuecert
        echo "issue complete,installing certificate"
        installcert
        echo "certificate install complete!"
        echo "giving private key read authority"
        installkey
        echo "autoconfiging trojan-gfw"
        changepasswd
        echo "autoconfiging nginx"
        nginxtrojan
        echo "starting trojan-gfw and nginx | setting up boot autostart"
        autostart
        echo "Setting up tcp-bbr boost technology"
        tcp-bbr
        iptables-persistent
        echo "Install Success,Enjoy it!"
        break
        ;;
      2)      
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
        echo "installing trojan-gfw"
        installtrojan-gfw
        echo "installing nginx"
        installnginx
        echo "installing acme"
        installacme
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
        echo "Install Success,Enjoy it!"
        break
        ;;
      3)
        echo "Detecting OS version"
        osdist
        #oscodename
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
        #oscodename
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
