#!/bin/bash
if [[ $(id -u) != 0 ]]; then
    echo Please run this script as root.
    exit 1
fi

#######color code############
ERROR="31m"      # Error message
SUCCESS="32m"    # Success message
WARNING="33m"   # Warning message
INFO="93m"     # Info message

#############################

function prompt() {
    while true; do
        read -p "$1 [y/N] " yn
        case $yn in
            [Yy] ) return 0;;
            [Nn]|"" ) return 1;;
        esac
    done
}


colorEcho(){
    COLOR=$1
    echo -e "\033[${COLOR}${@:2}\033[0m"
}

isresolved(){
    if [ $# = 2 ]
    then
        myip=$2
    else
        myip=`curl http://dynamicdns.park-your-domain.com/getip`
    fi
    ips=(`nslookup $1 1.1.1.1 | grep -v 1.1.1.1 | grep Address | cut -d " " -f 2`)
    for ip in "${ips[@]}"
    do
        if [ $ip == $myip ]
        then
            return 0
        else
            continue
        fi
    done
    return 1
}

userinput(){
echo "Hello, "$USER".  This script will help you set up a trojan-gfw server."
colorEcho ${WARNING} "Please Enter your domain and press [ENTER]: "
read domain
  if [[ -z "$domain" ]]; then
    colorEcho ${ERROR} "INPUT ERROR! Please Enter your domain again and press [ENTER]: "
    read domain
  fi
colorEcho ${INFO} "It\'s nice to meet you $domain"
colorEcho ${WARNING} "Please Enter your desired password1 and press [ENTER]: "
read password1
  if [[ -z "$password1" ]]; then
    colorEcho ${ERROR} "INPUT ERROR! Please Enter your os password1 again and press [ENTER]: "
    read password1
  fi
colorEcho ${INFO} "Your password1 is $password1"
colorEcho ${WARNING} "Please Enter your desired password2 and press [ENTER]: "
read password2
  if [[ -z "$password2" ]]; then
    colorEcho ${ERROR} "INPUT ERROR! Please Enter your password2 again and press [ENTER]: "
    read password2
  fi
colorEcho ${INFO} "Your password2 is $password2"
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
    yum update -q
 elif [[ $dist = ubuntu ]]; then
    apt-get update -q
 elif [[ $dist = debian ]]; then
    apt-get update -q
 else
  clear
    colorEcho ${ERROR} "error can't update system"
    exit 1;
 fi
}

upgradesystem(){
	if [[ $dist = centos ]]; then
    yum upgrade -q -y
 elif [[ $dist = ubuntu ]]; then
     export DEBIAN_FRONTEND=noninteractive 
    apt-get upgrade -q -y
    apt-get autoremove -q -y
 elif [[ $dist = debian ]]; then
     export DEBIAN_FRONTEND=noninteractive 
    apt-get upgrade -q -y
    apt-get autoremove -q -y
 else
  clear
    colorEcho ${ERROR} "error can't upgrade system"
    exit 1;
 fi
}

openfirewall(){
  iptables -I INPUT -p tcp -m tcp --dport 443 -j ACCEPT
  iptables -I INPUT -p tcp -m tcp --dport 80 -j ACCEPT
  iptables -I OUTPUT -j ACCEPT
}

installdependency(){
	echo "installing trojan-gfw nginx and acme"
	if [[ $dist = centos ]]; then
    yum install sudo curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release python3-qrcode python-pil unzip -q -y
 elif [[ $dist = ubuntu ]]; then
    apt-get install sudo curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release python3-qrcode python-pil unzip -q -y
 elif [[ $dist = debian ]]; then
    apt-get install sudo curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release python3-qrcode python-pil unzip -q -y
 else
  clear
    colorEcho ${ERROR} "error can't install dependency"
    exit 1;
 fi
}

installtrojan-gfw(){
	bash -c "$(wget -O- https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"
}

nginxyum(){
	yum install nginx -q -y
}

nginxapt(){
	wget https://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
  touch /etc/apt/sources.list.d/nginx.list
  cat > '/etc/apt/sources.list.d/nginx.list' << EOF
deb https://nginx.org/packages/mainline/debian/ $(lsb_release -cs) nginx
deb-src https://nginx.org/packages/mainline/debian/ $(lsb_release -cs) nginx
EOF
	apt-get update -q
	apt-get install nginx -q -y
}

nginxubuntu(){
	wget https://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
  touch /etc/apt/sources.list.d/nginx.list
  cat > '/etc/apt/sources.list.d/nginx.list' << EOF
deb https://nginx.org/packages/mainline/ubuntu/ $(lsb_release -cs) nginx
deb-src https://nginx.org/packages/mainline/ubuntu/ $(lsb_release -cs) nginx
EOF
	apt-get update -q
	apt-get install nginx -q -y
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
    colorEcho ${ERROR} "error can't install nginx"
    exit 1;
 fi
}

installacme(){
	curl https://get.acme.sh | sh
  sudo ~/.acme.sh/acme.sh --upgrade --auto-upgrade
  rm -rf /etc/trojan/
	mkdir /etc/trojan/
}

issuecert(){
  systemctl start nginx
	sudo ~/.acme.sh/acme.sh --issue -d $domain --webroot /usr/share/nginx/html/ -k ec-256 --log
  #sudo ~/.acme.sh/acme.sh --issue --nginx /etc/nginx/conf.d/trojan.conf -d $domain -k ec-256 --log
}

renewcert(){
  sudo ~/.acme.sh/acme.sh --issue -d $domain --webroot /usr/share/nginx/html/ -k ec-256 --force --log
  #sudo ~/.acme.sh/acme.sh --issue --nginx /etc/nginx/conf.d/trojan.conf -d $domain -k ec-256 --log
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
rm -rf /etc/nginx/sites-available/*
rm -rf /etc/nginx/sites-enabled/*
rm -rf /etc/nginx/conf.d/*
touch /etc/nginx/conf.d/trojan.conf
  cat > '/etc/nginx/conf.d/trojan.conf' << EOF
server {
  listen 127.0.0.1:80;
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
    root /usr/share/nginx/html/; #needed for auto certificate renew
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
	systemctl enable nginx
	systemctl enable trojan
}

tcp-bbr(){
	echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.d/99-sysctl.conf
	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.d/99-sysctl.conf
	echo "net.ipv4.tcp_max_syn_backlog = 12800" >> /etc/sysctl.d/99-sysctl.conf
	sysctl -p
    cat > '/etc/systemd/system.conf' << EOF
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#
# Entries in this file show the compile time defaults.
# You can change settings by editing this file.
# Defaults can be restored by simply deleting this file.
#
# See systemd-system.conf(5) for details.

[Manager]
#LogLevel=info
#LogTarget=journal-or-kmsg
#LogColor=yes
#LogLocation=no
#DumpCore=yes
#ShowStatus=yes
#CrashChangeVT=no
#CrashShell=no
#CrashReboot=no
#CtrlAltDelBurstAction=reboot-force
#CPUAffinity=1 2
#RuntimeWatchdogSec=0
#ShutdownWatchdogSec=10min
#WatchdogDevice=
#CapabilityBoundingSet=
#NoNewPrivileges=no
#SystemCallArchitectures=
#TimerSlackNSec=
#DefaultTimerAccuracySec=1min
#DefaultStandardOutput=journal
#DefaultStandardError=inherit
#DefaultTimeoutStartSec=90s
DefaultTimeoutStopSec=30s
#DefaultRestartSec=100ms
#DefaultStartLimitIntervalSec=10s
#DefaultStartLimitBurst=5
#DefaultEnvironment=
#DefaultCPUAccounting=no
#DefaultIOAccounting=no
#DefaultIPAccounting=no
#DefaultBlockIOAccounting=no
#DefaultMemoryAccounting=yes
#DefaultTasksAccounting=yes
#DefaultTasksMax=
#DefaultLimitCPU=
#DefaultLimitFSIZE=
#DefaultLimitDATA=
#DefaultLimitSTACK=
#DefaultLimitCORE=
#DefaultLimitRSS=
#DefaultLimitNOFILE=1024:524288
#DefaultLimitAS=
#DefaultLimitNPROC=
#DefaultLimitMEMLOCK=
#DefaultLimitLOCKS=
#DefaultLimitSIGPENDING=
#DefaultLimitMSGQUEUE=
#DefaultLimitNICE=
#DefaultLimitRTPRIO=
#DefaultLimitRTTIME=
DefaultLimitCORE=infinity
DefaultLimitNOFILE=51200
DefaultLimitNPROC=51200
EOF
    cat > '/etc/security/limits.conf' << EOF
# /etc/security/limits.conf
#
#Each line describes a limit for a user in the form:
#
#<domain>        <type>  <item>  <value>
#
#Where:
#<domain> can be:
#        - a user name
#        - a group name, with @group syntax
#        - the wildcard *, for default entry
#        - the wildcard %, can be also used with %group syntax,
#                 for maxlogin limit
#        - NOTE: group and wildcard limits are not applied to root.
#          To apply a limit to the root user, <domain> must be
#          the literal username root.
#
#<type> can have the two values:
#        - "soft" for enforcing the soft limits
#        - "hard" for enforcing hard limits
#
#<item> can be one of the following:
#        - core - limits the core file size (KB)
#        - data - max data size (KB)
#        - fsize - maximum filesize (KB)
#        - memlock - max locked-in-memory address space (KB)
#        - nofile - max number of open file descriptors
#        - rss - max resident set size (KB)
#        - stack - max stack size (KB)
#        - cpu - max CPU time (MIN)
#        - nproc - max number of processes
#        - as - address space limit (KB)
#        - maxlogins - max number of logins for this user
#        - maxsyslogins - max number of logins on the system
#        - priority - the priority to run user process with
#        - locks - max number of file locks the user can hold
#        - sigpending - max number of pending signals
#        - msgqueue - max memory used by POSIX message queues (bytes)
#        - nice - max nice priority allowed to raise to values: [-20, 19]
#        - rtprio - max realtime priority
#        - chroot - change root to directory (Debian-specific)
#
#<domain>      <type>  <item>         <value>
#

#*               soft    core            0
#root            hard    core            100000
#*               hard    rss             10000
#@student        hard    nproc           20
#@faculty        soft    nproc           20
#@faculty        hard    nproc           50
#ftp             hard    nproc           0
#ftp             -       chroot          /ftp
#@student        -       maxlogins       4

# End of file
* soft nofile 51200
* hard nofile 51200
EOF
    cat > '/etc/profile' << EOF
# /etc/profile: system-wide .profile file for the Bourne shell (sh(1))
# and Bourne compatible shells (bash(1), ksh(1), ash(1), ...).

if [ "${PS1-}" ]; then
  if [ "${BASH-}" ] && [ "$BASH" != "/bin/sh" ]; then
    # The file bash.bashrc already sets the default PS1.
    # PS1='\h:\w\$ '
    if [ -f /etc/bash.bashrc ]; then
      . /etc/bash.bashrc
    fi
  else
    if [ "`id -u`" -eq 0 ]; then
      PS1='# '
    else
      PS1='$ '
    fi
  fi
fi

if [ -d /etc/profile.d ]; then
  for i in /etc/profile.d/*.sh; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi
ulimit -SHn 51200
EOF
systemctl daemon-reload
}

iptables-persistent(){
  if [[ $dist = centos ]]; then
    yum install iptables-persistent -q -y
 elif [[ $dist = ubuntu ]]; then
     export DEBIAN_FRONTEND=noninteractive 
    apt-get install iptables-persistent -q -y
 elif [[ $dist = debian ]]; then
     export DEBIAN_FRONTEND=noninteractive 
    apt-get install iptables-persistent -q -y
 else
  clear
    colorEcho ${ERROR} "error can't install iptables-persistent"
    exit 1;
 fi
}
###########Trojan share link########
sharelink(){
  cd
  wget https://github.com/trojan-gfw/trojan-url/raw/master/trojan-url.py
  ./trojan-url.py -i /etc/trojan/client.json
  echo "Your Trojan-Gfw Share link1 is: trojan://$password1@$domain:443"
  echo "Your Trojan-Gfw Share link1 is: trojan://$password2@$domain:443"
  echo ""
}

############Set UP V2ray############
v2input(){
echo "Hello, "$USER".  This script will help you set up a trojan-gfw server."
colorEcho ${WARNING} "Please Enter your domain and press [ENTER]: "
read domain
  if [[ -z "$domain" ]]; then
    colorEcho ${ERROR} "INPUT ERROR! Please Enter your domain again and press [ENTER]: "
    read domain
  fi
colorEcho ${INFO} "It\'s nice to meet you $domain"
colorEcho ${WARNING} "Please Enter your desired password1 and press [ENTER]: "
read password1
  if [[ -z "$password1" ]]; then
    colorEcho ${ERROR} "INPUT ERROR! Please Enter your os password1 again and press [ENTER]: "
    read password1
  fi
colorEcho ${INFO} "Your password1 is $password1"
colorEcho ${WARNING} "Please Enter your desired password2 and press [ENTER]: "
read password2
  if [[ -z "$password2" ]]; then
    colorEcho ${ERROR} "INPUT ERROR! Please Enter your password2 again and press [ENTER]: "
    read password2
  fi
colorEcho ${INFO} "Your password2 is $password2"
colorEcho ${WARNING} "Please Enter your desired Websocket path and press [ENTER]: "
read path
colorEcho ${INFO} "Your path is $path"
}
installv2ray(){
  bash <(curl -L -s https://install.direct/go.sh)
  rm -rf /etc/v2ray/config.json
  colorEcho ${INFO} "generating random uuid"
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
  rm go.sh
}
###########Remove Nginx and acme###############
removenginx(){
  systemctl stop nginx
  systemctl disable nginx
  apt purge nginx -p -y
  sudo ~/.acme.sh/acme.sh --uninstall
}
##########Check for update############
checkupdate(){
  cd
  wget https://install.direct/go.sh
  sudo bash go.sh --check
  rm go.sh
  bash -c "$(wget -O- https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"
}
######################################
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
3. Check update for Trojan-gfw or V2ray
4. Install Trojan-Gfw only (If you'd like to manually set up web servers other than nginx)
5. Install Nginx only (If you'd like to set up Trojan-gfw manually)
6. Force renew certificate (If you don't trust autorenew)
7. Remove Trojan-Gfw
8. Remove V2ray
9. Uninstall everything
0. Quit

_EOF_

  read -p "Enter selection [0-9] > "

  if [[ $REPLY =~ ^[0-9]$ ]]; then
    case $REPLY in
      1)
        clear
        userinput
        clear
        colorEcho ${INFO} "Detecting OS version"
        osdist
        colorEcho ${INFO} "Your os codename is $dist $(lsb_release -cs)"
        colorEcho ${INFO} "Updating system"
        updatesystem
        colorEcho ${WARNING} "Upgrade system may cause unwanted bugs...,continue?"
        if ! [[ -n "$dist" ]] || prompt ${WARNING} "continue?"; then
        colorEcho ${INFO} "Upgrading system"
        upgradesystem
        else
        echo Skipping system upgrade...
        fi
        colorEcho ${INFO} "installing dependency"
        installdependency       
        if isresolved $domain
        then
        :
        else 
        colorEcho ${ERROR} "Resolve error,Please check your domain DNS config and vps firewall !"
        exit -1
        clear
        fi
        colorEcho ${INFO} "configing firewall"
        openfirewall
        clear
        colorEcho ${INFO} "installing trojan-gfw"
        installtrojan-gfw
        clear
        colorEcho ${INFO} "installing nginx"
        installnginx
        clear
        colorEcho ${INFO} "installing acme"
        installacme
        clear
        colorEcho ${INFO} "autoconfiging nginx"
        nginxtrojan
        clear
        colorEcho ${INFO} "issueing let\'s encrypt certificate"
        issuecert
        clear
        colorEcho ${INFO} "issue complete,installing certificate"
        installcert
        clear
        colorEcho ${INFO} "certificate install complete!"
        colorEcho ${INFO} "giving private key read authority"
        installkey
        clear
        colorEcho ${INFO} "autoconfiging trojan-gfw"
        changepasswd
        clear
        colorEcho ${INFO} "starting trojan-gfw and nginx | setting up boot autostart"
        autostart
        clear
        colorEcho ${INFO} "Setting up tcp-bbr boost technology"
        tcp-bbr
        clear
        iptables-persistent
        clear
        trojanclient
        colorEcho ${INFO} "Your Trojan-Gfw client config"
        cat /etc/trojan/client.json
        colorEcho ${INFO} "https://github.com/trojan-gfw/trojan/wiki/Mobile-Platforms"
        colorEcho ${INFO} "https://github.com/trojan-gfw/trojan/releases/latest"        
        colorEcho ${SUCCESS} "Install Success,Enjoy it!"
        break
        ;;
      2)
        clear      
        v2input
        clear
        colorEcho ${INFO} "Detecting OS version"
        osdist
        colorEcho ${INFO} "Your os codename is $dist $(lsb_release -cs)"
        colorEcho ${INFO} "Updating system"
        updatesystem
        colorEcho ${WARNING} "Upgrade system may cause unwanted bugs...,continue?"
        if ! [[ -n "$dist" ]] || prompt ${WARNING} "continue?"; then
        colorEcho ${INFO} "Upgrading system"
        upgradesystem
        else
        echo Skipping system upgrade...
        fi
        colorEcho ${INFO} "installing dependency"
        installdependency
        if isresolved $domain
        then
        :
        else 
        colorEcho ${ERROR} "Resolve error,Please check your domain DNS config and vps firewall !"
        exit -1
        fi
        colorEcho ${INFO} "configing firewall"
        openfirewall
        clear
        colorEcho ${INFO} "installing trojan-gfw"
        installtrojan-gfw
        colorEcho ${INFO} "installing nginx"
        installnginx
        colorEcho ${INFO} "installing acme"
        installacme
        clear
        colorEcho ${INFO} "configing v2ray vmess+tls+Websocket"
        nginxv2ray
        clear
        colorEcho ${INFO} "issueing let\'s encrypt certificate"
        issuecert
        colorEcho ${INFO} "issueing let\'s encrypt certificate"
        installcert
        colorEcho ${INFO} "certificate install complete!"
        colorEcho ${INFO} "giving private key read authority"
        installkey
        changepasswd
        colorEcho ${INFO} "installing V2ray"
        installv2ray
        colorEcho ${INFO} "starting trojan-gfw v2ray and nginx | setting up boot autostart"
        autostart
        colorEcho ${INFO} "Setting up tcp-bbr boost technology"
        tcp-bbr
        iptables-persistent
        clear
        trojanclient
        colorEcho ${INFO} "Your Trojan-Gfw client config"
        cat /etc/trojan/client.json
        colorEcho ${INFO} "https://github.com/trojan-gfw/trojan/wiki/Mobile-Platforms"
        colorEcho ${INFO} "https://github.com/trojan-gfw/trojan/releases/latest"
        v2rayclient
        colorEcho ${INFO} "Your V2ray client config"
        cat /etc/v2ray/client.json
        colorEcho ${INFO} "https://github.com/v2ray/v2ray-core/releases/latest"
        colorEcho ${INFO} "Install Success,Enjoy it!"
        break
        ;;
      3)
        checkupdate
        break
        ;;
      4)
        colorEcho ${INFO} "Detecting OS version"
        osdist
        colorEcho ${INFO} "Your os codename is $dist"
        colorEcho ${INFO} "Updating system"
        updatesystem
        if ! [[ -n "$dist" ]] || prompt ${WARNING} "Upgrade system may cause unwanted bugs...,continue?"; then
        colorEcho ${INFO} "Upgrading system"
        upgradesystem
        else
        echo Skipping system upgrade...
        fi
        colorEcho ${INFO} "configing firewall"
        openfirewall
        colorEcho ${INFO} "installing dependency"
        installdependency
        colorEcho ${INFO} "installing trojan-gfw"
        installtrojan-gfw
        break
        ;;
      5)
        colorEcho ${INFO} "Detecting OS version"
        osdist
        colorEcho ${INFO} "Your os codename is $dist"
        colorEcho ${INFO} "Updating system"
        updatesystem
        if ! [[ -n "$dist" ]] || prompt ${WARNING} "Upgrade system may cause unwanted bugs...,continue?"; then
        colorEcho ${INFO} "Upgrading system"
        upgradesystem
        else
        echo Skipping system upgrade...
        fi
        colorEcho ${INFO} "configing firewall"
        openfirewall
        colorEcho ${INFO} "installing dependency"
        installdependency
        colorEcho ${INFO} "installing nginx"
        installnginx
        break
        ;;
      6)
        userinput
        osdist
        installdependency
        if isresolved $domain
        then
        :
        else 
        colorEcho ${ERROR} "Resolve error,Please check your domain DNS config and vps firewall !"
        exit -1
        fi
        renewcert
        break
        ;;
      7)
        removetrojan
        colorEcho ${SUCCESS} "Remove complete"
        break
        ;;
      8)
        removev2ray
        colorEcho ${SUCCESS} "Remove complete"
        break
        ;;
      9)
        removetrojan
        removev2ray
        removenginx
        colorEcho ${SUCCESS} "Remove complete"
        break
        ;;          
      0)
        break
        ;;
    esac
  else
    colorEcho ${ERROR} "Invalid entry."
    sleep $DELAY
  fi
done
echo "Program terminated."
