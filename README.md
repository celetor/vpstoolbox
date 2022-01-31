# ![VPSToolBox](logo.png)

[TG 群组](https://t.me/vpstoolbox_chat)

厌倦了总是需要手动输入命令安装博客，网盘，邮箱，代理了吗？VPSToolBox 提供了一种全自动化的解决方案，解放双手，从今天开始！

> 经观察，**证书自动续签的问题已解决**，方案已稳定，可长期正常使用。

## 一键命令 One click command

```bash
apt-get update --fix-missing && apt-get upgrade -y && apt-get install sudo curl -y && curl -Ss https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/vps.sh | sudo bash
```

> 注: 仅推荐 **Debian10/11** 系统。

## 前提条件及要点 Usage instruction

1. **Trojan-GFW 不支援 Cloudflare CDN ！！！** ( ![CF](images/cf1.png) )
2. 请以 **root(sudo -i)** 运行。
3. **可覆盖安装**。
4. 请自行[购买](https://www.namesilo.com/?rid=685fb47qi)/[白嫖](https://www.freenom.com)/使用现有的/**域名** 并 **[完成 DNS A 解析](https://dnschecker.org/)**，即将域名指向你的 VPS IP,(namesilo NS 最慢需要 15+min 生效)!
5. 请在 服务器/VPS/其他各种 控制面板中 **完全关闭或禁用 VPS 防火墙(即开放所有端口)**
> _Trojan-gfw 以及 Shadowsocks-rust 皆支援 **Fullcone-nat** 但需服务器开启所有端口才能使用。_
6. [HTTP 申请](https://github.com/acmesh-official/acme.sh/wiki/Blogs-and-tutorials) TLS 证书需 **域名 A 解析生效**，[API 申请](https://github.com/acmesh-official/acme.sh/wiki/dnsapi)则需要输入正确的信息。

## 免责声明 Disclaimer

1. 本项目不对使用 Vultr 提供的机器造成的任何可能问题负责(this project is not responsible for any possible problems caused by Vultr machines) !
2. 本项目部分应用需要较高的系统资源和服务器配置(Nextcloud,邮箱等)，这些都不是必选项，请量力而行 ！

## 支援的软件及应用 Supported applications

> 打勾的为启用默认安装的,其余请手动选中以安装,分类标签仅供参考。

- 代理
  - [x] [Trojan-gfw](https://github.com/trojan-gfw/trojan)
  - [ ] [Shadowsocks-rust](https://github.com/shadowsocks/shadowsocks-rust)
  - [ ] [Trojan-panel](https://github.com/trojan-gfw/trojan-panel)
- 系统
  - [x] [Acme.sh](https://github.com/acmesh-official/acme.sh)
  - [x] [IPv6](https://zh.wikipedia.org/wiki/IPv6)
  - [x] [Tcp-BBR and tcp_fastopen](https://zh.wikipedia.org/wiki/TCP%E6%8B%A5%E5%A1%9E%E6%8E%A7%E5%88%B6#TCP_BBR)
  - [x] [Netdata](https://github.com/netdata/netdata)
- 前端
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
  - [ ] [Miniflux](https://miniflux.app/index.html)
        ~~- [ ] [Tiny Tiny RSS](https://git.tt-rss.org/fox/tt-rss)~~
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
  - [ ] 自定义 Trojan 端口(Non standard https port support)
  - [ ] [Qbittorrent_origin_version](https://github.com/qbittorrent/qBittorrent)
- 区块链
  - [ ] [Monero/XMR](https://github.com/monero-project/monero-gui)

> 欢迎 PR/issue 更多软件。

## 尚未添加/整合/测试的软件 To be done

咕咕咕。

- 影音

- [ ] [Jackett](https://github.com/Jackett/Jackett)
- [ ] [Radarr](https://github.com/Radarr/Radarr)
- [ ] [Lidarr](https://github.com/lidarr/Lidarr)
- [ ] [Sonarr](https://github.com/Sonarr/Sonarr)
- [ ] [Bazarr](https://github.com/morpheus65535/bazarr)
- [ ] [音乐解锁](https://github.com/unlock-music/unlock-music)
- [ ] [youtube-dl](https://github.com/ytdl-org/youtube-dl)

- 前端

- [mikutap](https://github.com/akirarika/mikutap)

## 支援的 Linux 发行版

> 打勾的为测试过的,保证可用性,未打勾的表示理论上支援但未测试。

- [x] Debian11
- [x] Debian10
- [x] Debian9
- [x] Ubuntu 20.xx
- [x] Ubuntu 18.xx

## 项目实现 Program Language

使用`bash shell`实现。

## 贡献 Contritbution

1. **Fork**本项目
2. **Clone**到你自己的机器
3. **Commit** 修改
4. **Push** 到你自己的 Fork
5. 提交**Pull request**
6. PR 要求请看[**pr 要求**](https://github.com/johnrosen1/vpstoolbox/tree/dev/install)

## Bug 反馈以及 Feature request

- [x] [Github Issue](https://github.com/johnrosen1/vpstoolbox/issues)
- [x] [TG 群组](https://t.me/vpstoolbox_chat)

注：

1. 其他的反馈方式我大概率看不见。
2. 除非你有能说服我的理由或者直接提 pr,否则**不接受代理软件支援请求**(比如 wireguard 之类的)。
3. 无论发生什么请**务必附上复现错误的步骤，截图，OS 发行版等信息**,否则我不可能能够提供任何帮助。

## Code Quality

1. 本项目实现了**模块化**
2. 本项目我个人从学习 bash 开始就写起的项目,可能有诸多不合理之处,不建议作为直接教材学习。

## Rclone 以及全自动上传脚本使用方法

**[Aria2+Rclone+Onedrive 实现全自动化下载](https://johnrosen1.com/2021/02/14/onedrive/)**

## Trojan-panel 使用方法

- Trojan-panel 默认不安装,请**手动选中**以执行安装程序。
- 进入生成的 url,**首次注册的用户为管理员(admin)**。
- 用户需联系管理员(admin)申请流量(**设置为-1 为不限流量**)。
- 客户端配置文件中的密码为用户注册在 Panel 时填入的：`Username:Password`(**中间的`:`不能漏!**)。
- 若出现`File not found. `错误,刷新页面即可。
- 更多请看[Trojan-panel 使用方法](https://johnrosen1.com/2021/02/01/trojan-panel/)

## Nextcloud 优化方法

> 由于 Nextcloud 自身限制,无法全自动添加 redis 配置,请手动配置。

1. 开启 Memcache
   在`/usr/share/nginx/nextcloud/config/config.php`中添加以下几行(请添加在中间，非开头或末尾)

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
  'default_phone_region' => 'CN',
```

[相关文档](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/config_sample_php_parameters.html)

2. 优化索引

运行以下几行

```
cd /usr/share/nginx/nextcloud/
sudo -u nginx ./occ db:add-missing-indices
sudo -u nginx ./occ db:convert-filecache-bigint
cd
```

3. 切换后台进程方式为 cron(Nextcloud 会自己切换,如未切换请手动切换)

Nextcloud 设定-->基本设定-->改为 cron(伺服器端已配置完成，无需任何手动配置)

4. 重启服务使配置生效

```
systemctl restart php7.4-fpm
```

## 邮箱服务(Mail Service)使用条件

1. 一台有**独立公网 IPv4**的非中国大陆 VPS/伺服器且**25/143/443/465/587/993 等 TCP 端口必须能正常使用**。
   > _阿里云，Google cloud platform,vultr 等厂商皆不满足此项要求（当然你乐意去跟他们交涉的话就不关我事了。）。_
2. 伺服器/VPS 必须拥有大于等于 **2+GB RAM 以及 30+GB Storage**.
3. 一个付费域名(推荐[Namesilo](https://www.namesilo.com/?rid=685fb47qi)),.com/.xyz/.moe 等后缀无所谓。
4. 你的伺服器(VPS) 必须支援**rDNS(PTR) record**(除非你希望你的邮件被列为 spam)。
5. 你的伺服器(VPS) 的 ip 必须不在各种邮件黑名单里面(否则你发的所有邮件都会被列为 spam)。
6. 本项目暂不支援 Postfixadmin,LDAP 等相关功能。
7. 全自动垃圾删除功能默认垃圾邮件 30d 清理，已删除 14d 。

> 由于邮箱服务的特殊性,仅推荐有需求(且乐意折腾)的人使用。

## Debug 相关

1. 本项目主要采用 systemd+docker-compose 启动服务。
2. 具体的懒得写了,`systemctl`查看运行状态,有问题记得反馈即可。

## 流量示意图

> 可能不完整,仅供参考。

![https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/images/flow_zh_cn.png](https://raw.githubusercontent.com/johnrosen1/vpstoolbox/master/images/flow_zh_cn.png)

## 恰饭 aff

1. [Namesilo](https://www.namesilo.com/?rid=685fb47qi)

## License

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

## 如果本项目帮助到了你,那真是太好不过了!!

[![Stargazers over time](https://starchart.cc/johnrosen1/vpstoolbox.svg)](https://starchart.cc/johnrosen1/vpstoolbox)

## 题外话，看看就好

1. 这个项目的初衷是什么？
   A: 我主要是因为懒，所以才创立的这个项目。
2. 这个项目花费了多少时间完成？
   A: 林林总总的也有上千小时了吧，不算维护花费的时间吧。
3. 这个项目花费了多少资金？
   A: 金钱方面的花费倒是不多。
4. 这个项目目前是什么情况？
   A: 已经没什么值得添加的新功能了，我只能维护维护罢了，这个项目也没有什么热度。
5. 开发这个项目最耗时间的是什么事情？
   A: 查询各种各样的文档以及各种调试工作。
6. 是否有想放弃的时候？
   A: 有些功能确实特别难搞，中途确实有不管不顾的时候，但是最后还是坚持下来了。
7. 开发这个项目最大的收获是什么？
   A: 最大的收获我个人觉得不是学到了什么牛逼的技术，而是学到了项目开发所需的各种基础技能。
8. 最可惜的是什么？
   A: 我觉得最可惜的可能是基本只有我一个人开发，没多少人帮我。
