![logo](https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/logo.png)
# VPS Toolbox

A powerful Toolbox for Linux VPS.

#### How to use
```
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/vps.sh)"
```
If sudo/curl command not found , then:  
```
apt-get update && apt-get install sudo curl -y || (yum update -y && yum install sudo curl -y)
```

Flowchart:
![flowchart](https://raw.githubusercontent.com/jerrypoma/trojan-gfw-script/master/vpstoolbox.png)

#### Friendly Reminder:
1. Please **Run as root**(sudo -i)
2. Please **[Purchase a domain](https://www.namesilo.com/?rid=685fb47qi)** and **[finish a dns resolve](https://dnschecker.org/)** before running this bash script!
3. Please **Open Tcp port [80](https://www.speedguide.net/port.php?port=80) and [443](https://www.speedguide.net/port.php?port=443) and turn off Cloudflare CDN** in your control panel before running this bash script!
4. For customized certificate , please put it in /etc/trojan/ , no name change required !

## If you found it useful , please give a star ,thanks!

### Live Demo(no Guarantee)

[https://www.trojan-gfw.xyz/vpstoolbox.html](https://www.trojan-gfw.xyz/vpstoolbox.html)

#### Bash Features:

1. Auto install and config **[NGINX](https://www.nginx.com/)**
3. Auto issue renew [let's encrypt certificate](https://letsencrypt.org/) and **auto reload Trojan-GFW after renewal**
4. Auto OS Detect **Support [Debian](https://www.debian.org/) [Ubuntu](https://ubuntu.com/) (Centos not recommended)**
5. Auto [domain resolve verification](https://en.wikipedia.org/wiki/Nslookup)
6. Auto [iptables](https://en.wikipedia.org/wiki/Iptables)(includes ipv6) firewall config and [iptables-persistent](https://github.com/zertrin/iptables-persistent)
7. Auto generate Trojan-GFW [client config](https://trojan-gfw.github.io/trojan/config) 
10. Auto [Nginx Performance Optimization](https://www.johnrosen1.com/nginx1/)
11. Auto [Trojan-GFW ***trojan://*** share link and QR code generate](https://github.com/trojan-gfw/trojan-url)
13. Auto [https 301 redirect](https://en.wikipedia.org/wiki/HTTP_301) without affecting certificate renew
14. Auto enable [HSTS header](https://securityheaders.com/)
16. Auto ***Random Html Template Choose***
17. Auto enable [***Full IPv6 Support***](https://en.wikipedia.org/wiki/IPv6)
18. Auto enable ***[time sync](https://www.freedesktop.org/software/systemd/man/timedatectl.html)***
19. Auto enable ***Fail Restart*** 
20. Auto [uninstall Aliyun Aegis](https://www.johnrosen1.com/ali-iso/)
20. Support Auto install and config **[Trojan-GFW](https://github.com/trojan-gfw/trojan) [Dnscrypt-proxy](https://www.dnscrypt.org/) [Qbittorrent](https://www.qbittorrent.org/) [Bittorrent-Tracker](https://github.com/webtorrent/bittorrent-tracker) [Aria2](https://github.com/aria2/aria2) [Filebrowser](https://github.com/filebrowser/filebrowser) [Netdata](https://github.com/netdata/netdata) and [TOR](https://famicoman.com/2018/01/03/configuring-and-monitoring-a-tor-middle-relay/)**
9.  Support Auto [TCP Turbo](https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks) enable ( **[TCP-BBR](https://github.com/google/bbr)** included)
20. Support ***[BBRPLUS](https://github.com/chiakge/Linux-NetSpeed)***
15. Support ***[TLS1.3 ONLY](https://wiki.openssl.org/index.php/TLS1.3)***
21. Support manually check for update
23. Support Full/Part Uninstall
24. And so on...

**If you need more functions, please open a Github issue.(No Centos related issues or bugs allowed except pull requests)**

