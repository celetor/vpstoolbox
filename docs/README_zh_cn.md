![logo](https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/logo.png)
# VPS Toolbox

超级Linux VPS脚本工具箱，**一键安装Trojan-GFW代理,Hexo博客,RSS,邮件,Qbittorrent,Aria2,Netdata等應用程式**。

[![Gitter](https://badges.gitter.im/vpstoolbox/community.svg)](https://gitter.im/vpstoolbox/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

[Telegram群組](https://t.me/vpstoolbox_chat)

#### 使用方法(請以root/sudo用戶運行)
```
apt-get update && apt-get install sudo curl -y && curl -Ss https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/vps.sh | sudo bash
```

流量图示(仅供参考):
![flowchart](https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/images/flow_zh_cn.png)

#### 隐私声明:

1. 此项目使用MIT开源协议，**欢迎PR**.
2. Ip Information is just an indispensable part of this project, all ip information comes from ipinfo.io,no spam related.

#### 友情提示:
1. 请 **以root/sudoer身份运行**(sudo -i)
2. 请 **[先购买一个域名](https://www.namesilo.com/?rid=685fb47qi)** 并 **[完成DNS解析](https://dnschecker.org/)**!
3. 请在控制面板中 **开启TCP端口 [80](https://www.speedguide.net/port.php?port=80) 以及 [443](https://www.speedguide.net/port.php?port=443)** 并 ***关闭 Cloudflare CDN !***
4. 如果您出于某些原因需要使用自定义证书(不推荐) , 请放在 /etc/trojan/ 里面 , 不需要修改名称(证书类型需为fullchain) !
5. 请使用一台有至少 **0.5 GB RAM** 以及 **5G 硬盘空间的VPS**. 
6. 出于安全原因，本项目已禁止360/qq/xiaomi/wechat等垃圾国产浏览器访问最终结果页面及相关服务，请使用chrome/firefox等访问。

#### 特性:

1. 全自动安装并配置 **[NGINX Web Server](https://www.nginx.com/) 以及 Hexo**
2. 支援所有种类的虚拟化技术，包括bare mental,kvm openvz等
20. 支援全自动安装并配置 **[Trojan-GFW](https://github.com/trojan-gfw/trojan) [Hexo](https://hexo.io/zh-tw/docs/) [Dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) [Qbittorrent](https://www.qbittorrent.org/) [Bittorrent-Tracker](https://github.com/webtorrent/bittorrent-tracker) [Aria2](https://github.com/aria2/aria2) [Filebrowser](https://github.com/filebrowser/filebrowser) [Netdata](https://github.com/netdata/netdata) [MariaDB](https://mariadb.org/) [PHP](https://www.php.net/) RSSHUB [Tiny Tiny RSS](https://git.tt-rss.org/fox/tt-rss) Fail2ban [Speedtest](https://github.com/librespeed/speedtest) [TOR](https://famicoman.com/2018/01/03/configuring-and-monitoring-a-tor-middle-relay/) [Trojan-panel](https://github.com/trojan-gfw/trojan-panel) Postfix Dovecot Roundcube-Webmail**
3. 全自动签发,续签,重启服务 [let's encrypt 证书](https://letsencrypt.org/)
4. **支援 [Debian](https://www.debian.org/) [Ubuntu](https://ubuntu.com/)**
17. [完整的IPV6支援](https://en.wikipedia.org/wiki/IPv6)
17. [Full HTTP/2 Support](https://en.wikipedia.org/wiki/HTTP/2)
18. [全自动时间较准](https://www.freedesktop.org/software/systemd/man/timedatectl.html)
19. 全自动服务掉线重启(systemd auto-failrestart)
20. [全自动检测并卸载阿里云监控](https://www.johnrosen1.com/ali-iso/)
9.  支援 [TCP Turbo](https://github.com/shadowsocks/shadowsocks/wiki/Optimizing-Shadowsocks)
23. 支援完全/部分卸载
24. And so on...

### 小白向教程

[VPSTOOLBOX基础使用方法](https://github.com/johnrosen1/vpstoolbox/wiki/VPSTOOLBOX%E5%9F%BA%E7%A1%80%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95)

### Give it a try ! (Live Demo,no Guarantee)

[https://trojan-gfw.xyz/vpstoolbox/](https://trojan-gfw.xyz/vpstoolbox/)

## 如果此项目对你有用 , 请给颗star ,谢谢!

***请勿使用Vultr运行本项目,vultr导致的一切错误,本项目不负责！！！***
