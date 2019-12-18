# Trojan-GFW Script
## This script will help you set up a trojan-gfw server in an extremely fast way.
### For more Info: https://www.johnrosen1.com/trojan/ 

#### via wget
```
sudo bash -c "$(wget -O- https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojan.sh)"
```
#### or via curl
```
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojan.sh)"
```
#### Bash Features:

1. Auto install Trojan-GFW NGINX V2ray and Dnsmasq
2. Auto config Trojan-GFW NGINX V2ray and Dnsmasq
3. Auto issue and renew let's encrypt certificate
4. Auto OS Detect Support Centos Debian and Ubuntu
5. Auto domain resolve verification
6. Auto iptables firewall config and iptables-persistent
7. Auto generate client config
8. Auto random vmess uuid generate
9. Auto TCP Turbo enable ( includes more than tcp-bbr )
10. Auto Nginx Performance Optimization (Centos exclued due to too old nginx version)
11. Auto Trojan-GFW trojan:// share link and QR code generate
12. Auto V2ray vmess:// share link generate
13. Auto https 301 redirect without affecting certificate renew
14. Support auto vmess + tls + websocket + nginx config
15. Support manually check for update include both Trojan-gfw and v2ray
16. Support manually force renew certificate
17. Support Full Uninstall

#### Friendly Reminder:
1. Please Purchase a domain and finish a dns resolve before running this bash script!
2. Please manually change system dns to frequently updated dns like 1.1.1.1 instead of those who update slowly like aliyun lan dns !
3. Please choose option2 if you want to use v2ray !
4. Please do not any special symbols like "!" in password1 or 2 , or error will occur !
5. Please do not use enter / in websocket option ,enter someting else like /secret !
6. For security reasons, system upgrade is not forced ,press [ENTER] to skip or manually enter y to upgrade system.
7. Due to the lack of support for python3-qrcode in Ubuntu 16.04,Trojan-GFW QR code generating will be skipped !
8. Due to personal demands , Dnsmasq installation is not forced ,press [ENTER] to skip or manually enter y to install dnsmasq.
9. If "sudo command not found" , please manually remove "sudo" from the beginning of the command and run as root !

#### Telegram Channel And Group

### https://t.me/johnrosen1

### https://t.me/trojanscript

附： Trojan一键脚本功能已基本齐全，从此停止更新，如需更多功能请移步Github issue，我会考虑的。
