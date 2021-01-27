![logo](https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/logo.png)

# VPSTOOLBOX

**一键安装Trojan-GFW代理,Hexo博客,Nextcloud等應用程式**。

[![Gitter](https://badges.gitter.im/vpstoolbox/community.svg)](https://gitter.im/vpstoolbox/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Join our Discord server!](https://img.shields.io/badge/discord-join-7289DA.svg?logo=discord&longCache=true&style=flat)](https://discord.gg/y5KUxfYZ)
[TG群组](https://t.me/vpstoolbox_chat)

## 使用方法(請以root/sudo用戶運行,仅推荐Debian10系统)
```
apt-get update && apt-get install sudo curl -y && curl -Ss https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/vps.sh | sudo bash
```

#### 重要提示:
1. 本项目**可覆盖安装，无需重建伺服器/VPS !**
2. Trojan-GFW**不支援Cloudflare CDN**,请勿开启!
4. **仅支援 [Debian9+](https://www.debian.org/) [Ubuntu16+](https://ubuntu.com/)**
1. 请 **以root/sudoer身份运行**(sudo -i)
2. 请 **先[购买](https://www.namesilo.com/?rid=685fb47qi)/[白嫖](https://www.freenom.com)一个域名或者使用二级域名** 并 **[完成DNS A解析,即将域名指向IP](https://dnschecker.org/)**(ipv6地址请添加AAAA解析,namesilo最慢需要15min生效)!
3. 请在控制面板中 **完全关闭VPS防火墙(即开放所有端口)**(Trojan-gfw支援fullcone-nat但需服务器开启所有端口才能使用) 并 ***关闭 Cloudflare 之类的 CDN !***
4. 除Trojan-gfw相關軟件外皆為可選項，請自行選擇需要的軟件。
2. API申请证书和HTTP申请证书区别不大,推荐HTTP申请(需A解析生效),无需输入API等信息。
4. 如安装失败请自行加入TG群组反馈或者开issue,但请**务必附上错误的步骤，截图，OS版本等信息**。
5. 证书续签目前使用crontab,如有问题,欢迎反馈 !

#### Trojan-panel使用方法

- Trojan-panel默认不安装,请**手动选中**以执行安装程序。
- 进入生成的url,**首次注册的用户为管理员(admin)**。
- 用户需联系管理员(admin)申请流量(**设置为-1为不限流量**)。
- 客户端配置文件中的密码填写在Panel注册的用户信息："Username:Password"。

#### Nextcloud优化方法

1. 开启Memcache
在```/usr/share/nginx/nextcloud/config/config.php```中添加以下几行(请添加在中间，非开头或末尾)

```
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'memcache.distributed' => '\\OC\\Memcache\\Redis',
  'filelocking.enabled' => true,
  'memcache.locking' => '\\OC\Memcache\\Redis',
  'redis' => 
  array (
    'host' => '/var/run/redis/redis.sock',
    'port' => 0,
    'timeout' => 0.0,
  ),
```

2. 优化索引

运行以下几行

```
cd /usr/share/nginx/nextcloud/
sudo -u nginx ./occ db:add-missing-indices
sudo -u nginx ./occ db:convert-filecache-bigint
cd
```

3. 切换后台进程方式为cron(好像nextcloud会自己切换,如未切换请手动切换)

Nextcloud设定-->基本设定-->改为cron(伺服器端已配置完成，无需任何手动配置)

4. 重启服务使配置生效
```
systemctl restart php7.4-fpm
```

#### 隐私声明:

1. 此项目使用MIT开源协议，**欢迎PR**.
2. 所有ip信息皆来自ipinfo.io,仅用于显示结果，无其他作用。
3. 项目Demo倒闭了,请自行搭建,谢谢!
4. 请勿提出任何关于Vultr的issue或者问题,那个垃圾厂商出的问题与本项目无关!

#### 项目特性:

1. 全自动安装并配置 **[NGINX](https://www.nginx.com/) 以及 Hexo**
2. 支援所有种类的虚拟化技术，包括bare mental,kvm openvz等
20. 支援全自动安装并配置 **[Trojan-GFW](https://github.com/trojan-gfw/trojan) [Hexo](https://hexo.io/zh-tw/docs/) [Dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) [Qbittorrent增强版](https://github.com/c0re100/qBittorrent-Enhanced-Edition) [Bittorrent-Tracker](https://erdgeist.org/arts/software/opentracker/) [Aria2](https://github.com/aria2/aria2) [Filebrowser](https://github.com/filebrowser/filebrowser) [Netdata](https://github.com/netdata/netdata) [MariaDB](https://mariadb.org/) [PHP](https://www.php.net/) RSSHUB [Tiny Tiny RSS](https://git.tt-rss.org/fox/tt-rss) Fail2ban [Speedtest](https://github.com/librespeed/speedtest) [TOR](https://famicoman.com/2018/01/03/configuring-and-monitoring-a-tor-middle-relay/) Postfix Dovecot Roundcube-Webmail等**
3. 全自动签发,续签,重启服务 [let's encrypt 证书](https://letsencrypt.org/)
17. [完整的IPV6支援](https://en.wikipedia.org/wiki/IPv6)
17. [Full HTTP/2 Support](https://en.wikipedia.org/wiki/HTTP/2)
18. [全自动时间较准](https://www.freedesktop.org/software/systemd/man/timedatectl.html)
19. 全自动服务掉线重启(systemd auto-failrestart)
20. 全自动检测并卸载阿里云监控
9.  支援 [TCP Turbo](https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks)
23. 支援完全/部分卸载
24. And so on...

#### 如果此项目对你有用 , 请给颗star ,谢谢!

* * *

# VPSTOOLBOX

One click install Trojan-gfw Hexo Nextcloud and so on.

[![Gitter](https://badges.gitter.im/vpstoolbox/community.svg)](https://gitter.im/vpstoolbox/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)
[![Join our Discord server!](https://img.shields.io/badge/discord-join-7289DA.svg?logo=discord&longCache=true&style=flat)](https://discord.gg/y5KUxfYZ)
[Chat on Telegram](https://t.me/vpstoolbox_chat)

## How to use
```
apt-get update && apt-get install sudo curl -y && curl -Ss https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/vps.sh | sudo bash
```

#### Important Reminder:
4. **Support [Debian8+](https://www.debian.org/) [Ubuntu14+](https://ubuntu.com/)**
1. Please **Run as root**(sudo -i)
3. Trojan-GFW **does not support Cloudflare CDN**,please do not enable!
2. Please **[Purchase a domain](https://www.namesilo.com/?rid=685fb47qi)** and **[finish a dns resolve](https://dnschecker.org/)**(A for ipv4,AAAA for ipv6) before running this program!
3. Please **turn off your firewall for best performance(full-cone nat) and turn off Cloudflare CDN** in your control panel before running this program!

Flowchart:
![flowchart](https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/images/flowchart.png)

#### Privacy Statement:

Ip Information is just an indispensable part of this project, all ip information comes from ipinfo.io,no spam related.

#### Features:

1. Auto install and config **[NGINX](https://www.nginx.com/)**
2. Support all kinds of virtualization including kvm openvz and so on.
20. Support Auto install and config **[Trojan-GFW](https://github.com/trojan-gfw/trojan) [Hexo](https://hexo.io/zh-tw/docs/) [Dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) [Qbittorrent](https://www.qbittorrent.org/) [Bittorrent-Tracker](https://github.com/webtorrent/bittorrent-tracker) [Aria2](https://github.com/aria2/aria2) [Filebrowser](https://github.com/filebrowser/filebrowser) [Netdata](https://github.com/netdata/netdata) [MariaDB](https://mariadb.org/) [PHP](https://www.php.net/) RSSHUB [Tiny Tiny RSS](https://git.tt-rss.org/fox/tt-rss) Fail2ban [TOR](https://famicoman.com/2018/01/03/configuring-and-monitoring-a-tor-middle-relay/) [Speedtest](https://github.com/librespeed/speedtest) Postfix Dovecot Roundcube-Webmail**
3. Auto issue and renew [let's encrypt certificate](https://letsencrypt.org/) and auto reload Trojan-GFW after renewal
17. [Full IPv6 Support](https://en.wikipedia.org/wiki/IPv6)
17. [Full HTTP/2 Support](https://en.wikipedia.org/wiki/HTTP/2)
18. [time sync](https://www.freedesktop.org/software/systemd/man/timedatectl.html)
19. Fail Restart
20. uninstall Aliyun Aegis
9.  Support [TCP Turbo](https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks)
23. Support Full/Part Uninstall
24. And so on...

#### If you found it useful , please give a star ,thanks!

#### License

[MIT](https://github.com/johnrosen1/vpstoolbox/blob/master/LICENSE)

#### 本项目不对Vultr机器造成的任何问题负责,this project does not responsible for any problems caused by vulrt machines !

## Stargazers over time

[![Stargazers over time](https://starchart.cc/johnrosen1/vpstoolbox.svg)](https://starchart.cc/johnrosen1/vpstoolbox)
