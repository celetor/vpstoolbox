![logo](https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/logo.png)
# Trojan-GFW Script
# [中文文檔](https://github.com/johnrosen1/trojan-gfw-script/blob/master/README_CN.md)
## This script will help you set up a [Trojan-GFW](https://github.com/trojan-gfw/trojan) and an Ultimate Offline download server in an extremely fast way.
### Read The Fucking Manual: https://www.johnrosen1.com/trojan/

### GUI Version (Everything has been included)
```
apt-get update && apt-get install sudo curl -y && sudo -i
```

```
yum update -y && yum install sudo curl -y && sudo -i
```

```
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojangui.sh)"
```
![menu](https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/menu.png)
![choose](https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/menu2.png)

#### Friendly Reminder:
1. Please **Run as root**(sudo -i)
2. Please **[Purchase a domain](https://www.namesilo.com/?rid=685fb47qi)** and **[finish a dns resolve](https://dnschecker.org/)** before running this bash script!
3. Please **Open Tcp port [80](https://www.speedguide.net/port.php?port=80) and [443](https://www.speedguide.net/port.php?port=443) and turn off Cloudflare CDN** in your control panel before running this bash script!
4. Please manually change system dns to frequently updated dns like [1.1.1.1](https://1.1.1.1/) instead of those who update slowly like aliyun lan dns !
```
echo "nameserver 1.1.1.1" > '/etc/resolv.conf'
```
5. Please **Change QBittorrent Download save path to /usr/share/nginx/qbt/ manually !**

#### [Telegram](https://telegram.org/) Channel And Group

### https://t.me/johnrosen1

### https://t.me/trojanscript

## If you found it useful , please give a star ,thanks!
#### Bash Features:

1. Auto install and config **[NGINX](https://www.nginx.com/)**
3. Auto issue renew [let's encrypt certificate](https://letsencrypt.org/) and **auto reload Trojan-GFW after renewal**
4. Auto OS Detect **Support [Debian](https://www.debian.org/) [Ubuntu](https://ubuntu.com/) Centos**
5. Auto [domain resolve verification](https://en.wikipedia.org/wiki/Nslookup)
6. Auto [iptables](https://en.wikipedia.org/wiki/Iptables)(includes ipv6) firewall config and [iptables-persistent](https://github.com/zertrin/iptables-persistent)
7. Auto generate [client config](https://trojan-gfw.github.io/trojan/config) (includes both Trojan-GFW and V2ray )
10. Auto [Nginx Performance Optimization](https://www.johnrosen1.com/nginx1/)
11. Auto [Trojan-GFW ***trojan://*** share link and QR code generate](https://github.com/trojan-gfw/trojan-url)
13. Auto [https 301 redirect](https://en.wikipedia.org/wiki/HTTP_301) without affecting certificate renew
14. Auto enable [HSTS header](https://securityheaders.com/)
16. Auto ***Random Html Template Choose***
17. Auto enable [***Full IPv6 Support***](https://en.wikipedia.org/wiki/IPv6)
18. Auto enable ***[time sync](https://www.freedesktop.org/software/systemd/man/timedatectl.html)***
19. Auto enable ***Fail Restart*** 
20. Auto [uninstall Aliyun Aegis](https://www.johnrosen1.com/ali-iso/)
20. Support Auto install and config **[Trojan-GFW](https://github.com/trojan-gfw/trojan) [Dnsmasq](https://en.wikipedia.org/wiki/Dnsmasq) [Qbittorrent](https://www.qbittorrent.org/) [Bittorrent-Tracker](https://github.com/webtorrent/bittorrent-tracker) [Aria2](https://github.com/aria2/aria2) [Filebrowser](https://github.com/filebrowser/filebrowser) [Netdata](https://github.com/netdata/netdata) [V2ray](https://www.v2ray.com/index.html) and [Shadowsocks](https://shadowsocks.org/en/index.html)([V2ray-plugin](https://github.com/shadowsocks/v2ray-plugin)) [TOR](https://famicoman.com/2018/01/03/configuring-and-monitoring-a-tor-middle-relay/)**
12. Support auto [V2ray ***vmess://*** share link generate](https://github.com/boypt/vmess2json) and Shadowsocks ss:// share link and qrcode generate
19. Support auto [***vmess or ss + tls + websocket + nginx*** config](https://guide.v2fly.org/advanced/wss_and_web.html)
9.  Support Auto [TCP Turbo](https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks) enable ( **[TCP-BBR](https://github.com/google/bbr)** included)
20. Support ***[BBRPLUS](https://github.com/chiakge/Linux-NetSpeed)***
15. Support ***[TLS1.3 ONLY](https://wiki.openssl.org/index.php/TLS1.3)***
21. Support manually check for update include both Trojan-gfw and v2ray(ss included)
23. Support Full/Part Uninstall

**If you need more functions, please open a Github issue.(No Centos related issues or bugs allowed except pull requests)**

### VPS Recommendation (no personal aff included)

#### https://www.kamatera.com/

#### Related Links

https://www.johnrosen1.com/qbt/

### Debug Guide

```
https://github.com/trojan-gfw/trojan-quickstart
sudo nginx -t
sudo systemctl status trojan
sudo systemctl status nginx
sudo systemctl status v2ray
sudo systemctl status tor
sudo systemctl status tor@default
sudo systemctl status dnsmasq
sudo systemctl status qbittorrent
sudo systemctl status tracker
sudo systemctl status aria2
sudo systemctl status filebrowser
sudo systemctl status netdata
journalctl -e -u trojan.service
cat /var/log/v2ray/error.log
cat /usr/local/etc/trojan/config.json
cat /etc/nginx/conf.d/trojan.conf
cat /etc/v2ray/config.json
cat /etc/aria.conf
crontab -l
sudo ~/.acme.sh/acme.sh --cron
timedatectl
iptables -L -v
```
### Result Example
```
trojan://trojanscript@www.johnrosen.top:443
```
![Trojan-GFW QR code](https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojanscript.png)



