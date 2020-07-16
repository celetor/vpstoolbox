![logo](https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/logo.png)
# VPS Toolbox

超级Linux VPS工具箱，一键安装包含TLEMP(Trojan-GFW+Linux+NGINX+MariaDB+PHP7.4),全能下载套件(Qbitttorrent-nox+Aria2c+Filebrowser),RSS套件(RSSHUB+Tiny Tiny RSS),邮箱套件(Postfix+Dovecot+Roundcube Webmail),伺服器实时监控(Netdata)等实用软件(除NGINX外皆为可选项)。

#### 使用方法(請以root/sudo用戶運行)
```
apt-get update && apt-get install sudo curl -y && curl -Ss https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/vps.sh | sudo bash
```

流量图示(仅供参考):
![flowchart](https://raw.githubusercontent.com/jerrypoma/trojan-gfw-script/master/vpstoolbox.png)

#### 隐私声明:

1. 此项目使用MIT开源协议，欢迎PR.
2. Ip Information is just an indispensable part of this project, all ip information comes from ipinfo.io,no spam related.

#### 友情提示:
1. 请 **以root/sudoer身份运行**(sudo -i)
2. 请 **[先购买一个域名](https://www.namesilo.com/?rid=685fb47qi)** 并 **[完成DNS解析](https://dnschecker.org/)**!
3. 请在控制面板中 **开启TCP端口 [80](https://www.speedguide.net/port.php?port=80) 以及 [443](https://www.speedguide.net/port.php?port=443) 并 关闭 Cloudflare CDN** !
4. 如果您需要使用自定义证书(不推荐) , 请放在 /etc/trojan/ 里面 , 不需要修改名称(证书类型需为fullchain) !
5. 请使用一台有至少 **0.5 GB RAM** 以及 **5G 硬盘空间的VPS**. 
6. 出于安全原因，本脚本已禁止360/qq/xiaomi/wechat等垃圾国产浏览器访问最终结果页面及相关服务，请使用chrome/firefox等访问。

#### 特性:

1. 全自动安装并配置 **[NGINX Web Server](https://www.nginx.com/)**
2. 支援所有种类的虚拟化技术，包括kvm openvz等
20. 支援全自动安装并配置 **[Trojan-GFW](https://github.com/trojan-gfw/trojan) [Dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) [Qbittorrent](https://www.qbittorrent.org/) [Bittorrent-Tracker](https://github.com/webtorrent/bittorrent-tracker) [Aria2](https://github.com/aria2/aria2) [Filebrowser](https://github.com/filebrowser/filebrowser) [Netdata](https://github.com/netdata/netdata) [MariaDB](https://mariadb.org/) [PHP](https://www.php.net/) RSSHUB [Tiny Tiny RSS](https://git.tt-rss.org/fox/tt-rss) Fail2ban [Speedtest](https://github.com/librespeed/speedtest) [TOR](https://famicoman.com/2018/01/03/configuring-and-monitoring-a-tor-middle-relay/) [Trojan-panel](https://github.com/trojan-gfw/trojan-panel) Postfix Dovecot Roundcube-Webmail**
3. 全自动签发,续签,重启服务 [let's encrypt 证书](https://letsencrypt.org/)
4. **支援 [Debian](https://www.debian.org/) [Ubuntu](https://ubuntu.com/)**
16. 随机HTML模板选择
17. [完整的IPV6支援](https://en.wikipedia.org/wiki/IPv6)
17. [Full HTTP/2 Support](https://en.wikipedia.org/wiki/HTTP/2)
18. [全自动时间较准](https://www.freedesktop.org/software/systemd/man/timedatectl.html)
19. 全自动服务掉线重启
20. [全自动检测并卸载阿里云监控](https://www.johnrosen1.com/ali-iso/)
9.  支援 [TCP Turbo](https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks)
15. 支援 [TLS1.3 ONLY](https://wiki.openssl.org/index.php/TLS1.3)
21. 支援手动更新（Trojan-GFW为全自动更新，binary only）
23. 支援完全/部分卸载
24. And so on...

### Give it a try ! (Live Demo,no Guarantee)

[https://trojan-gfw.xyz/vpstoolbox.html](https://trojan-gfw.xyz/vpstoolbox.html)

## 如果此项目对你有用 , 请给颗star ,谢谢!
