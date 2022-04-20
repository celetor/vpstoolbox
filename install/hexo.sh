#!/usr/bin/env bash

## Hexo模组 Hexo moudle

set +e

install_hexo(){
TERM=ansi whiptail --title "安装中" --infobox "安装Hexo中..." 7 68
  colorEcho ${INFO} "Install Hexo ing..."
  cd /usr/share/nginx
  npm install -g npm
  npm install hexo-cli -g
  npm update
  hexo init hexo
  cd /usr/share/nginx/hexo
  npm audit fix
  npm prune
  hexo new page ${password1}
  cd /usr/share/nginx/hexo/themes
  apt-get install git -y
  git clone https://github.com/theme-next/hexo-theme-next next
  cd /usr/share/nginx/hexo
  npm install hexo-generator-feed --save
  npm install hexo-filter-nofollow --save
  npm install hexo-migrator-rss --save
    cat > '/usr/share/nginx/hexo/_config.yml' << EOF
#title: xxx's Blog
#author: xxx
#description: xxx的博客。
language: zh-CN
url: https://${domain}
theme: next
post_asset_folder: true
feed:
  type: atom
  path: atom.xml
  limit: 20
  hub:
  content: true
  content_limit: 140
  content_limit_delim: ' '
  order_by: -date
  icon: icon.png
  autodiscovery: true
  template:
nofollow:
  enable: true
  field: site
  exclude:
    - 'exclude1.com'
    - 'exclude2.com'
EOF

## Enable CC license (by-nc-sa)

sed -i '0,/sidebar: false/s//sidebar: true/' /usr/share/nginx/hexo/themes/next/_config.yml
sed -i '0,/post: false/s//post: true/' /usr/share/nginx/hexo/themes/next/_config.yml
sed -i '0,/darkmode: false/s//darkmode: true/' /usr/share/nginx/hexo/themes/next/_config.yml
sed -i '0,/lazyload: false/s//lazyload: true/' /usr/share/nginx/hexo/themes/next/_config.yml
sed -i '0,/lazyload: false/s//lazyload: true/' /usr/share/nginx/hexo/themes/next/_config.yml

cd /usr/share/nginx/hexo/source/${password1}
if [[ -f index.md ]]; then
  rm index.md
fi
cat > "index.md" << EOF
---
title: VPS Toolbox Result
---

欢迎使用[VPSToolBox](https://github.com/johnrosen1/vpstoolbox) ! 此页面由[Hexo](https://hexo.io/zh-tw/docs/)全自动生成,如果你在使用VPSToolBox时遇到任何问题,请仔细阅读以下所有链接以及信息或者**通过 [Telegram](https://t.me/vpstoolbox_chat)请求支援** !

如果觉得好用，欢迎打钱帮助开发或者尝试以下服务，😃❤️🤣：

ETH：0x9DB5737AB34E1F5d1303E9eD726776eebba3BF16

[Namesilo](https://www.namesilo.com/?rid=685fb47qi)

[阿里云](https://www.aliyun.com/daily-act/ecs/activity_selection?userCode=fgdncdz2)

[Hostyun](https://my.hostyun.com/page.aspx?c=referral&u=27710)

---

### Trojan-GFW 链接

1. trojan://${password1}@${domain}:${trojanport}?security=tls&headerType=none&type=tcp&sni=${domain}#Trojan(${route_final}${mycountry} ${mycity} ${myip})
2. trojan://${password2}@${domain}:${trojanport}?security=tls&headerType=none&type=tcp&sni=${domain}#Trojan(${route_final}${mycountry} ${mycity} ${myip})

#### 相关链接(重要!)

1. <a href="https://github.com/trojan-gfw/igniter/releases" target="_blank" rel="noreferrer">Android client</a> 安卓客户端
2. <a href="https://apps.apple.com/us/app/shadowrocket/id932747118" target="_blank" rel="noreferrer">ios client</a>苹果客户端
3. <a href="https://github.com/trojan-gfw/trojan/releases/latest" target="_blank" rel="noreferrer">windows client</a>windows客户端
4. <a href="https://github.com/NetchX/Netch" target="_blank" rel="noreferrer">https://github.com/NetchX/Netch</a>推荐的**游戏**客户端
5. <a href="https://chrome.google.com/webstore/detail/proxy-switchyomega/padekgcemlokbadohgkifijomclgjgif" target="_blank" rel="noreferrer">Proxy SwitchyOmega</a>
6. <a href="https://github.com/gfwlist/gfwlist/blob/master/gfwlist.txt" target="_blank" rel="noreferrer">Gfwlist(请配合SwichyOmega食用)</a>

---

### Vless(Grpc)

Vless(grpc)链接(支持Cloudflare CDN)

vless://${uuid_new}@${domain}:${trojanport}?mode=gun&security=tls&type=grpc&serviceName=${path_new}&sni=${domain}#Vless(${route_final}${mycountry} ${mycity} ${myip})

---

### 影音(包含qBittorrent加强版)

前端
<a href="https://$domain:${trojanport}/emby/" target="_blank" rel="noreferrer">emby</a>
<a href="https://$domain:${trojanport}/ombi/" target="_blank" rel="noreferrer">ombi</a>
中间层
<a href="https://$domain:${trojanport}/sonarr/" target="_blank" rel="noreferrer">sonarr</a>
<a href="https://$domain:${trojanport}/radarr/" target="_blank" rel="noreferrer">radarr</a>
<a href="https://$domain:${trojanport}/lidarr/" target="_blank" rel="noreferrer">lidarr</a>
<a href="https://$domain:${trojanport}/readarr/" target="_blank" rel="noreferrer">readarr</a>
字幕
<a href="https://$domain:${trojanport}/bazarr/" target="_blank" rel="noreferrer">bazarr</a>
<a href="https://$domain:${trojanport}/chinesesubfinder/" target="_blank" rel="noreferrer">chinesesubfinder</a>
索引器
<a href="https://$domain:${trojanport}/prowlarr/" target="_blank" rel="noreferrer">prowlarr</a>
下载器
<a href="https://$domain:${trojanport}/qbt/" target="_blank" rel="noreferrer">qbt</a>
<a href="https://$domain:${trojanport}/nzbget/" target="_blank" rel="noreferrer">nzbget</a>

---

### Rsshub + Miniflux

#### RSSHUB

<a href="https://$domain/rsshub/" target="_blank" rel="noreferrer">https://$domain/rsshub/</a>

#### Miniflux

- <a href="https://$domain/miniflux/" target="_blank" rel="noreferrer">https://$domain/miniflux/</a>
- 用户名(username): **admin**
- 密碼(password): **${password1}**

---

### Aria2

#### AriaNG

- <a href="https://$domain:443/ariang/" target="_blank" rel="noreferrer">https://$domain/ariang/</a>

#### Aria2

- https://$domain:443$ariapath
- 密碼(Aria2 RPC金钥,token): **$ariapasswd**

---

### Filebrowser

- <a href="https://$domain:443/file/" target="_blank" rel="noreferrer">https://$domain/file/</a>
- 用户名(username): **admin**
- 密碼(token): **admin**

> *请自行修改初始用户名和密码！*

---



### Speedtest

- <a href="https://$domain:443/${password1}_speedtest/" target="_blank" rel="noreferrer">https://$domain/${password1}_speedtest/</a>

---

### Netdata

> 简介: 一款 **实时效能监测工具** 应用。

- <a href="https://$domain:443/${password1}_netdata/" target="_blank" rel="noreferrer">https://${domain}/${password1}_netdata/</a>

---

### Rocket Chat

- <a href="https://$domain:443/chat/" target="_blank" rel="noreferrer">https://$domain/rocketchat/</a>

---

### Mail Service

#### Roundcube Webmail

- <a href="https://${domain}/mail/" target="_blank" rel="noreferrer">Roundcube Webmail</a>
- 用户名(username): ${mailuser}
- 密碼(password): ${password1}
- 收件地址: **${mailuser}@${domain}**

#### Tips:

1. 请自行添加SPF(TXT) RECORD: v=spf1 mx ip4:${myip} a ~all
2. 请自行运行sudo cat /etc/opendkim/keys/${domain}/default.txt 来获取生成的DKIM(TXT) RECORD

---

### Typecho

请自行注释掉*/etc/nginx/conf.d/default.conf*中的Hexo部分并去掉Typecho的注释以启用Typecho。

EOF
cd /usr/share/nginx/hexo/
hexo g
hexo d
cd
hexo_location=$(which hexo)
    cat > '/etc/systemd/system/hexo.service' << EOF
[Unit]
Description=Hexo Server Service
Documentation=https://hexo.io/zh-tw/docs/
After=network.target

[Service]
WorkingDirectory=/usr/share/nginx/hexo
ExecStart=${hexo_location} server -i 127.0.0.1
LimitNOFILE=infinity
Restart=always
RestartSec=3s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable hexo --now
}
