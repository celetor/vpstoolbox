# ![VPSToolBox](logo.png)

[TG群组](https://t.me/vpstoolbox_chat)

一键安装Trojan-GFW代理,Hexo博客,Nextcloud等應用程式。

## 一键命令

```bash
apt-get update && apt-get install sudo curl -y && curl -Ss https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/vps.sh | sudo bash
```

> 注: 仅推荐**Debian10**系统。

## 使用要点

1. 请以 **root/sudoer** 身份运行(sudo -i)
2. 请自行[购买](https://www.namesilo.com/?rid=685fb47qi)/[白嫖](https://www.freenom.com)/使用现有的/**域名** 并 **[完成DNS A解析](https://dnschecker.org/)**,即将域名指向你的VPS IP,(ipv6地址请添加AAAA解析,namesilo最慢需要15min生效)!
3. 请在VPS控制面板中 **完全关闭VPS防火墙(即开放所有端口)**(Trojan-gfw以及Shadowsocks-rust皆支援fullcone-nat但需服务器开启所有端口才能使用) 并 **关闭 Cloudflare CDN** !
4. API申请证书和HTTP申请证书区别不大,推荐HTTP申请(需A解析生效),无需输入API等信息。

## 支援的软件

> 打勾的为启用默认安装的,其余请手动选中以安装,分类标签仅为参考。

- 代理
  - [x] [Trojan-gfw](https://github.com/trojan-gfw/trojan)
  - [x] [Acme.sh](https://github.com/acmesh-official/acme.sh)
  - [ ] [Shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)
  - [ ] [Trojan-panel](https://github.com/trojan-gfw/trojan-panel)
- 系统
  - [x] [IPv6](https://zh.wikipedia.org/wiki/IPv6)
  - [x] [Tcp-BBR and tcp_fastopen](https://zh.wikipedia.org/wiki/TCP%E6%8B%A5%E5%A1%9E%E6%8E%A7%E5%88%B6#TCP_BBR)
  - [x] [Netdata](https://github.com/netdata/netdata)
- 博客
  - [x] [Nginx](https://github.com/nginx/nginx)
  - [x] [Hexo Blog](https://github.com/hexojs/hexo)
  - [ ] [Typecho](https://typecho.org/)
- 下载
  - [ ] [Qbittorrent_enhanced_version](https://github.com/c0re100/qBittorrent-Enhanced-Edition)
  - [ ] [Aria2](https://github.com/aria2/aria2)
  - [ ] [AriaNG](https://github.com/mayswind/AriaNg/)
- 网盘
  - [ ] [Nextcloud](https://github.com/nextcloud/server)
  - [ ] [Rclone](https://github.com/rclone/rclone)
  - [ ] [Filebrowser](https://github.com/filebrowser/filebrowser)
  - [ ] [Onedrive](https://johnrosen1.com/2021/02/14/onedrive/)
- RSS
  - [ ] [RSSHub](https://github.com/DIYgod/RSSHub)
  - [ ] [Tiny Tiny RSS](https://git.tt-rss.org/fox/tt-rss)
- 影音(待完善)
  - [ ] [JellyFin](https://github.com/jellyfin/jellyfin)
- 邮箱
  - [ ] [Mail Service](https://johnrosen1.com/2020/08/27/mail1/)
- 通讯
  - [ ] [RocketChat](https://github.com/RocketChat/Rocket.Chat)
- 测速
  - [ ] [Librespeed](https://github.com/librespeed/speedtest)
- 安全
  - [ ] [Fail2ban](https://github.com/fail2ban/fail2ban)
- 数据库
  - [ ] [MariaDB](https://github.com/MariaDB/server)
  - [ ] [Redis-server](https://github.com/redis/redis)
  - [ ] [MongoDB](https://github.com/mongodb/mongo)
- 暗网
  - [ ] [i2pd](https://github.com/PurpleI2P/i2pd)
  - [ ] [Tor](https://www.torproject.org/)
- 其他
  - [ ] [Docker](https://www.docker.com/)
  - [ ] [Opentracker](https://erdgeist.org/arts/software/opentracker/)
  - [ ] [stun-server](https://github.com/jselbie/stunserver)
  - [ ] [Dnscrypt-proxy2](https://github.com/DNSCrypt/dnscrypt-proxy)
  - [ ] Non standard https port support
  - [ ] [Qbittorrent_origin_version](https://github.com/qbittorrent/qBittorrent)

> 欢迎PR/issue更多软件。

## 尚未添加/整合/测试的软件

> 欢迎PR/request。

- 系统

- [ ] [BBRv2](https://github.com/google/bbr/tree/v2alpha)

- 影音

- [ ] [Jackett](https://github.com/Jackett/Jackett)
- [ ] [Radarr](https://github.com/Radarr/Radarr)
- [ ] [Lidarr](https://github.com/lidarr/Lidarr)
- [ ] [Sonarr](https://github.com/Sonarr/Sonarr)
- [ ] [Bazarr](https://github.com/morpheus65535/bazarr)

- 通讯

- [ ] [insp ircd](https://github.com/inspircd/inspircd) IRC伺服器

更多的在路上了,咕咕咕。

## 支援的Linux发行版

> 打勾的为测试过的,保证可用性,未打勾的表示理论上支援但未测试。

- [x] Debian10
- [ ] Debian9
- [ ] Debian8
- [ ] Ubuntu 20.xx
- [ ] Ubuntu 18.xx
- [ ] Ubuntu 16.xx

## 项目实现

使用```100% bash shell```实现。

## 重要提示

1. 本项目**可覆盖安装，无需重建伺服器/VPS !**
2. Trojan-GFW**不支援Cloudflare CDN**,请勿开启!
3. 证书续签目前使用crontab,如有问题,欢迎反馈 !
4. 本项目不对Vultr机器造成的任何问题负责,this project is not responsible for any problems caused by Vultr machines !

## 贡献

1. **Fork**本项目
2. **Clone**到你自己的机器
3. **Commit** 修改
4. **Push** 到你自己的Fork
5. 提交**Pull request**
6. PR要求请看[**pr要求**](https://github.com/johnrosen1/vpstoolbox/tree/dev/install)

## Bug反馈以及Feature request

- [x] [Github Issue](https://github.com/johnrosen1/vpstoolbox/issues)
- [x] [TG群组](https://t.me/vpstoolbox_chat)
- [x] [TG私聊](https://t.me/johnrosen)

注： 

1. 其他的反馈方式我大概率看不见。
2. 除非你有能说服我的理由或者直接提pr,否则**不接受代理软件支援请求**(比如wireguard之类的)。
3. 无论发生什么请**务必附上复现错误的步骤，截图，OS发行版等信息**,否则我不可能能够提供任何帮助。
4. **私聊请直奔主题**,请勿询问 *域名怎么买?* 这种小白向问题,大家的时间都是有限的,谢谢配合。

## Code Quality

1. 本项目实现了**模块化**
2. 本项目我个人从学习bash开始就写起的项目,可能有诸多不合理之处,不建议作为直接教材学习。

## Rclone以及全自动上传脚本使用方法

**[Aria2+Rclone+Onedrive实现全自动化下载](https://johnrosen1.com/2021/02/14/onedrive/)**

## Trojan-panel使用方法

- Trojan-panel默认不安装,请**手动选中**以执行安装程序。
- 进入生成的url,**首次注册的用户为管理员(admin)**。
- 用户需联系管理员(admin)申请流量(**设置为-1为不限流量**)。
- 客户端配置文件中的密码为用户注册在Panel时填入的：```Username:Password```(**中间的```:```不能漏!**)。
- 若出现```File not found. ```错误,刷新页面即可。
- 更多请看[Trojan-panel使用方法](https://johnrosen1.com/2021/02/01/trojan-panel/)

## Nextcloud优化方法

> 由于Nextcloud自身限制,无法全自动添加redis配置,请手动配置。

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

## 邮箱服务(Mail Service)使用条件

1. 一台有**独立公网IPv4**的非中国大陆VPS/伺服器且**25/80/143/443/465/587/993等TCP端口必须能正常使用**。
> *阿里云，Google cloud platform,vultr等厂商皆不满足此项要求*。
2. 伺服器/VPS必须拥有大于等于 **2GB RAM 以及 30GB Storage**(SSD最好).
3. 一个付费域名(推荐[Namesilo](https://www.namesilo.com/?rid=685fb47qi)),.com/.xyz/.moe等后缀无所谓。
4. 你的伺服器或VPS厂商必须支援**rDNS(PTR) record**(除非你希望你的邮件被列为spam)。
5. 你的伺服器或者VPS的ip必须不在各种邮件黑名单里面(否则你发的所有邮件都会被列为spam)。
6. 本项目暂不支援Postfixadmin,LDAP等企业级服务。

> 由于邮箱服务的特殊性,仅推荐有需求的人使用。

## Debug相关

1. 本项目主要采用systemd+docker-compose启动服务。
2. 具体的懒得写了,```systemctl```查看运行状态,有问题记得反馈即可。

## 流量示意图

> 可能不完整,仅供参考。

![https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/images/flow_zh_cn.png](https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/images/flow_zh_cn.png)

## 如果本项目帮助到了你,请给颗star并帮忙推广,谢谢!

[![Stargazers over time](https://starchart.cc/johnrosen1/vpstoolbox.svg)](https://starchart.cc/johnrosen1/vpstoolbox)

## 捐赠

BTC: `bc1qtcmu8fc0fv9ksedh38msdvfaqdga5s2u8fmsy6`

> 你的捐赠对我而言是最大的帮助,但请不要勉强。

## 執照

```
MIT License

Copyright (c) 2019-2021 johnrosen1

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
