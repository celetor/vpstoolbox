# trojan-gfw-script
This script will help you set up a trojan-gfw server in an extremely fast way.
For more Info: https://www.johnrosen1.com/trojan/ 

via wget

sudo bash -c "$(wget -O- https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojan.sh)"

or via curl

sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojan.sh)"

Bash Features:

1. Auto install Trojan-GFW NGINX and V2ray
2. Auto config Trojan-GFW NGINX and V2ray
3. Auto issue and renew let's encrypt certificate
4. Auto OS Detect Support Centos Debian and Ubuntu
5. Auto domain resolve verification
6. Auto iptables firewall config and iptables-persistent
7. Auto generate client config
8. Auto random vmess uuid generate
9. Auto enable tcp-bbr and disable tcp slow start
10. Auto Trojan-GFW share link and QR code generate
11. Auto V2ray vmess:// share link generate
12. Support auto vmess + tls + websocket + nginx config
13. Support manually check for update include both Trojan-gfw and v2ray
14. Support manually force renew certificate
15. Support Full Uninstall

Friendly Reminder:
1. Please Purchase a domain and finish a dns resolve before running this bash script!
2. Please manually change system dns to frequently updated dns like 1.1.1.1 instead of those who update slowly like aliyun lan dns !
3. Please choose option2 if you want to use v2ray !
4. Please do not any special symbols like ! in password1 or 2 , or error will occur !
5. Please do not use enter / in websocket option ,enter someting else like /secret !
6. For security reasons, system upgrade is not forced ,press [ENTER] to skip or manually enter y to upgrade system.
7. Due to the lack of support for python3-qrcode in Ubuntu 16.04,QR code generating will be skipped !
