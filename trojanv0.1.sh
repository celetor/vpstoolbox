#!/bin/bash
if [[ $(id -u) != 0 ]]; then
    echo Please run this script as root.
    exit 1
fi
echo "Hello, "$USER".  This script will help you set up a trojan-gfw server."
cat /etc/os-release
read -p "Enter your os codename and press [ENTER]: "
codename
echo -n "Your os codename is $codename"
echo
read -p "Enter your domain and press [ENTER]: "
domain
echo -n "It\'s nice to meet you $domain"
echo
read -p "Enter your desired password1 and press [ENTER]: "
password1
echo -n "Your password1 is $password1"
echo
read -p "Enter your desired password2 and press [ENTER]: "
password2
echo -n "Your password2 is $password2"

echo installing trojan-gfw nginx and acme
apt-get update
apt-get upgrade -y
apt-get install curl socat xz-utils wget apt-transport-https -y

bash -c "$(wget -O- https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"

wget https://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
echo "deb https://nginx.org/packages/mainline/debian/ $codename nginx" >> /etc/apt/sources.list
echo "deb-src https://nginx.org/packages/mainline/debian/ $codename nginx" >> /etc/apt/sources.list
apt-get update
apt-get install nginx -y
curl https://get.acme.sh | sh
mkdir /etc/trojan/
echo issueing let\'s encrypt certificate
sudo ~/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
echo issue complete,installing certificate
sudo ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/trojan/trojan.crt --keypath /etc/trojan/trojan.key --ecc
chmod +r /etc/trojan/trojan.key
echo certificate install complete
sed  -i 's/path/etc/g' /usr/local/etc/trojan/config.json
sed  -i 's/to/trojan/g' /usr/local/etc/trojan/config.json
sed  -i 's/certificate.crt/trojan.crt/g' /usr/local/etc/trojan/config.json
sed  -i 's/private.key/trojan.key/g' /usr/local/etc/trojan/config.json
sed  -i "s/password1/$password1/g" /usr/local/etc/trojan/config.json
sed  -i "s/password2/$password2/g" /usr/local/etc/trojan/config.json
echo trojan-gfw config complete,congratulations!
echo starting trojan-gfw and nginx
systemctl start trojan
systemctl start nginx
echo setup boot autostart
systemctl enable nginx
systemctl enable trojan
echo setup tcp-bbr boost technology
echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.d/99-sysctl.conf
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.d/99-sysctl.conf
sysctl -p
echo install Success,Enjoy it!
