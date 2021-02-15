#!/usr/bin/env bash

## Trojan-panel模组 Trojan-panel moudle

install_tjp(){
set +e
TERM=ansi whiptail --title "安装中" --infobox "安装Trojan-panel中..." 7 68
colorEcho ${INFO} "Install Trojan-panel ing"
cd /usr/share/nginx/
git clone https://github.com/trojan-gfw/trojan-panel.git
chown -R nginx:nginx /usr/share/nginx/trojan-panel
cd trojan-panel
composer install
npm install
npm audit fix
cp .env.example .env
php artisan key:generate
sed -i "s/example.com/${domain}/;" /usr/share/nginx/trojan-panel/.env
sed -i "s/DB_PASSWORD=/DB_PASSWORD=${password1}/;" /usr/share/nginx/trojan-panel/.env
#sed -i "s/MAIL_PORT=2525/MAIL_PORT=25/;" /usr/share/nginx/trojan-panel/.env
clear
php artisan migrate --force
chown -R nginx:nginx /usr/share/nginx/
cd
}