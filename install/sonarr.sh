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
mkdir /data/
### 二级子目录(qbt,emby,bazarr)
mkdir /data/torrents/
mkdir /data/usenet/
mkdir /data/media/
### 三级子目录(none)
mkdir /data/torrents/animes/
mkdir /data/torrents/movies/
mkdir /data/torrents/music/
mkdir /data/torrents/tv/
mkdir /data/usenet/animes/
mkdir /data/usenet/movies/
mkdir /data/usenet/music/
mkdir /data/usenet/tv/
mkdir /data/media/animes/
mkdir /data/media/movies/
mkdir /data/media/music/
mkdir /data/media/tv/

apt-get install xml-twig-tools -y
apt-get install sqlite3 -y

add_download_client_sonarr(){

    cat > "add.sh" << "EOF"
#!/usr/bin/env bash

  sqlite3 /usr/share/nginx/sonarr/data/sonarr.db  "insert into DownloadClients values ('1','1','localhost','QBittorrent','{
  \"host\": \"127.0.0.1\",
  \"port\": 8080,
  \"useSsl\": false,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"tvCategory\": \"tv\",
  \"recentTvPriority\": 0,
  \"olderTvPriority\": 0,
  \"initialState\": 0,
  \"sequentialOrder\": false,
  \"firstAndLast\": false
}','QBittorrentSettings','1','1','1');"
EOF

sed -i "s/adminadmin/${password1}/g" add.sh

bash add.sh

rm add.sh

}

add_download_client_radarr(){

    cat > "add.sh" << "EOF"
#!/usr/bin/env bash

  sqlite3 /usr/share/nginx/radarr/data/radarr.db  "insert into DownloadClients values ('1','1','localhost','QBittorrent','{
  \"host\": \"127.0.0.1\",
  \"port\": 8080,
  \"useSsl\": false,
  \"username\": \"admin\",
  \"password\": \"adminadmin\",
  \"movieCategory\": \"movies\",
  \"recentTvPriority\": 0,
  \"olderTvPriority\": 0,
  \"initialState\": 0
}','QBittorrentSettings','1','1','1');"
EOF

sed -i "s/adminadmin/${password1}/g" add.sh

bash add.sh

rm add.sh

}


install_sonarr(){

## tv show

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
      - /data:/data
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
sqlite3 /usr/share/nginx/sonarr/data/sonarr.db  "insert into RootFolders values ('1','/data/media/tv/');"
sqlite3 /usr/share/nginx/sonarr/data/sonarr.db  "UPDATE NamingConfig SET RenameEpisodes = 1;"
## PRAGMA table_info(NamingConfig);
add_download_client_sonarr
docker-compose up -d
fi
cd

sonarr_api=$(xml_grep 'ApiKey' /usr/share/nginx/sonarr/data/config.xml --text_only)


## movies

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
      - /data:/data
    restart: unless-stopped
EOF

docker-compose up -d
sleep 10s;

cat /usr/share/nginx/radarr/data/config.xml | grep AnalyticsEnabled &> /dev/null

if [[ $? != 0 ]]; then
docker-compose down
sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/radarr\/<\/UrlBase>/g" /usr/share/nginx/radarr/data/config.xml
sed -i '$d' /usr/share/nginx/radarr/data/config.xml
echo '  <AnalyticsEnabled>False</AnalyticsEnabled>' >> /usr/share/nginx/radarr/data/config.xml
echo '  <UpdateAutomatically>True</UpdateAutomatically>' >> /usr/share/nginx/radarr/data/config.xml
echo '</Config>' >> /usr/share/nginx/radarr/data/config.xml
sqlite3 /usr/share/nginx/radarr/data/radarr.db  "insert into RootFolders values ('1','/data/media/movies/');"
add_download_client_radarr
docker-compose up -d
fi
cd

radarr_api=$(xml_grep 'ApiKey' /usr/share/nginx/radarr/data/config.xml --text_only)


## api

cd /usr/share/nginx/
mkdir jackett
cd /usr/share/nginx/jackett
mkdir /usr/share/nginx/jackett/config

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

## music

# cd /usr/share/nginx/
# mkdir lidarr
# cd /usr/share/nginx/lidarr
# mkdir /usr/share/nginx/lidarr/config
# mkdir /usr/share/nginx/lidarr/downloads

#     cat > "docker-compose.yml" << EOF
# version: "3.8"
# services:
#   lidarr:
#     network_mode: host
#     image: lscr.io/linuxserver/lidarr
#     container_name: lidarr
#     environment:
#       - PUID=${uid}
#       - PGID=${gid}
#       - TZ=Asia/Shanghai
#     volumes:
#       - /usr/share/nginx/lidarr/config:/config
#       - /usr/share/nginx/data:/data
#     restart: unless-stopped
# EOF

# docker-compose up -d
# sleep 10s;

# cat /usr/share/nginx/lidarr/data/config.xml | grep AnalyticsEnabled &> /dev/null

# if [[ $? != 0 ]]; then
# docker-compose down
# sed -i "s/<UrlBase><\/UrlBase>/<UrlBase>\/lidarr\/<\/UrlBase>/g" /usr/share/nginx/lidarr/config/config.xml
# sed -i '$d' /usr/share/nginx/lidarr/config/config.xml
# echo '  <AnalyticsEnabled>False</AnalyticsEnabled>' >> /usr/share/nginx/lidarr/config/config.xml
# echo '  <UpdateAutomatically>True</UpdateAutomatically>' >> /usr/share/nginx/lidarr/config/config.xml
# echo '</Config>' >> /usr/share/nginx/lidarr/config/config.xml
# docker-compose up -d
# fi
# cd

## subtitles

cd /usr/share/nginx/
mkdir bazarr
cd /usr/share/nginx/bazarr
mkdir /usr/share/nginx/bazarr/config

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
      - /data/media/:/data/media
    restart: unless-stopped
EOF

docker-compose up -d
sleep 10s;
docker-compose down
sed -i "0,/base_url \=/s//base_url \= \/bazarr/g" /usr/share/nginx/bazarr/config/config/config.ini
sed -i '/^\[sonarr\]$/,/^\[/ s/^base_url = \//base_url = \/sonarr\//' /usr/share/nginx/bazarr/config/config/config.ini
sed -i "/^\[sonarr\]$/,/^\[/ s/^apikey =/apikey = ${sonarr_api}/" /usr/share/nginx/bazarr/config/config/config.ini
sed -i '/^\[radarr\]$/,/^\[/ s/^base_url = \//base_url = \/radarr\//' /usr/share/nginx/bazarr/config/config/config.ini
sed -i "/^\[radarr\]$/,/^\[/ s/^apikey =/apikey = ${radarr_api}/" /usr/share/nginx/bazarr/config/config/config.ini
sed -i '/^\[analytics\]$/,/^\[/ s/^enabled = True/enabled = False/' /usr/share/nginx/bazarr/config/config/config.ini
sed -i "s/use_sonarr = False/use_sonarr = True/g" /usr/share/nginx/bazarr/config/config/config.ini
sed -i "s/use_radarr = False/use_radarr = True/g" /usr/share/nginx/bazarr/config/config/config.ini
docker-compose up -d
cd

cd /usr/share/nginx/
mkdir chinesesubfinder
cd /usr/share/nginx/chinesesubfinder
mkdir /usr/share/nginx/chinesesubfinder/config

## 19035

    cat > "docker-compose.yml" << EOF
version: "3.8"
services:
  chinesesubfinder:
    network_mode: host
    image: allanpk716/chinesesubfinder:latest
    container_name: chinesesubfinder
    environment:
      - PUID=${uid}
      - PGID=${gid}
      - TZ=Asia/Shanghai    
    volumes:
      - /usr/share/nginx/chinesesubfinder/config:/config
    restart: unless-stopped
EOF

docker-compose up -d
#sleep 10s;
#docker-compose down
#docker-compose up -d
cd

# cd /usr/share/nginx/
# mkdir overseerr
# cd /usr/share/nginx/overseerr
# mkdir /usr/share/nginx/overseerr/config

# ## 5055

#     cat > "docker-compose.yml" << EOF
# version: "3.8"
# services:
#   overseerr:
#     network_mode: host
#     image: sctx/overseerr:latest
#     container_name: overseerr
#     environment:
#       - PUID=${uid}
#       - PGID=${gid}
#       - TZ=Asia/Shanghai    
#     volumes:
#       - /usr/share/nginx/overseerr/config:/config
#     restart: unless-stopped
# EOF

# docker-compose up -d
# #sleep 10s;
# #docker-compose down
# #docker-compose up -d
# cd

chown -R nginx:nginx /data/
}