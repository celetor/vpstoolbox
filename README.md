![logo](https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/logo.png)

# VPSTOOLBOX

超级Linux VPS脚本工具箱，**支援一键安装Trojan-GFW代理,Hexo博客,RSS,邮件,Qbittorrent,Aria2,Netdata等應用程式**。

[![Gitter](https://badges.gitter.im/vpstoolbox/community.svg)](https://gitter.im/vpstoolbox/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Join our Discord server!](https://img.shields.io/badge/discord-join-7289DA.svg?logo=discord&longCache=true&style=flat)](https://discord.gg/y5KUxfYZ)
[TG群组](https://t.me/vpstoolbox_chat)

## 使用方法(請以root/sudo用戶運行)
```
apt-get update && apt-get install sudo curl -y && curl -Ss https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/vps.sh | sudo bash
```

#### 重要提示:
1. 本项目**可覆盖安装，无需重建伺服器/VPS !**
4. **仅支援 [Debian](https://www.debian.org/) [Ubuntu](https://ubuntu.com/)**
1. 请 **以root/sudoer身份运行**(sudo -i)
2. 请 **[先购买一个域名](https://www.namesilo.com/?rid=685fb47qi)** 并 **[完成DNS解析](https://dnschecker.org/)**!
3. 请在控制面板中 **开启所有端口**(Trojan-gfw支援fullcone-nat但需服务器开启所有端口才能使用) 并 ***关闭 Cloudflare CDN !***
4. 如安装失败请自行加入TG群组反馈或者开issue,但请**务必附上错误的步骤，截图，OS版本等信息**。

流量图示(仅供参考):
![flowchart](https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/images/flow_zh_cn.png)

#### 隐私声明:

1. 此项目使用MIT开源协议，**欢迎PR**.
2. 所有ip信息皆来自ipinfo.io,仅用于验证域名解析是否成功，无其他作用。

#### 项目特性:

1. 全自动安装并配置 **[NGINX](https://www.nginx.com/) 以及 Hexo**
2. 支援所有种类的虚拟化技术，包括bare mental,kvm openvz等
20. 支援全自动安装并配置 **[Trojan-GFW](https://github.com/trojan-gfw/trojan) [Hexo](https://hexo.io/zh-tw/docs/) [Dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) [Qbittorrent](https://www.qbittorrent.org/) [Bittorrent-Tracker](https://github.com/webtorrent/bittorrent-tracker) [Aria2](https://github.com/aria2/aria2) [Filebrowser](https://github.com/filebrowser/filebrowser) [Netdata](https://github.com/netdata/netdata) [MariaDB](https://mariadb.org/) [PHP](https://www.php.net/) RSSHUB [Tiny Tiny RSS](https://git.tt-rss.org/fox/tt-rss) Fail2ban [Speedtest](https://github.com/librespeed/speedtest) [TOR](https://famicoman.com/2018/01/03/configuring-and-monitoring-a-tor-middle-relay/) [Trojan-panel](https://github.com/trojan-gfw/trojan-panel) Postfix Dovecot Roundcube-Webmail等**
3. 全自动签发,续签,重启服务 [let's encrypt 证书](https://letsencrypt.org/)
17. [完整的IPV6支援](https://en.wikipedia.org/wiki/IPv6)
17. [Full HTTP/2 Support](https://en.wikipedia.org/wiki/HTTP/2)
18. [全自动时间较准](https://www.freedesktop.org/software/systemd/man/timedatectl.html)
19. 全自动服务掉线重启(systemd auto-failrestart)
20. [全自动检测并卸载阿里云监控](https://www.johnrosen1.com/ali-iso/)
9.  支援 [TCP Turbo](https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks)
23. 支援完全/部分卸载
24. And so on...

#### 新手上路

[VPSTOOLBOX基础使用方法](https://github.com/johnrosen1/vpstoolbox/wiki/VPSTOOLBOX%E5%9F%BA%E7%A1%80%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95)

#### 项目Demo(无保证)

[https://trojan-gfw.xyz/vpstoolbox/](https://trojan-gfw.xyz/vpstoolbox/)

#### 更多信息请自行查看Wiki !

#### 如果此项目对你有用 , 请给颗star ,谢谢!

* * *

# VPSTOOLBOX

VPSToolBox is a bash script that helps you setup Trojan-gfw Nginx Hexo Netdata and other powerful applications on a Linux server really quickly.

[![Gitter](https://badges.gitter.im/vpstoolbox/community.svg)](https://gitter.im/vpstoolbox/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Join our Discord server!](https://img.shields.io/badge/discord-join-7289DA.svg?logo=discord&longCache=true&style=flat)](https://discord.gg/y5KUxfYZ)
[Chat on Telegram](https://t.me/vpstoolbox_chat)

## How to use
```
apt-get update && apt-get install sudo curl -y && curl -Ss https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/vps.sh | sudo bash
```

#### Important Reminder:
4. **Support [Debian](https://www.debian.org/) [Ubuntu](https://ubuntu.com/)**
1. Please **Run as root**(sudo -i)
2. Please **[Purchase a domain](https://www.namesilo.com/?rid=685fb47qi)** and **[finish a dns resolve](https://dnschecker.org/)** before running this program!
3. Please **turn off your firewall for best performance(full-cone nat) and turn off Cloudflare CDN** in your control panel before running this program!

Flowchart:
![flowchart](https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/images/flowchart.png)

#### Privacy Statement:

Ip Information is just an indispensable part of this project, all ip information comes from ipinfo.io,no spam related.

#### Features:

1. Auto install and config **[NGINX](https://www.nginx.com/)**
2. Support all kinds of virtualization including kvm openvz and so on.
20. Support Auto install and config **[Trojan-GFW](https://github.com/trojan-gfw/trojan) [Hexo](https://hexo.io/zh-tw/docs/) [Dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) [Qbittorrent](https://www.qbittorrent.org/) [Bittorrent-Tracker](https://github.com/webtorrent/bittorrent-tracker) [Aria2](https://github.com/aria2/aria2) [Filebrowser](https://github.com/filebrowser/filebrowser) [Netdata](https://github.com/netdata/netdata) [MariaDB](https://mariadb.org/) [PHP](https://www.php.net/) RSSHUB [Tiny Tiny RSS](https://git.tt-rss.org/fox/tt-rss) Fail2ban [TOR](https://famicoman.com/2018/01/03/configuring-and-monitoring-a-tor-middle-relay/) [Speedtest](https://github.com/librespeed/speedtest) [Trojan-panel](https://github.com/trojan-gfw/trojan-panel) Postfix Dovecot Roundcube-Webmail**
3. Auto issue and renew [let's encrypt certificate](https://letsencrypt.org/) and auto reload Trojan-GFW after renewal
17. [Full IPv6 Support](https://en.wikipedia.org/wiki/IPv6)
17. [Full HTTP/2 Support](https://en.wikipedia.org/wiki/HTTP/2)
18. [time sync](https://www.freedesktop.org/software/systemd/man/timedatectl.html)
19. Fail Restart
20. [uninstall Aliyun Aegis](https://www.johnrosen1.com/ali-iso/)
9.  Support [TCP Turbo](https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks)
23. Support Full/Part Uninstall
24. And so on...

#### Give it a try ! (Live Demo,no Guarantee)

[https://trojan-gfw.xyz/vpstoolbox/](https://trojan-gfw.xyz/vpstoolbox/)

#### Please check project wiki for more info !

#### If you found it useful , please give a star ,thanks!

#### License

[MIT](https://github.com/johnrosen1/vpstoolbox/blob/master/LICENSE)


## Stargazers over time

[![Stargazers over time](https://starchart.cc/johnrosen1/vpstoolbox.svg)](https://starchart.cc/johnrosen1/vpstoolbox)
