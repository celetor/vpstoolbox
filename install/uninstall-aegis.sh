#!/usr/bin/env bash

## Tor模组 Tor moudle

uninstall_aegis(){
TERM=ansi whiptail --title "阿里云监控卸载" --infobox "检测到阿里云恶意监控服务，开始卸载..." 7 68
colorEcho ${INFO} "Uninstall Aliyun aegis ing"
iptables -I INPUT -s 140.205.201.0/28 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.201.16/29 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.201.32/28 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.192/29 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.200/30 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.184/29 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.183/32 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.206/32 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.205/32 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.195/32 -j DROP &>/dev/null
iptables -I INPUT -s 140.205.225.204/32 -j DROP &>/dev/null
systemctl stop aegis
systemctl stop CmsGoAgent.service
systemctl stop aliyun
systemctl stop cloud-config
systemctl stop cloud-final
systemctl stop cloud-init-local.service
systemctl stop cloud-init
systemctl stop ecs_mq
systemctl stop exim4
systemctl stop apparmor
systemctl stop sysstat
systemctl disable aegis
systemctl disable CmsGoAgent.service
systemctl disable aliyun
systemctl disable cloud-config
systemctl disable cloud-final
systemctl disable cloud-init-local.service
systemctl disable cloud-init
systemctl disable ecs_mq
systemctl disable exim4
systemctl disable apparmor
systemctl disable sysstat
killall -9 aegis_cli >/dev/null 2>&1
killall -9 aegis_update >/dev/null 2>&1
killall -9 aegis_cli >/dev/null 2>&1
killall -9 AliYunDun >/dev/null 2>&1
killall -9 AliHids >/dev/null 2>&1
killall -9 AliHips >/dev/null 2>&1
killall -9 AliYunDunUpdate >/dev/null 2>&1
rm -rf /etc/init.d/aegis
rm -rf /etc/systemd/system/CmsGoAgent*
rm -rf /etc/systemd/system/aliyun*
rm -rf /lib/systemd/system/cloud*
rm -rf /lib/systemd/system/ecs_mq*
rm -rf /usr/local/aegis
rm -rf /usr/local/cloudmonitor
rm -rf /usr/sbin/aliyun*
rm -rf /sbin/ecs_mq_rps_rfs
rm -rf /usr/local/share/assist-daemon
for ((var=2; var<=5; var++)) do
  if [ -d "/etc/rc${var}.d/" ];then
    rm -rf "/etc/rc${var}.d/S80aegis"
  elif [ -d "/etc/rc.d/rc${var}.d" ];then
    rm -rf "/etc/rc.d/rc${var}.d/S80aegis"
  fi
done
apt-get purge sysstat exim4 chrony aliyun-assist -y
systemctl daemon-reload
#echo "nameserver 1.1.1.1" > '/etc/resolv.conf'
}

