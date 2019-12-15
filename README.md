# trojan-gfw-script
This script will help you set up a trojan-gfw server in an extremely fast way.
https://www.johnrosen1.com/trojan/ main course
Auto install and setup Trojan-Gfw and nginx.

sudo bash -c "$(wget -O- https://raw.githubusercontent.com/johnrosen1/trojan-gfw-script/master/trojanv1.3.sh)"

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
10. Support auto vmess + tls + websocket + nginx config
11. Support manually force renew certificate
12. Support Remove Trojan-gfw or V2ray
