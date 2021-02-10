#!/usr/bin/env bash

## PHP模组 PHP moudle

install_php(){
  clear
TERM=ansi whiptail --title "安装中" --infobox "安装PHP中..." 7 68
colorEcho ${INFO} "Install PHP ing"
apt-get purge php* -y
mkdir /usr/log/
if [[ ${dist} == debian ]]; then
    wget --no-check-certificate -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php.list
    apt-get update
elif [[ ${dist} == ubuntu ]]; then
    add-apt-repository ppa:ondrej/php -y
    apt-get update
else
  echo "fail"
fi
  apt-get install php7.4-fpm -y
  apt-get install php7.4-apcu php7.4-gmp php7.4-common php7.4-mysql php7.4-ldap php7.4-xml php7.4-json php7.4-readline php7.4-xmlrpc php7.4-curl php7.4-gd php7.4-imagick php7.4-cli php7.4-dev php7.4-imap php7.4-mbstring php7.4-opcache php7.4-soap php7.4-zip php7.4-intl php7.4-bcmath -y
  apt-get purge apache2* -y
  sed -i "s/;date.timezone.*/date.timezone = Asia\/Hong_Kong/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.enable=1/opcache.enable=1/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.save_comments=1/opcache.save_comments=1/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.revalidate_freq=2/opcache.revalidate_freq=1/" /etc/php/7.4/fpm/php.ini
  sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 2000G/" /etc/php/7.4/fpm/php.ini
  sed -i "s/post_max_size = 8M/post_max_size = 0/" /etc/php/7.4/fpm/php.ini
  sed -i "s/memory_limit = 128M/memory_limit = 1024M/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.memory_consumption=128/opcache.memory_consumption=192/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.max_accelerated_files=10000/opcache.max_accelerated_files=10000/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=16/" /etc/php/7.4/fpm/php.ini
  if grep -q "opcache.fast_shutdown" /etc/php/7.4/fpm/php.ini
    then
    :
    else
    echo "" >> /etc/php/7.4/fpm/php.ini
    echo "opcache.fast_shutdown=1" >> /etc/php/7.4/fpm/php.ini
  fi
  if grep -q "env[PATH]" /etc/php/7.4/fpm/php-fpm.conf
    then
    :
    else
    echo "" >> /etc/php/7.4/fpm/php-fpm.conf
    echo "env[PATH] = /usr/local/bin:/usr/bin:/bin:/usr/local/php/bin" >> /etc/php/7.4/fpm/php-fpm.conf
  fi
  if grep -q "apc.enabled_cli=1" /etc/php/7.4/cli/conf.d/20-apcu.ini
    then
    :
    else
    echo "" >> /etc/php/7.4/cli/conf.d/20-apcu.ini
    echo "apc.enabled_cli=1" >> /etc/php/7.4/cli/conf.d/20-apcu.ini
  fi
  cd /etc/php/7.4/
  curl -sS https://getcomposer.org/installer -o composer-setup.php
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer --force
  cd
cat > '/etc/php/7.4/fpm/pool.d/www.conf' << EOF
[www]

;prefix = /path/to/pools/$pool

user = nginx
group = nginx

listen = /run/php/php7.4-fpm.sock
; Set listen(2) backlog.
; Default Value: 511 (-1 on FreeBSD and OpenBSD)
;listen.backlog = 511

; Set permissions for unix socket, if one is used. In Linux, read/write
; permissions must be set in order to allow connections from a web server. Many
; BSD-derived systems allow connections regardless of permissions. The owner
; and group can be specified either by name or by their numeric IDs.
; Default Values: user and group are set as the running user
;                 mode is set to 0660
listen.owner = nginx
listen.group = nginx
;listen.mode = 0660
;listen.acl_users =
;listen.acl_groups =

; List of addresses (IPv4/IPv6) of FastCGI clients which are allowed to connect.
; Equivalent to the FCGI_WEB_SERVER_ADDRS environment variable in the original
; PHP FCGI (5.2.2+). Makes sense only with a tcp listening socket. Each address
; must be separated by a comma. If this value is left blank, connections will be
; accepted from any ip address.
; Default Value: any
; listen.allowed_clients = 127.0.0.1

pm = dynamic

pm.max_children = $(($(nproc --all)*5))

pm.start_servers = $(($(nproc --all)*4))

pm.min_spare_servers = $(($(nproc --all)*2))

pm.max_spare_servers = $(($(nproc --all)*4))

; The number of requests each child process should execute before respawning.
; This can be useful to work around memory leaks in 3rd party libraries. For
; endless request processing specify '0'. Equivalent to PHP_FCGI_MAX_REQUESTS.
; Default Value: 0
;pm.max_requests = 500

pm.status_path = /status

ping.path = /ping

catch_workers_output = no

; Default Value: nothing is defined by default except the values in php.ini and
;                specified at startup with the -d argument
;php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f www@my.domain.com
php_flag[display_errors] = on
php_admin_value[error_log] = /var/log/fpm-php.www.log
php_admin_flag[log_errors] = on
;php_admin_value[memory_limit] = 32M
EOF
touch /var/log/fpm-php.www.log
systemctl restart php7.4-fpm
}