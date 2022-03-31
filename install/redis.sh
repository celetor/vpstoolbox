#!/usr/bin/env bash

## Redis-server模组 Redis-server moudle

set +e

install_redis(){
  cd
  TERM=ansi whiptail --title "安装中" --infobox "安装redis中..." 7 68
  curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

  echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

  apt-get update
  apt-get install redis -y
  systemctl enable redis-server
cd
}
