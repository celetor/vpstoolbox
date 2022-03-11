#!/usr/bin/env bash

## Sonarr + Jackett 模组

set +e

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

install_sonarr(){
cd /usr/share/nginx/
mkdir sonarr
cd /usr/share/nginx/sonarr

    cat > "docker-compose.yml" << "EOF"
version: "3.8"
services:
  sonarr:
    network_mode: host
    image: lscr.io/linuxserver/sonarr
    container_name: sonarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/sonarr/data:/config
      - /usr/share/nginx/sonarr/tvseries:/tv #optional
      - /usr/share/nginx/sonarr/downloads:/downloads #optional
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
mkdir jackett
cd /usr/share/nginx/jackett
mkdir /usr/share/nginx/jackett/config
mkdir /usr/share/nginx/jackett/downloads

    cat > "docker-compose.yml" << "EOF"
version: "3.8"
services:
  jackett:
    network_mode: host
    image: lscr.io/linuxserver/jackett
    container_name: jackett
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
      - AUTO_UPDATE=true #optional
    volumes:
      - /usr/share/nginx/jackett/config:/config
      - /usr/share/nginx/jackett/downloads:/downloads
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
docker-compose up -d
fi
cd /root

cd /usr/share/nginx/
mkdir lidarr
cd /usr/share/nginx/lidarr
mkdir /usr/share/nginx/lidarr/config
mkdir /usr/share/nginx/lidarr/downloads

    cat > "docker-compose.yml" << "EOF"
version: "3.8"
services:
  lidarr:
    network_mode: host
    image: lscr.io/linuxserver/lidarr
    container_name: lidarr
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
    volumes:
      - /usr/share/nginx/lidarr/config:/config
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


}