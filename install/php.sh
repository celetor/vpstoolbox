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

;prefix = /path/to/pools/\$pool

user = nginx
group = nginx

listen = /run/php/php7.4-fpm.sock

listen.owner = nginx
listen.group = nginx
;listen.mode = 0660

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

php_flag[display_errors] = off
php_admin_value[error_log] = /var/log/fpm-php.www.log
php_admin_flag[log_errors] = off
EOF
#touch /var/log/fpm-php.www.log
systemctl restart php7.4-fpm
}
