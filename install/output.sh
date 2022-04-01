#!/usr/bin/env bash

## OUTPUT模组 Tor moudle

set +e

prase_output(){
clear
apt-get install neofetch -y
	cat > '/etc/profile.d/mymotd.sh' << EOF
#!/usr/bin/env bash
#!!! Do not change these settings unless you know what you are doing !!!
bold=\$(tput bold)
normal=\$(tput sgr0)
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
###
domain="$( jq -r '.domain' "/root/.trojan/config.json" )"
trojanport="$( jq -r '.trojanport' "/root/.trojan/config.json" )"
password1="$( jq -r '.password1' "/root/.trojan/config.json" )"
password2="$( jq -r '.password2' "/root/.trojan/config.json" )"
neofetch
echo -e " --- 欢迎使用VPSToolBox --- "
echo -e " --- \${BLUE}服務狀態(Service Status)\${NOCOLOR} ---"
  if [[ -f /usr/local/bin/trojan ]]; then
echo -e "Trojan-GFW:\t\t"\$(systemctl is-active trojan)
  fi
  if [[ -f /usr/bin/xray ]]; then
echo -e "Vless(Grpc):\t\t"\$(systemctl is-active grpc)
  fi
  if [[ -f /usr/sbin/ssserver ]]; then
echo -e "SS-rust:\t\t"\$(systemctl is-active ssserver)
  fi
  if [[ -f /usr/sbin/nginx ]]; then
echo -e "Nginx:\t\t\t"\$(systemctl is-active nginx)
  fi
  if [[ -f /usr/bin/hexo ]]; then
echo -e "Hexo:\t\t\t"\$(systemctl is-active hexo)
  fi
  if [[ -f /usr/sbin/dnscrypt-proxy ]]; then
echo -e "Dnscrypt-proxy:\t\t"\$(systemctl is-active dnscrypt-proxy)
  fi
  if [[ -f /usr/bin/qbittorrent-nox ]]; then
echo -e "Qbittorrent:\t\t"\$(systemctl is-active qbittorrent)
  fi
  if [[ -f /usr/sbin/opentracker ]]; then
echo -e "Bittorrent-tracker:\t"\$(systemctl is-active tracker)
  fi
  if [[ -f /usr/local/bin/aria2c ]]; then
echo -e "Aria2c:\t\t\t"\$(systemctl is-active aria2)
  fi
  if [[ -f /usr/local/bin/filebrowser ]]; then
echo -e "Filebrowser:\t\t"\$(systemctl is-active filebrowser)
  fi
  if [[ -f /opt/netdata/usr/sbin/netdata ]]; then
echo -e "Netdata:\t\t"\$(systemctl is-active netdata)
  fi
  if [[ -f /usr/bin/dockerd ]]; then
echo -e "Docker:\t\t\t"\$(systemctl is-active docker)
  fi
  if [[ -f /usr/sbin/mysqld ]]; then
echo -e "MariaDB:\t\t"\$(systemctl is-active mariadb)
  fi
  if [[ -f /usr/sbin/php-fpm8.0 ]]; then
echo -e "PHP:\t\t\t"\$(systemctl is-active php8.0-fpm)
  fi
  if [[ -f /usr/sbin/dovecot ]]; then
echo -e "Dovecot:\t\t"\$(systemctl is-active dovecot)
  fi
  if [[ -f /usr/sbin/postfix ]]; then
echo -e "Postfix:\t\t"\$(systemctl is-active postfix)
  fi
  if [[ -f /usr/bin/fail2ban-server ]]; then
echo -e "Fail2ban:\t\t"\$(systemctl is-active fail2ban)
  fi
echo -e " --- \${BLUE}帶寬使用(Bandwith Usage)\${NOCOLOR} ---"
echo -e "         接收(Receive)    发送(Transmit)"
tail -n +3 /proc/net/dev | grep -e eth -e enp | awk '{print \$1 " " \$2 " " \$10}' | numfmt --to=iec --field=2,3
echo -e " --- \${GREEN}證書狀態(Certificate Status)\${NOCOLOR} ---"
ssl_date=\$(echo |timeout 3 openssl s_client -4 -connect ${myip}:${trojanport} -servername ${domain} -tls1_3 2>&1 |sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'|openssl x509 -text) &>/dev/null
tmp_last_date=\$(echo "\${ssl_date}" | grep 'Not After :' | awk -F' : ' '{print \$NF}')
last_date=\$(date -ud "\${tmp_last_date}" +%Y-%m-%d" "%H:%M:%S)
day_count=\$(( (\$(date -d "\${last_date}" +%s) - \$(date +%s))/(24*60*60) ))
echo -e "\e[40;33;1m [${domain}] 证书过期日期 : \${last_date} && [\${day_count} days] \e[0m"
echo -e "*******************************************************************"
if [[ -f /usr/bin/xray ]]; then
echo -e " --- \${BLUE}Vless(grpc)链接(低延迟 推荐使用 支持Cloudflare CDN)\${NOCOLOR} ---"
echo -e "    \${YELLOW}vless://${uuid_new}@${domain}:${trojanport}?mode=gun&security=tls&type=grpc&serviceName=${path_new}&sni=${domain}#Vless(grpc_cdn_${myip})\${NOCOLOR}"
echo -e " --- \${BLUE}Trojan-GFW链接(不支持Cloudflare CDN)\${NOCOLOR} ---"
echo -e "    \${YELLOW}trojan://$password1@$domain:${trojanport}\${NOCOLOR}"
else
echo -e " --- \${BLUE}Trojan-GFW链接(不支持Cloudflare CDN)\${NOCOLOR} ---"
echo -e "    \${YELLOW}trojan://$password1@$domain:${trojanport}\${NOCOLOR}"
fi
if [[ -f /usr/sbin/ssserver ]]; then
echo -e " --- \${BLUE}SS-rust链接\${NOCOLOR} ---"
###
echo -e "    \${YELLOW}ss://aes-128-gcm:${password1}@${myip}:8388#iplc-only\${NOCOLOR}"
echo -e "    \${YELLOW}ss://$(echo "aes-128-gcm:${password1}@${myip}:8388" | base64)#iplc-only\${NOCOLOR}"
###
fi
if [[ -d /usr/share/nginx/nextcloud/ ]]; then
echo -e " --- \${BLUE}Nextcloud链接\${NOCOLOR}(Nextcloud links) ---"
###
echo -e "    \${YELLOW}https://${domain}:${trojanport}/nextcloud/\${NOCOLOR}"
echo -e "    \${YELLOW}用户名: admin\${NOCOLOR}"
echo -e "    \${YELLOW}密码: ${password1}\${NOCOLOR}"
###
fi
echo -e " --- 获取详细結果 ---"
echo -e "    \${YELLOW}https://${domain}:${trojanport}/${password1}/\${NOCOLOR}"
echo -e "*********************"
EOF
chmod +x /etc/profile.d/mymotd.sh
echo "" > /etc/motd
echo "Install complete!"
whiptail --title "Success" --msgbox "安装成功(Install Success),欢迎使用VPSTOOLBOX !" 8 68
bash /etc/profile.d/mymotd.sh
}
