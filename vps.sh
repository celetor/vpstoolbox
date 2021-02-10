#!/usr/bin/env bash
# VPSTOOLBOX

# 一键安装Trojan-GFW代理,Hexo博客,Nextcloud等應用程式.
# One click install Trojan-gfw Hexo Nextcloud and so on.

# MIT License
#
# Copyright (c) 2019-2021 JohnRosen

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#如果你在使用VPSToolBox时遇到任何问题,请仔细阅读README.md/code或者**通过 [Telegram](https://t.me/vpstoolbox_chat)请求支援** !                                  

clear

set +e

#System Requirement
if [[ $(id -u) != 0 ]]; then
  echo -e "请使用root或者sudo用户运行,Please run this script as root or sudoer."
  exit 1
fi

if [[ $(uname -m 2> /dev/null) != x86_64 ]]; then
  echo -e "本程式仅适用于x86_64机器,Please run this script on x86_64 machine."
  exit 1
fi

if [[ $(free -m  | grep Mem | awk '{print $2}' 2> /dev/null) -le "100" ]]; then
  echo -e "本程式需要至少100MB记忆体才能正常运作,Please run this script on machine with more than 100MB total ram."
  exit 1
fi

if [[ $(df $PWD | awk '/[0-9]%/{print $(NF-2)}' 2> /dev/null) -le "3000000" ]]; then
  echo -e "本程式需要至少3GB磁碟空间才能正常运作,Please run this script on machine with more than 3G free disk space."
  exit 1
fi

#Do not show user interface for apt
export DEBIAN_FRONTEND=noninteractive

# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
###Legacy Defined Colors
ERROR="31m"      # Error message
SUCCESS="32m"    # Success message
WARNING="33m"   # Warning message
INFO="36m"     # Info message
LINK="92m"     # Share Link Message

#Predefined install,do not change!!!
install_bbr=1
install_nodejs=1
install_trojan=1
trojanport="443"
tcp_fastopen="false"

#predefined env,do not change!!!
export COMPOSER_ALLOW_SUPERUSER=1

if [[ -d /usr/local/qcloud ]]; then
  #disable tencent cloud process
  rm -rf /usr/local/sa
  rm -rf /usr/local/agenttools
  rm -rf /usr/local/qcloud
  #disable huawei cloud process
  rm -rf /usr/local/telescope
fi

#Disable cloud-init
rm -rf /lib/systemd/system/cloud*

colorEcho(){
  set +e
  COLOR=$1
  echo -e "\033[${COLOR}${@:2}\033[0m"
}

#Set system language
setlanguage(){
  set +e
  if [[ ! -d /root/.trojan/ ]]; then
    mkdir /root/.trojan/
    mkdir /etc/certs/
  fi
  if [[ -f /root/.trojan/language.json ]]; then
    language="$( jq -r '.language' "/root/.trojan/language.json" )"
  fi
  while [[ -z $language ]]; do
  export LANGUAGE="C.UTF-8"
  export LANG="C.UTF-8"
  export LC_ALL="C.UTF-8"
  if (whiptail --title "System Language Setting" --yes-button "中文" --no-button "English" --yesno "使用中文或英文(Use Chinese or English)?" 8 68); then
  chattr -i /etc/locale.gen
  cat > '/etc/locale.gen' << EOF
zh_TW.UTF-8 UTF-8
en_US.UTF-8 UTF-8
EOF
language="cn"
locale-gen
update-locale
chattr -i /etc/default/locale
  cat > '/etc/default/locale' << EOF
LANGUAGE="zh_TW.UTF-8"
LANG="zh_TW.UTF-8"
LC_ALL="zh_TW.UTF-8"
EOF
#apt-get install manpages-zh -y
  cat > '/root/.trojan/language.json' << EOF
{
  "language": "$language"
}
EOF
  else
  chattr -i /etc/locale.gen
  cat > '/etc/locale.gen' << EOF
zh_TW.UTF-8 UTF-8
en_US.UTF-8 UTF-8
EOF
language="en"
locale-gen
update-locale
chattr -i /etc/default/locale
  cat > '/etc/default/locale' << EOF
LANGUAGE="en_US.UTF-8"
LANG="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
EOF
  cat > '/root/.trojan/language.json' << EOF
{
  "language": "$language"
}
EOF
fi
done
if [[ $language == "cn" ]]; then
export LANGUAGE="zh_TW.UTF-8"
export LANG="zh_TW.UTF-8"
export LC_ALL="zh_TW.UTF-8"
  else
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
fi
}

#install acme.sh
installacme(){
  set +e
  curl -s https://get.acme.sh | sh
  if [[ $? != 0 ]]; then
    colorEcho ${ERROR} "安装acme.sh失败，请自行检查网络连接及DNS配置!"
    colorEcho ${ERROR} "Install acme.sh fail,please check your internet availability!!!"
    exit 1
  fi
  ~/.acme.sh/acme.sh --upgrade --auto-upgrade
}

#Set json file before and after installation
prasejson(){
  set +e
  cat > '/root/.trojan/config.json' << EOF
{
  "installed": "1",
  "domain": "$domain",
  "password1": "$password1",
  "password2": "$password2",
  "qbtpath": "$qbtpath",
  "trackerpath": "$trackerpath",
  "trackerstatuspath": "$trackerstatuspath",
  "ariapath": "$ariapath",
  "ariapasswd": "$ariapasswd",
  "filepath": "$filepath",
  "check_trojan": "$check_trojan",
  "check_tjp": "$check_tjp",
  "check_dns": "$check_dns",
  "check_rss": "$check_rss",
  "check_qbt": "$check_qbt",
  "check_aria": "$check_aria",
  "check_file": "$check_file",
  "check_speed": "$check_speed",
  "check_mariadb": "$check_mariadb",
  "check_fail2ban": "$check_fail2ban",
  "check_mail": "$check_mail",
  "check_qbt_origin": "$check_qbt_origin",
  "check_tracker": "$check_tracker",
  "check_cloud": "$check_cloud",
  "check_tor": "$check_tor",
  "check_i2p": "$check_i2p",
  "fastopen": "${fastopen}",
  "tor_name": "$tor_name"
}
EOF
}

#Read var from json
readconfig(){
  domain="$( jq -r '.domain' "/root/.trojan/config.json" )"
  password2="$( jq -r '.password2' "/root/.trojan/config.json" )"
  password1="$( jq -r '.password1' "/root/.trojan/config.json" )"
  qbtpath="$( jq -r '.qbtpath' "/root/.trojan/config.json" )"
  trackerpath="$( jq -r '.trackerpath' "/root/.trojan/config.json" )"
  trackerstatuspath="$( jq -r '.username' "/root/.trojan/config.json" )"
  ariapath="$( jq -r '.ariapath' "/root/.trojan/config.json" )"
  ariapasswd="$( jq -r '.ariapasswd' "/root/.trojan/config.json" )"
  filepath="$( jq -r '.filepath' "/root/.trojan/config.json" )"
  netdatapath="$( jq -r '.netdatapath' "/root/.trojan/config.json" )"
  tor_name="$( jq -r '.tor_name' "/root/.trojan/config.json" )"
  check_trojan="$( jq -r '.check_trojan' "/root/.trojan/config.json" )"
  check_tjp="$( jq -r '.check_tjp' "/root/.trojan/config.json" )"
  check_dns="$( jq -r '.check_dns' "/root/.trojan/config.json" )"
  check_rss="$( jq -r '.check_rss' "/root/.trojan/config.json" )"
  check_qbt="$( jq -r '.check_qbt' "/root/.trojan/config.json" )"
  check_aria="$( jq -r '.check_aria' "/root/.trojan/config.json" )"
  check_file="$( jq -r '.check_file' "/root/.trojan/config.json" )"
  check_speed="$( jq -r '.check_speed' "/root/.trojan/config.json" )"
  check_mariadb="$( jq -r '.check_mariadb' "/root/.trojan/config.json" )"
  check_fail2ban="$( jq -r '.check_fail2ban' "/root/.trojan/config.json" )"
  check_mail="$( jq -r '.check_mail' "/root/.trojan/config.json" )"
  check_qbt_origin="$( jq -r '.check_qbt_origin' "/root/.trojan/config.json" )"
  check_tracker="$( jq -r '.check_tracker' "/root/.trojan/config.json" )"
  check_cloud="$( jq -r '.check_cloud' "/root/.trojan/config.json" )"
  check_tor="$( jq -r '.check_tor' "/root/.trojan/config.json" )"
  check_chat="$( jq -r '.check_chat' "/root/.trojan/config.json" )"
  check_i2p="$( jq -r '.check_i2p' "/root/.trojan/config.json" )"
  fastopen="$( jq -r '.fastopen' "/root/.trojan/config.json" )"
}

#User input
userinput(){
set +e
clear
if [[ ${install_status} == 1 ]]; then
  if (whiptail --title "Installed" --yes-button "读取" --no-button "修改" --yesno "检测到现有配置，读取/修改现有配置?(Installed,read configuration?)" 8 68); then
    readconfig
    else
    check_trojan="on"
    check_tjp="off"
    check_dns="off"
    check_rss="off"
    check_qbt="off"
    check_aria="off"
    check_file="off"
    check_speed="off"
    check_mariadb="off"
    check_fail2ban="off"
    check_mail="off"
    check_qbt_origin="off"
    check_tracker="off"
    check_cloud="off"
    check_tor="off"
    check_chat="off"
    fastopen="on"
    stun="off"
  fi
fi

if [[ -z ${check_trojan} ]]; then
  check_trojan="on"
fi
if [[ -z ${check_dns} ]]; then
  check_dns="off"
fi
if [[ -z ${check_rss} ]]; then
  check_rss="off"
fi
if [[ -z ${check_chat} ]]; then
  check_chat="off"
fi
if [[ -z ${check_qbt} ]]; then
  check_qbt="off"
fi
if [[ -z ${check_aria} ]]; then
  check_aria="off"
fi
if [[ -z ${check_file} ]]; then
  check_file="off"
fi
if [[ -z ${check_speed} ]]; then
  check_speed="off"
fi
if [[ -z ${check_mariadb} ]]; then
  check_mariadb="off"
fi
if [[ -z ${check_fail2ban} ]]; then
  check_fail2ban="off"
fi
if [[ -z ${check_mail} ]]; then
  check_mail="off"
fi
if [[ -z ${check_qbt_origin} ]]; then
  check_qbt_origin="off"
fi
if [[ -z ${check_tracker} ]]; then
  check_tracker="off"
fi
if [[ -z ${check_cloud} ]]; then
  check_cloud="off"
fi
if [[ -z ${check_tor} ]]; then
  check_tor="off"
fi
if [[ -z ${check_i2p} ]]; then
  check_i2p="off"
fi
if [[ -z ${check_tjp} ]]; then
  check_tjp="off"
fi
if [[ -z ${fastopen} ]]; then
  fastopen="on"
fi
if [[ -z ${stun} ]]; then
  stun="off"
fi

whiptail --clear --ok-button "下一步" --backtitle "Hi,请按空格以及方向键来选择需要安装/更新的软件,请自行下拉以查看更多(Please press space and Arrow keys to choose)" --title "Install checklist" --checklist --separate-output --nocancel "请按空格及方向键来选择需要安装/更新的软件。" 24 65 16 \
"Back" "返回上级菜单(Back to main menu)" off \
"trojan" "Trojan-GFW+TCP-BBR+Hexo Blog" on \
"net" "Netdata(监测伺服器运行状态)" on \
"fast" "TCP Fastopen" ${fastopen} \
"tjp" "Trojan-panel" ${check_tjp} \
"nextcloud" "Nextcloud(私人网盘)" ${check_cloud} \
"rss" "RSSHUB + TT-RSS(RSS生成器+RSS阅读器)" ${check_rss} \
"mail" "Mail service(邮箱服务,需2g+内存)" ${check_mail} \
"chat" "Rocket Chat" ${check_chat} \
"qbt" "Qbittorrent增强版(可全自动屏蔽吸血行为)" ${check_qbt} \
"aria" "Aria2下载器" ${check_aria} \
"file" "Filebrowser(用于拉回Qbt/aria下载完成的文件)" ${check_file} \
"speed" "Speedtest(测试本地网络到VPS的延迟及带宽)" ${check_speed} \
"fail2ban" "Fail2ban(防SSH爆破用)" ${check_fail2ban} \
"i2p" "自建i2p网站" ${check_i2p} \
"tor" "自建onion网站" ${check_tor} \
"stun" "stunserver(用于测试nat类型)" ${stun} \
"dns" "Dnscrypt-proxy(Doh客户端)" ${check_dns} \
"7" "MariaDB数据库" ${check_mariadb} \
"redis" "Redis缓存数据库" off \
"其他" "以下选项请勿选中,除非必要(Others)" off  \
"port" "自定义Trojan端口(除nat机器外请勿选中)" ${check_qbt_origin} \
"10" "Bt-Tracker(Bittorrent-tracker服务)" ${check_tracker} \
"13" "Qbt原版(除PT站指明要求,请勿选中)" ${check_qbt_origin} \
"test-only" "test-only" off 2>results

while read choice
do
  case $choice in
    Back) 
    advancedMenu
    break
    ;;
    trojan)
    install_trojan=1
    install_bbr=1
    ;;
    stun)
    install_stun="1"
    ;;
    dns)
    dnsmasq_install=1
    ;;
    fast)
    tcp_fastopen="true"
    ;;
    chat)
    install_chat=1
    install_docker=1
    ;;
    tjp)
    install_tjp=1
    install_php=1
    install_mariadb=1
    install_redis=1
    ;;
    net)
    install_netdata=1
    ;;
    nextcloud)
    install_nextcloud=1
    install_php=1
    install_mariadb=1
    install_redis=1
    ;;
    redis)
    install_redis=1
    ;;
    rss)
    check_rss="on"
    install_rsshub=1
    install_redis=1
    install_php=1
    install_mariadb=1
    ;;
    qbt)
    check_qbt="on"
    install_qbt=1
    ;;
    aria)
    check_aria="on"
    install_aria=1
    ;;
    file)
    check_file="on"
    install_file=1
    ;;
    speed)
    check_speed="on"
    install_speedtest=1
    install_php=1
    ;;
    7)
    check_mariadb="on"
    install_mariadb=1
    ;;
    fail2ban)
    check_fail2ban="on"
    install_fail2ban=1
    ;;
    mail)
    check_mail="on"
    install_mail=1
    install_php=1
    install_mariadb=1
    ;;
    10)
    check_tracker="on"
    install_tracker=1
    ;;
    11) 
    install_tjp=1
    install_php=1
    install_nodejs=1
    install_mariadb=1
    ;;
    tor)
    install_tor=1
    ;;
    i2p)
    install_i2p=1
    ;;
    13)
    check_qbt_origin="on"
    install_qbt_origin=1
    ;;
    port)
    trojan_other_port=1
    ;;
    *)
    ;;
  esac
done < results

rm results

if [[ ${trojan_other_port} == 1 ]]; then
  trojanport=$(whiptail --inputbox --nocancel "Trojan-GFW 端口(若不確定，請直接回車)" 8 68 443 --title "port input" 3>&1 1>&2 2>&3)
  if [[ -z ${trojanport} ]]; then
  trojanport="443"
  fi
fi

system_upgrade=1
if [[ ${system_upgrade} == 1 ]]; then
  if [[ $(lsb_release -cs) == jessie ]]; then
      debian9_install=1
  fi
  if [[ $(lsb_release -cs) == xenial ]]; then
      ubuntu18_install=1
  fi
fi

while [[ -z ${domain} ]]; do
domain=$(whiptail --inputbox --nocancel "请輸入你的域名,例如 example.com(请先完成A/AAAA解析) | Please enter your domain" 8 68 --title "Domain input" 3>&1 1>&2 2>&3)
TERM=ansi whiptail --title "检测中" --infobox "检测域名是否合法中..." 7 68
colorEcho ${INFO} "Checking if domain is vaild."
host ${domain}
if [[ $? != 0 ]]; then
  whiptail --title "Warning" --msgbox "Warning: Invaild Domain" 8 68
  domain=""
  clear
fi
done
clear
hostnamectl set-hostname ${domain}
echo "${domain}" > /etc/hostname
rm -rf /etc/dhcp/dhclient.d/google_hostname.sh
rm -rf /etc/dhcp/dhclient-exit-hooks.d/google_set_hostname
echo "" >> /etc/hosts
echo "$(jq -r '.ip' "/root/.trojan/ip.json") ${domain}" >> /etc/hosts
if [[ ${install_trojan} = 1 ]]; then
  while [[ -z ${password1} ]]; do
password1=$(whiptail --passwordbox --nocancel "Trojan-GFW Password One(推荐自定义密码,***请勿添加特殊符号***)" 8 68 --title "password1 input" 3>&1 1>&2 2>&3)
if [[ -z ${password1} ]]; then
password1=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
fi
done
while [[ -z ${password2} ]]; do
password2=$(whiptail --passwordbox --nocancel "Trojan-GFW Password Two(若不確定，請直接回車，会随机生成)" 8 68 --title "password2 input" 3>&1 1>&2 2>&3)
if [[ -z ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
done
fi
if [[ ${password1} == ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
if [[ -z ${password1} ]]; then
  password1=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
if [[ -z ${password2} ]]; then
  password2=$(head /dev/urandom | tr -dc a-z0-9 | head -c 9 ; echo '' )
  fi
  if [[ ${install_mail} == 1 ]]; then
  mailuser=$(whiptail --inputbox --nocancel "Please enter your desired mailusername(邮箱用户名)" 8 68 admin --title "Mail user input" 3>&1 1>&2 2>&3)
  if [[ -z ${mailuser} ]]; then
  mailuser=$(head /dev/urandom | tr -dc a-z | head -c 4 ; echo '' )
  fi
fi
  if [[ $install_qbt = 1 ]]; then
    while [[ -z $qbtpath ]]; do
    qbtpath=$(whiptail --inputbox --nocancel "Qbittorrent Nginx Path(路径)" 8 68 /qbt/ --title "Qbittorrent path input" 3>&1 1>&2 2>&3)
    done
  fi
  if [[ ${install_aria} == 1 ]]; then
    ariaport=$(shuf -i 13000-19000 -n 1)
    while [[ -z ${ariapath} ]]; do
    ariapath=$(whiptail --inputbox --nocancel "Aria2 RPC Nginx Path(路径)" 8 68 /aria2/ --title "Aria2 path input" 3>&1 1>&2 2>&3)
    done
    while [[ -z $ariapasswd ]]; do
    ariapasswd=$(whiptail --passwordbox --nocancel "Aria2 rpc token(密码)" 8 68 --title "Aria2 rpc token input" 3>&1 1>&2 2>&3)
    if [[ -z ${ariapasswd} ]]; then
    ariapasswd=$(head /dev/urandom | tr -dc 0-9 | head -c 10 ; echo '' )
    fi
    done
  fi
  if [[ ${install_file} = 1 ]]; then
    while [[ -z ${filepath} ]]; do
    filepath=$(whiptail --inputbox --nocancel "Filebrowser Nginx 路径" 8 68 /file/ --title "Filebrowser path input" 3>&1 1>&2 2>&3)
    done
  fi
  if [[ ${install_netdata} = 1 ]]; then
    while [[ -z ${netdatapath} ]]; do
    netdatapath=$(whiptail --inputbox --nocancel "Netdata Nginx 路径" 8 68 /${password1}_netdata/ --title "Netdata path input" 3>&1 1>&2 2>&3)
    done
  fi
}
###############OS detect####################
initialize(){
set +e
TERM=ansi whiptail --title "初始化中(initializing)" --infobox "初始化中...(initializing)" 7 68
if [[ -f /etc/sysctl.d/60-disable-ipv6.conf ]]; then
  mv /etc/sysctl.d/60-disable-ipv6.conf /etc/sysctl.d/60-disable-ipv6.conf.bak
fi
if cat /etc/*release | grep ^NAME | grep -q Ubuntu; then
  dist=ubuntu
  if [[ -f /etc/sysctl.d/60-disable-ipv6.conf.bak ]]; then
    sed -i 's/#//g' /etc/netplan/01-netcfg.yaml
    netplan apply
  fi
  apt-get update
  apt-get install sudo whiptail curl dnsutils locales lsb-release jq -y
 elif cat /etc/*release | grep ^NAME | grep -q Debian; then
  dist=debian
  apt-get update
  apt-get install sudo whiptail curl dnsutils locales lsb-release jq -y
 else
  whiptail --title "OS not supported(操作系统不支援)" --msgbox "Please use Debian or Ubuntu to run this project.(请使用Debian或者Ubuntu运行本项目)" 8 68
  echo "OS not supported(操作系统不支援),Please use Debian or Ubuntu to run this project.(请使用Debian或者Ubuntu运行本项目)"
  exit 1;
fi
}

##########install dependencies#############
installdependency(){
  set +e
  TERM=ansi whiptail --title "安装中" --infobox "安装所有必备软件中..." 7 68
colorEcho ${INFO} "Updating system"
apt-get update
clear
colorEcho ${INFO} "Installing all necessary Software"
apt-get install sudo git curl xz-utils wget apt-transport-https gnupg lsb-release python-pil unzip resolvconf ntpdate systemd dbus ca-certificates locales iptables software-properties-common cron e2fsprogs less haveged neofetch -q -y
apt-get install python3-qrcode python-dnspython -q -y
sh -c 'echo "y\n\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get install ntp -q -y'
clear
}
########Nginx config##############
nginxtrojan(){
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
  listen 127.0.0.1:80 fastopen=20 reuseport default_server;
  listen 127.0.0.1:8888 fastopen=20 reuseport default_server;
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
    proxy_set_header Host \$http_host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
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
echo "        proxy_http_version 1.1;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forward-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
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
echo "    location /${password1}_webmail/ {" >> /etc/nginx/conf.d/default.conf
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
echo "        #proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        #proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
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
echo "        proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
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
echo "        proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
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
echo "    location $filepath {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:8081/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_i2p == 1 ]]; then
echo "    location /${password1}_i2p/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:7070/;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
fi
if [[ $install_tracker == 1 ]]; then
echo "    location /tracker/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        client_max_body_size 0;" >> /etc/nginx/conf.d/default.conf
echo "        index index.html;" >> /etc/nginx/conf.d/default.conf
echo "        alias /usr/share/nginx/tracker/;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location /tracker_stats/ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6969/;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Real-IP \$remote_addr;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> /etc/nginx/conf.d/default.conf
echo "        }" >> /etc/nginx/conf.d/default.conf
echo "    location ~ ^/announce$ {" >> /etc/nginx/conf.d/default.conf
echo "        #access_log off;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_pass http://127.0.0.1:6969;" >> /etc/nginx/conf.d/default.conf
echo "        proxy_set_header Host \$http_host;" >> /etc/nginx/conf.d/default.conf
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
echo "    listen 127.0.0.1:81 fastopen=20 reuseport;" >> /etc/nginx/conf.d/default.conf
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

start(){
  set +e
TERM=ansi whiptail --title "安装中" --infobox "启动Trojan-gfw中..." 7 68
  colorEcho ${INFO} "启动(starting) trojan-gfw ing..."
  systemctl daemon-reload
  if [[ $install_mariadb == 1 ]]; then
    systemctl restart mariadb
  fi
  if [[ $install_rsshub == 1 ]]; then
    systemctl restart rsshub
    systemctl restart rssfeed
  fi
  if [[ $install_trojan == 1 ]]; then
    systemctl restart trojan
  fi
}

advancedMenu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用VPSTOOLBOX。有關錯誤報告或更多信息，請訪問以下鏈接: https://github.com/johnrosen1/vpstoolbox 或者 https://t.me/vpstoolbox_chat。" --title "VPS ToolBox Menu" --menu --nocancel "Welcome to VPS Toolbox main menu,Please Choose an option 欢迎使用VPSTOOLBOX,请选择一个选项" 14 68 5 \
  "Install/Update" "安裝/更新/覆盖安装" \
  "Benchmark" "效能测试"\
  "Exit" "退出" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    Install/Update)
    clear
    install_status="$( jq -r '.installed' "/root/.trojan/config.json" )"
    if [[ $install_status != 1 ]]; then
    cp /etc/resolv.conf /etc/resolv.conf.bak1
    echo "nameserver 1.1.1.1" >> /etc/resolv.conf
    echo "nameserver 1.0.0.1" >> /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "nameserver 1.1.1.1" >> /etc/resolvconf/resolv.conf.d/base
    echo "nameserver 1.0.0.1" >> /etc/resolvconf/resolv.conf.d/base
    echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/base
    resolvconf -u
      prasejson
      if [[ $(systemctl is-active caddy) == active ]]; then
      systemctl stop caddy
      systemctl disable caddy
      fi
      if [[ $(systemctl is-active apache2) == active ]]; then
      systemctl stop apache2
      systemctl disable apache2
      fi
      if [[ $(systemctl is-active httpd) == active ]]; then
      systemctl stop httpd
      systemctl disable httpd
      fi
    fi
    userinput
    curl -s https://ipinfo.io?token=56c375418c62c9 --connect-timeout 300 > /root/.trojan/ip.json
    myip="$( jq -r '.ip' "/root/.trojan/ip.json" )"
    localip=$(ip -4 a | grep inet | grep "scope global" | awk '{print $2}' | cut -d'/' -f1)
    myipv6=$(ip -6 a | grep inet6 | grep "scope global" | awk '{print $2}' | cut -d'/' -f1)
    if [[ -n ${myipv6} ]]; then
    curl -s https://ipinfo.io/${myipv6}?token=56c375418c62c9 --connect-timeout 300 > /root/.trojan/ipv6.json
    fi
    #检测证书是否已有

    if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]]; then
      apt-get install gnutls-bin -y
      openfirewall
      certtool -i < /etc/certs/${domain}_ecc/fullchain.cer --verify --verify-hostname=${domain}
      if [[ $? != 0 ]]; then
        whiptail --title "ERROR" --msgbox "无效的证书,可能过期或者域名不正确,启动证书续签程序" 8 68
        /root/.acme.sh/acme.sh --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' >> /root/.trojan/letcron.log 2>&1
        fi
        crontab -l | grep acme.sh
        if [[ $? != 0 ]]; then
        colorEcho ${INFO} "CRON(证书续签模块)缺失,添加中..."
        crontab -l > mycron
        echo "0 0 * * 0 /root/.acme.sh/acme.sh --cron --cert-home /etc/certs --reloadcmd 'systemctl reload trojan postfix dovecot nginx || true' >> /root/.trojan/letcron.log 2>&1" >> mycron
        crontab mycron
        rm mycron        
        fi
    fi

    if [[ -f /etc/certs/${domain}_ecc/fullchain.cer ]] && [[ -f /etc/certs/${domain}_ecc/${domain}.key ]]; then
      colorEcho ${INFO} "证书已有,跳过申请(skipping cert issue)"
      else
        if (whiptail --title "Issue TLS Cert" --yes-button "HTTP申请" --no-button "DNS API申请" --yesno "使用 (use) API/HTTP申请证书(to issue certificate)?" 8 68); then
        httpissue=1
        else
        dnsissue
        fi
      fi
    TERM=ansi whiptail --title "开始安装" --infobox "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!" 7 68
    colorEcho ${INFO} "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!"
    upgradesystem
    if [[ ${httpissue} == 1 ]]; then
      httpissue
    fi
    installdependency
    installhexo
    nginxtrojan
    start
    prasejson
    autoupdate
    apt-get purge python-pil python3-qrcode -q -y
    apt-get autoremove -y
    if [[ $install_netdata = 1 ]]; then
    #wget -O /opt/netdata/etc/netdata/netdata.conf http://127.0.0.1:19999/netdata.conf
    #sed -i 's/# bind to = \*/bind to = 127.0.0.1/g' /opt/netdata/etc/netdata/netdata.conf
    cd /opt/netdata/bin
    bash netdata-claim.sh -token=llFcKa-42N035f4WxUYZ5VhSnKLBYQR9Se6HIrtXysmjkMBHiLCuiHfb9aEJmXk0hy6V_pZyKMEz_QN30o2s7_OsS7sKEhhUTQGfjW0KAG5ahWhbnCvX8b_PW_U-256otbL5CkM -rooms=38e38830-7b2c-4c34-a4c7-54cacbe6dbb9 -url=https://app.netdata.cloud &>/dev/null
    cd
    fi
    if [[ ${dnsmasq_install} == 1 ]]; then
      if [[ ${dist} = ubuntu ]]; then
        systemctl stop systemd-resolved
        systemctl disable systemd-resolved
      fi
      if [[ $(systemctl is-active dnsmasq) == active ]]; then
        systemctl stop dnsmasq
      fi
    rm /etc/resolv.conf
    touch /etc/resolv.conf
    echo "nameserver 127.0.0.1" > '/etc/resolv.conf'
    systemctl restart dnscrypt-proxy
    fi
    clear
    chmod +x /etc/profile.d/mymotd.sh
    clear
    echo "" > /etc/motd
    echo "Install complete!"
    whiptail --title "Success" --msgbox "安装成功(Install Success),欢迎使用VPSTOOLBOX !" 8 68
    bash /etc/profile.d/mymotd.sh
    exit 0
    ;;
    Benchmark)
    clear
    if (whiptail --title "测试模式" --yes-button "快速测试" --no-button "完整测试" --yesno "效能测试方式(fast or full)?" 8 68); then
        curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s fast
        else
        curl -fsL https://ilemonra.in/LemonBenchIntl | bash -s full
    fi
    exit 0
    ;;
    Exit)
    whiptail --title "Bash Exited" --msgbox "Goodbye" 8 68
    exit 0
    ;;
    esac
}
clear
cd
initialize
setlanguage
clear
advancedMenu
