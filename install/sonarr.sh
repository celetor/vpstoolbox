#!/usr/bin/env bash

## Sonarr + Jackett 模组

set +e

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

uid=$(id -u nginx)
gid=$(id -g nginx)

## 文件夹

### 一级子目录(sonarr,radarr)
mkdir /usr/share/nginx/data/
### 二级子目录(qbt,emby,bazarr)
mkdir /usr/share/nginx/data/torrents/
mkdir /usr/share/nginx/data/usenet/
mkdir /usr/share/nginx/data/media/
### 三级子目录(none)
mkdir /usr/share/nginx/data/torrents/movies/
mkdir /usr/share/nginx/data/torrents/music/
mkdir /usr/share/nginx/data/torrents/tv/
mkdir /usr/share/nginx/data/usenet/movies/
mkdir /usr/share/nginx/data/usenet/music/
mkdir /usr/share/nginx/data/usenet/tv/
mkdir /usr/share/nginx/data/media/movies/
mkdir /usr/share/nginx/data/media/music/
mkdir /usr/share/nginx/data/media/tv/


install_sonarr(){
cd /usr/share/nginx/
mkdir sonarr
cd /usr/share/nginx/sonarr


    cat > "docker-compose.yml" << EOF
version: "3.8"
services:
  sonarr:
    network_mode: host
    image: lscr.io/linuxserver/sonarr
    container_name: sonarr
    environment:
      - PUID=${uid}
      - PGID=${gid}
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/sonarr/data:/config
      - /usr/share/nginx/data:/data
    restart: unless-stopped
EOF

docker-compose up -d
sleep 10s;

cat /usr/share/nginx/sonarr/data/config.xml | grep AnalyticsEnabled &> /dev/null

if [[ $? != 0 ]]; then
docker-compose down
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/sonarr\/<\/UrlBase>/g" /usr/share/nginx/sonarr/data/config.xml
sed -i '$d' /usr/share/nginx/sonarr/data/config.xml
echo '  <AnalyticsEnabled>False</AnalyticsEnabled>' >> /usr/share/nginx/sonarr/data/config.xml
echo '  <UpdateAutomatically>True</UpdateAutomatically>' >> /usr/share/nginx/sonarr/data/config.xml
echo '</Config>' >> /usr/share/nginx/sonarr/data/config.xml
docker-compose up -d
fi
cd

cd /usr/share/nginx/
mkdir radarr
cd /usr/share/nginx/radarr

## 7878

    cat > "docker-compose.yml" << EOF
version: "3.8"
services:
  radarr:
    network_mode: host
    image: lscr.io/linuxserver/radarr
    container_name: radarr
    environment:
      - PUID=${uid}
      - PGID=${gid}
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/radarr/data:/config
      - /usr/share/nginx/data:/data
    restart: unless-stopped
EOF

docker-compose up -d
sleep 10s;

cat /usr/share/nginx/radarr/data/config.xml | grep AnalyticsEnabled &> /dev/null

if [[ $? != 0 ]]; then
docker-compose down
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/radarr\/<\/UrlBase>/g" /usr/share/nginx/sonarr/data/config.xml
sed -i '$d' /usr/share/nginx/radarr/data/config.xml
echo '  <AnalyticsEnabled>False</AnalyticsEnabled>' >> /usr/share/nginx/radarr/data/config.xml
echo '  <UpdateAutomatically>True</UpdateAutomatically>' >> /usr/share/nginx/radarr/data/config.xml
echo '</Config>' >> /usr/share/nginx/radarr/data/config.xml
docker-compose up -d
fi
cd


cd /usr/share/nginx/
mkdir jackett
cd /usr/share/nginx/jackett
mkdir /usr/share/nginx/jackett/config
mkdir /usr/share/nginx/jackett/downloads

## 8191

    cat > "docker-compose.yml" << EOF
version: "3.8"
services:
  jackett:
    network_mode: host
    image: lscr.io/linuxserver/jackett
    container_name: jackett
    environment:
      - PUID=${uid}
      - PGID=${gid}
      - TZ=Asia/Shanghai
      - AUTO_UPDATE=true #optional
    volumes:
      - /usr/share/nginx/jackett/config:/config
      - /usr/share/nginx/jackett/downloads:/downloads
    restart: unless-stopped
  flaresolverr:
    network_mode: host
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    environment:
      - LOG_LEVEL=\${LOG_LEVEL:-info}
      - LOG_HTML=\${LOG_HTML:-false}
      - CAPTCHA_SOLVER=\${CAPTCHA_SOLVER:-none}
      - TZ=Asia/Shanghai
    restart: unless-stopped 
EOF

docker-compose up -d
sleep 10s;

cat /usr/share/nginx/jackett/config/Jackett/ServerConfig.json | grep /jackett/ &> /dev/null

if [[ $? != 0 ]]; then
docker-compose down
cat '/usr/share/nginx/jackett/config/Jackett/ServerConfig.json' | jq '.BasePathOverride |= "/jackett/"' >> /usr/share/nginx/jackett/config/Jackett/tmp.json
cp -f /usr/share/nginx/jackett/config/Jackett/tmp.json /usr/share/nginx/jackett/config/Jackett/ServerConfig.json
rm /usr/share/nginx/jackett/config/Jackett/tmp.json
cat '/usr/share/nginx/jackett/config/Jackett/ServerConfig.json' | jq '.AllowExternal |= false' >> /usr/share/nginx/jackett/config/Jackett/tmp.json
cp -f /usr/share/nginx/jackett/config/Jackett/tmp.json /usr/share/nginx/jackett/config/Jackett/ServerConfig.json
rm /usr/share/nginx/jackett/config/Jackett/tmp.json
cat '/usr/share/nginx/jackett/config/Jackett/ServerConfig.json' | jq '.FlareSolverrUrl |= "http://127.0.0.1:8191"' >> /usr/share/nginx/jackett/config/Jackett/tmp.json
cp -f /usr/share/nginx/jackett/config/Jackett/tmp.json /usr/share/nginx/jackett/config/Jackett/ServerConfig.json
rm /usr/share/nginx/jackett/config/Jackett/tmp.json
docker-compose up -d
fi
cd /root

cd /usr/share/nginx/
mkdir lidarr
cd /usr/share/nginx/lidarr
mkdir /usr/share/nginx/lidarr/config
mkdir /usr/share/nginx/lidarr/downloads

    cat > "docker-compose.yml" << EOF
version: "3.8"
services:
  lidarr:
    network_mode: host
    image: lscr.io/linuxserver/lidarr
    container_name: lidarr
    environment:
      - PUID=${uid}
      - PGID=${gid}
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/lidarr/config:/config
      - /usr/share/nginx/data:/data
    restart: unless-stopped
EOF

docker-compose up -d
sleep 10s;

cat /usr/share/nginx/lidarr/data/config.xml | grep AnalyticsEnabled &> /dev/null

if [[ $? != 0 ]]; then
docker-compose down
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/lidarr\/<\/UrlBase>/g" /usr/share/nginx/lidarr/config/config.xml
sed -i '$d' /usr/share/nginx/lidarr/config/config.xml
echo '  <AnalyticsEnabled>False</AnalyticsEnabled>' >> /usr/share/nginx/lidarr/config/config.xml
echo '  <UpdateAutomatically>True</UpdateAutomatically>' >> /usr/share/nginx/lidarr/config/config.xml
echo '</Config>' >> /usr/share/nginx/lidarr/config/config.xml
docker-compose up -d
fi
cd

cd /usr/share/nginx/
mkdir bazarr
cd /usr/share/nginx/bazarr
mkdir /usr/share/nginx/bazarr/config
mkdir /usr/share/nginx/bazarr/downloads

    cat > "docker-compose.yml" << EOF
version: "3.8"
services:
  bazarr:
    network_mode: host
    image: lscr.io/linuxserver/bazarr
    container_name: bazarr
    environment:
      - PUID=${uid}
      - PGID=${gid}
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/bazarr/config:/config
      - /usr/share/nginx/data/media/:/data/media
    restart: unless-stopped
EOF

docker-compose up -d
sleep 10s;
docker-compose down
sed -i "0,/base_url \=/s//base_url \= \/bazarr/g" /usr/share/nginx/bazarr/config/config/config.ini
sed -i '/^\[analytics\]$/,/^\[/ s/^enabled = True/enabled = False/' /usr/share/nginx/bazarr/config/config/config.ini
docker-compose up -d
cd

}