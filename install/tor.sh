#!/usr/bin/env bash

## Tor模组 Tor moudle

install_tor(){
clear
TERM=ansi whiptail --title "安装中" --infobox "安装Tor relay中..." 7 68
colorEcho ${INFO} "Install Tor Relay ing"
touch /etc/apt/sources.list.d/tor.list
  cat > '/etc/apt/sources.list.d/tor.list' << EOF
deb https://deb.torproject.org/torproject.org $(lsb_release -cs) main
#deb-src https://deb.torproject.org/torproject.org $(lsb_release -cs) main
EOF
curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -
apt-get update
apt-get install tor tor-geoipdb nyx -y
apt-get install python-stem -y
ipv4_prefer_1="0"
if [[ -n $myipv6 ]]; then
    ping -6 ipv6.google.com -c 2 || ping -6 2620:fe::10 -c 2
    if [[ $? -eq 0 ]]; then
      ipv4_prefer_1="1"
    fi
fi
  cat > '/etc/tor/torrc' << EOF
ClientUseIPv6 ${ipv4_prefer_1}
ClientPreferIPv6ORPort ${ipv4_prefer_1}
ControlPort 127.0.0.1:9051
CookieAuthentication 0
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServiceVersion 3
HiddenServicePort 80 127.0.0.1:8888
HiddenServicePort 443 127.0.0.1:443
EOF
torhostname=$(cat /var/lib/tor/hidden_service/hostname)
systemctl restart tor@default
}
