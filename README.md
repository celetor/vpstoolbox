# Trojan-GFW Script
## This script will help you set up a trojan-gfw server in an extremely fast way.
### Read The Fucking Manual: https://www.johnrosen1.com/trojan/ 

#### via wget
```
sudo bash -c "$(wget -O- https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojan.sh)"
```
#### or via curl
```
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojan.sh)"
```

### 汉化GUI版本
```
apt/yum install whiptail -y
sudo bash -c "$(curl -fsSL https://github.com/johnrosen1/trojan-gfw-script/raw/master/trojangui.sh)"
```
附：不保证中文兼容性
### Qbittorrent Version
```
apt/yum install whiptail -y
sudo bash -c "$(curl -fsSL https://github.com/johnrosen1/trojan-gfw-script/raw/master/trojangui-qbt.sh)"
```
#### Bash Features:

1. Auto install Trojan-GFW NGINX V2ray Qbittorrent and Dnsmasq
2. Auto config Trojan-GFW NGINX V2ray Qbittorrent and Dnsmasq
3. Auto issue and renew let's encrypt certificate
4. Auto OS Detect ***Support Centos Debian Ubuntu***
5. Auto domain resolve verification
6. Auto iptables firewall config and iptables-persistent
7. Auto generate client config
8. Auto random vmess uuid generate
9. Auto TCP Turbo enable ( **TCP-BBR** included)
10. Auto Nginx Performance Optimization (Centos exclued due to too old nginx version)
11. Auto Trojan-GFW trojan:// share link and QR code generate
12. Auto V2ray vmess:// share link generate
13. Auto https 301 redirect without affecting certificate renew
14. Auto enable **TLS1.3 ONLY**
15. Support auto vmess + tls + websocket + nginx config
16. Support manually check for update include both Trojan-gfw and v2ray
17. Support manually force renew certificate
18. Support Full Uninstall

#### Friendly Reminder:
1. Please Purchase a domain and finish a dns resolve before running this bash script!
2. Please manually change system dns to frequently updated dns like 1.1.1.1 instead of those who update slowly like aliyun lan dns !
```
echo "nameserver 1.1.1.1" > '/etc/resolv.conf'
```
3. Please choose option2 if you want to use v2ray !
4. Please do not any special symbols like "!" in password1 or 2 , or error will occur !
5. Please do not use enter / in websocket option ,enter someting else like /secret !
6. For security reasons, system upgrade is not forced ,press [ENTER] to skip or manually enter y to upgrade system.
7. Trojan-GFW QR code generate will be skipped on os who do not support python3-qrcode!
8. Due to personal demands , Dnsmasq installation is not forced ,press [ENTER] to skip or manually enter y to install dnsmasq.
9. If "sudo command not found" , please manually remove "sudo" from the beginning of the command and run as root !

#### Telegram Channel And Group

### https://t.me/johnrosen1

### https://t.me/trojanscript

Attachment: Trojan-GFW one-click script's function is basically complete. Stop updating from now on. If you need more functions, please use Github issue function.

## If you found it useful , please fork this project and give a star ,thanks!
