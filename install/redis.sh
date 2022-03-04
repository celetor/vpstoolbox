#!/usr/bin/env bash

## Redis-server模组 Redis-server moudle

install_redis(){
  set +e
  cd
  TERM=ansi whiptail --title "安装中" --infobox "安装redis中..." 7 68
  redisver=$(curl -s "https://api.github.com/repos/redis/redis/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
  if [[ -f /usr/local/bin/redis-server ]]; then
    TERM=ansi whiptail --title "安装中" --infobox "更新redis中..." 7 68
    curl -LO https://github.com/redis/redis/archive/${redisver}.zip
    unzip -o ${redisver}.zip
    rm ${redisver}.zip
    cd redis-${redisver}
    apt-get install libsystemd-dev pkg-config -y
    make USE_SYSTEMD=yes -j $(nproc --all)
    make install
  else
  apt-get install libsystemd-dev pkg-config unzip -y
  curl -LO https://github.com/redis/redis/archive/${redisver}.zip
  unzip -o ${redisver}.zip
  rm ${redisver}.zip
  cd redis-${redisver}
  make USE_SYSTEMD=yes -j $(nproc --all)
  make install
  chmod +x /usr/local/bin/redis-server
  chmod +x /usr/local/bin/redis-cli
  useradd -m -s /sbin/nologin redis
  groupadd redis
  usermod -a -G redis redis
  usermod -a -G redis nginx
  usermod -a -G redis netdata
  mkdir /var/lib/redis
  mkdir /var/log/redis/
  mkdir /etc/redis
  chown -R redis:redis /var/lib/redis
  chown -R redis:redis /etc/redis
  chown -R redis:redis /var/log/redis
  cat > '/etc/systemd/system/redis.service' << EOF
[Unit]
Description=Advanced key-value store
After=network.target
Documentation=http://redis.io/documentation, man:redis-server(1)

[Service]
Type=notify
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
TimeoutStopSec=0
Restart=always
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=2755

UMask=007
PrivateTmp=yes
LimitNOFILE=65535
PrivateDevices=yes
ProtectHome=yes
ReadOnlyDirectories=/
ReadWriteDirectories=-/var/lib/redis
ReadWriteDirectories=-/var/log/redis
ReadWriteDirectories=-/var/run/redis

NoNewPrivileges=true
CapabilityBoundingSet=CAP_SETGID CAP_SETUID CAP_SYS_RESOURCE
MemoryDenyWriteExecute=true
ProtectKernelModules=true
ProtectKernelTunables=true
ProtectControlGroups=true
RestrictRealtime=true
RestrictNamespaces=true
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX

ProtectSystem=full
ReadWriteDirectories=-/etc/redis

[Install]
WantedBy=multi-user.target
Alias=redis.service
EOF
systemctl daemon-reload
fi
  cat > '/etc/redis/redis.conf' << EOF
bind 127.0.0.1 ::1
protected-mode no
port 6379
tcp-backlog 511
unixsocket /var/run/redis/redis.sock
unixsocketperm 770
timeout 0
tcp-keepalive 300
daemonize no
supervised systemd
loglevel notice
logfile /var/log/redis/redis-server.log
databases 16
always-show-logo yes
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir /var/lib/redis
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
replica-priority 100
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
EOF
systemctl restart redis
systemctl enable redis
cd
rm -rf redis*
cd
}
