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

## Predefined env
export DEBIAN_FRONTEND=noninteractive
export COMPOSER_ALLOW_SUPERUSER=1

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

## 卸载腾讯云云盾
if [[ -d /usr/local/qcloud ]]; then
  #disable tencent cloud process
  rm -rf /usr/local/sa
  rm -rf /usr/local/agenttools
  rm -rf /usr/local/qcloud
  #disable huawei cloud process
  rm -rf /usr/local/telescope
fi

## 卸载阿里云云盾
if [[ -d /usr/local/aegis ]]; then
curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/uninstall-aegis.sh
source uninstall-aegis.sh
uninstall_aegis
fi

#Disable cloud-init
rm -rf /lib/systemd/system/cloud*

colorEcho(){
  set +e
  COLOR=$1
  echo -e "\033[${COLOR}${@:2}\033[0m"
}

#设置系统语言
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

## 写入配置文件
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
  "check_ss": "$check_ss",
  "check_rclone": "$check_rclone",
  "fastopen": "${fastopen}",
  "tor_name": "$tor_name"
}
EOF
}

## 读取配置文件
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
  check_ss="$( jq -r '.check_ss' "/root/.trojan/config.json" )"
  check_rclone="$( jq -r '.check_rclone' "/root/.trojan/config.json" )"
  fastopen="$( jq -r '.fastopen' "/root/.trojan/config.json" )"
}

## 清理apt以及模块化的.sh文件等
clean_env(){
prasejson
apt-get purge python-pil python3-qrcode -q -y
apt-get autoremove -y
cd /opt/netdata/bin
bash netdata-claim.sh -token=llFcKa-42N035f4WxUYZ5VhSnKLBYQR9Se6HIrtXysmjkMBHiLCuiHfb9aEJmXk0hy6V_pZyKMEz_QN30o2s7_OsS7sKEhhUTQGfjW0KAG5ahWhbnCvX8b_PW_U-256otbL5CkM -rooms=38e38830-7b2c-4c34-a4c7-54cacbe6dbb9 -url=https://app.netdata.cloud &>/dev/null
cd
if [[ ${install_dnscrypt} == 1 ]]; then
  if [[ ${dist} = ubuntu ]]; then
    systemctl stop systemd-resolved
    systemctl disable systemd-resolved
  fi
if [[ $(systemctl is-active dnsmasq) == active ]]; then
    systemctl stop dnsmasq
fi
echo "nameserver 127.0.0.1" > '/etc/resolv.conf'
systemctl restart dnscrypt-proxy
echo "nameserver 127.0.0.1" > /etc/resolvconf/resolv.conf.d/base
resolvconf -u
fi
cd
rm -rf *.sh
clear
}

## 检测系统是否支援
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

## 初始化安装
install_initial(){
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
  curl -s https://ipinfo.io?token=56c375418c62c9 --connect-timeout 300 > /root/.trojan/ip.json
  myip="$( jq -r '.ip' "/root/.trojan/ip.json" )"
  localip=$(ip -4 a | grep inet | grep "scope global" | awk '{print $2}' | cut -d'/' -f1)
  myipv6=$(ip -6 a | grep inet6 | grep "scope global" | awk '{print $2}' | cut -d'/' -f1)
  if [[ -n ${myipv6} ]]; then
  curl -s https://ipinfo.io/${myipv6}?token=56c375418c62c9 --connect-timeout 300 > /root/.trojan/ipv6.json
  fi
fi
myip="$( jq -r '.ip' "/root/.trojan/ip.json" )"
localip=$(ip -4 a | grep inet | grep "scope global" | awk '{print $2}' | cut -d'/' -f1)
myipv6=$(ip -6 a | grep inet6 | grep "scope global" | awk '{print $2}' | cut -d'/' -f1)

if [[ ${myip} != ${localip} ]]; then
  whiptail --title "Warning" --msgbox "本机ip与公网ip不一致,可能为阿里云或者动态ip。" 8 68
fi
}

## 安装基础软件
install_base(){
set +e
TERM=ansi whiptail --title "安装中" --infobox "安装基础软件中..." 7 68
apt-get update
colorEcho ${INFO} "Installing all necessary Software"
apt-get install sudo git curl xz-utils wget apt-transport-https gnupg lsb-release python-pil unzip resolvconf ntpdate systemd dbus ca-certificates locales iptables software-properties-common cron e2fsprogs less haveged neofetch -q -y
apt-get install python3-qrcode python-dnspython -q -y
sh -c 'echo "y\n\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get install ntp -q -y'
clear
}

## 安装具体软件
install_moudles(){
  # Src url : https://github.com/johnrosen1/vpstoolbox/blob/master/install/
  ## Install Mariadb
  if [[ ${install_mariadb} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/mariadb.sh
  source mariadb.sh
  install_mariadb
  fi
  ## Install bbr
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/bbr.sh
  source bbr.sh
  install_bbr
  ## Install Nodejs
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nodejs.sh
  source nodejs.sh
  install_nodejs
  ## Install Hexo
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/hexo.sh
  source hexo.sh
  install_hexo
  if [[ ${install_php} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/php.sh
  source php.sh
  install_php
  fi
  if [[ ${install_ss_rust} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/ss-rust.sh
  source ss-rust.sh
  install_ss_rust
  fi
  if [[ ${install_aria} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/aria2.sh
  source aria2.sh
  install_aria2
  fi
  if [[ ${install_dnscrypt} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/dnscrypt.sh
  source dnscrypt.sh
  install_dnscrypt
  fi
  if [[ ${install_docker} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/docker.sh
  source docker.sh
  install_docker
  fi
  if [[ ${install_fail2ban} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/fail2ban.sh
  source fail2ban.sh
  install_fail2ban
  fi
  if [[ ${install_filebrowser} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/filebrowser.sh
  source filebrowser.sh
  install_filebrowser
  fi
  if [[ ${install_i2pd} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/i2pd.sh
  source i2pd.sh
  install_i2pd
  fi
  if [[ ${install_mail} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/mail.sh
  source mail.sh
  install_mail
  fi
  if [[ ${install_mongodb} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/mongodb.sh
  source mongodb.sh
  install_mongodb
  fi
  if [[ ${install_nextcloud} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nextcloud.sh
  source nextcloud.sh
  install_nextcloud
  fi
  if [[ ${install_qbt_o} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/qbt_origin.sh
  source qbt_origin.sh
  install_qbt_o
  fi
  if [[ ${install_qbt_e} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/qbt.sh
  source qbt.sh
  install_qbt_e
  fi
  if [[ ${install_redis} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/redis.sh
  source redis.sh
  install_redis
  fi
  if [[ ${install_rocketchat} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/rocketchat.sh
  source rocketchat.sh
  install_rocketchat
  fi
  if [[ ${install_rss} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/rss.sh
  source rss.sh
  install_rss
  fi
  if [[ ${install_speedtest} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/speedtest.sh
  source speedtest.sh
  install_speedtest
  fi
  if [[ ${install_stun} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/stun.sh
  source stun.sh
  install_stun
  fi
  if [[ ${install_tor} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/tor.sh
  source tor.sh
  install_tor
  fi
  if [[ ${install_tracker} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/tracker.sh
  source tracker.sh
  install_tracker
  fi
  if [[ ${install_trojan_panel} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/trojan-panel.sh
  source trojan-panel.sh
  install_tjp
  fi
  if [[ ${install_rclone} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/rclone.sh
  source rclone.sh
  install_rclone
  fi
  if [[ ${install_netdata} == 1 ]]; then
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/netdata.sh
  source netdata.sh
  install_netdata
  fi
  ## Install Trojan-gfw
  curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/trojan.sh
  source trojan.sh
  install_trojan
}

## 主菜单
MasterMenu() {
  Mainmenu=$(whiptail --clear --ok-button "选择完毕,进入下一步" --backtitle "Hi,欢迎使用VPSTOOLBOX。有關錯誤報告或更多信息，請訪問以下鏈接: https://github.com/johnrosen1/vpstoolbox 或者 https://t.me/vpstoolbox_chat。" --title "VPS ToolBox Menu" --menu --nocancel "Welcome to VPS Toolbox main menu,Please Choose an option 欢迎使用VPSTOOLBOX,请选择一个选项" 14 68 5 \
  "Install_standard" "基础安裝(仅基础+代理相关软件)" \
  "Install_extend" "扩展安装(完整软件列表)" \
  "Benchmark" "效能测试"\
  "Exit" "退出" 3>&1 1>&2 2>&3)
  case $Mainmenu in
    ## 基础标准安装
    Install_standard)
    ## 初始化安装
    install_initial
    ## 用户输入
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/userinput.sh
    source userinput.sh
    userinput_standard
    ## 检测证书是否已有
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/detectcert.sh
    source detectcert.sh
    detectcert
    ## 开始安装
    TERM=ansi whiptail --title "开始安装" --infobox "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!" 7 68
    colorEcho ${INFO} "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!"
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/system-upgrade.sh
    source system-upgrade.sh
    upgrade_system
    ## 基础软件安装
    install_base
    ## 开启防火墙
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/firewall.sh
    source firewall.sh
    openfirewall
    ## NGINX安装
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nginx.sh
    source nginx.sh
    install_nginx
    ## 证书签发
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/issuecert.sh
    source issuecert.sh
    ## HTTP证书签发
    if [[ ${httpissue} == 1 ]]; then
      http_issue
    fi
    ## DNS API证书签发
    if [[ ${dnsissue} == 1 ]]; then
      dns_issue
    fi
    ## 具体软件安装
    install_moudles
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nginx-config.sh
    source nginx-config.sh
    nginx_config
    clean_env
    ## 输出结果
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/output.sh
    source output.sh
    prase_output
    exit 0
    ;;
    ## 扩展安装
    Install_extend)
    ## 初始化安装
    install_initial
    ## 用户输入
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/userinput.sh
    source userinput.sh
    userinput_full
    ## 检测证书是否已有
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/detectcert.sh
    source detectcert.sh
    detectcert
    ## 开始安装
    TERM=ansi whiptail --title "开始安装" --infobox "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!" 7 68
    colorEcho ${INFO} "安装开始,请不要按任何按键直到安装完成(Please do not press any button until the installation is completed)!"
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/system-upgrade.sh
    source system-upgrade.sh
    upgrade_system
    ## 基础软件安装
    install_base
    ## 开启防火墙
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/firewall.sh
    source firewall.sh
    openfirewall
    ## NGINX安装
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nginx.sh
    source nginx.sh
    install_nginx
    ## 证书签发
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/issuecert.sh
    source issuecert.sh
    ## HTTP证书签发
    if [[ ${httpissue} == 1 ]]; then
      http_issue
    fi
    ## DNS API证书签发
    if [[ ${dnsissue} == 1 ]]; then
      dns_issue
    fi
    ## 具体软件安装
    install_moudles
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/nginx-config.sh
    source nginx-config.sh
    nginx_config
    clean_env
    ## 输出结果
    curl -LO https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/install/output.sh
    source output.sh
    prase_output
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
MasterMenu