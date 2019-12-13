#!/bin/bash
if [[ $(id -u) != 0 ]]; then
    echo Please run this script as root.
    exit 1
fi
#SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
#AIRTIMEROOT=${SCRIPT_DIR}
#YUM_CMD=$(which yum)
#APT_GET_CMD=$(which apt-get)
#OTHER_CMD=$(which <other installer>)

echo "Hello, "$USER".  This script will help you set up a trojan-gfw server."
userinput(){
echo -n "Enter your domain and press [ENTER]: "
read domain
echo -n "It\'s nice to meet you $domain"
echo
echo -n "Enter your desired password1 and press [ENTER]: "
read password1
echo -n "Your password1 is $password1"
echo
echo -n "Enter your desired password2 and press [ENTER]: "
read password2
echo -n "Your password2 is $password2"
}

userinput

getoscode(){
# Validate the distribution and release is a supported one; set boolean flags.
echo "Detecting distribution and release ..."
is_debian_dist=false
is_debian_buster=false
is_debian_stretch=false
is_debian_jessie=false
is_debian_wheezy=false
is_ubuntu_dist=false
is_ubuntu_bionic=false
is_ubuntu_eoan=false
is_ubuntu_xenial=false
is_ubuntu_trusty=false
is_centos_dist=false
is_centos_7=false
if [ -e /etc/os-release ]; then
  # Access $ID, $VERSION_CODENAME, $VERSION_ID and $PRETTY_NAME
  source /etc/os-release
  dist=$ID
  code="${VERSION_CODENAME-$VERSION_ID}"
  case "${dist}-${code}" in
    ubuntu-eoan) #ubuntu 19.10
      code="eoan"
      is_ubuntu_dist=true
      
      is_ubuntu_eoan=true
      ;;
    ubuntu-bionic) #ubuntu 18.04
      code="bionic"
      is_ubuntu_dist=true
      is_ubuntu_bionic=true
      ;;
    ubuntu-xenial) #ubuntu 16.04
      code="trusty"
      is_ubuntu_dist=true
      is_ubuntu_xenial=true
      ;;
    ubuntu-14.04) #ubuntu 14.04
      code="trusty"
      is_ubuntu_dist=true
      is_ubuntu_trusty=true
      ;;
    debian-buster) #debian10
      code="buster"
      is_debian_dist=true
      is_debian_buster=true
      ;;
    debian-9) #debian9
      code="stretch"
      is_debian_dist=true
      is_debian_stretch=true
      ;;
    debian-8) #debian8
      code="jessie"
      is_debian_dist=true
      is_debian_jessie=true
      ;;
    debian-7) #debian7
      code="wheezy"
      is_debian_dist=true
      is_debian_wheezy=true
      ;;
    centos-7)
      is_centos_dist=true
      is_centos_7=true
      ;;
    *)
      echo "ERROR: Distribution \"$PRETTY_NAME\" is not supported!" >&2
      exit 1
      ;;
  esac
else
  echo "ERROR: This is an unsupported distribution and/or version!" >&2
  exit 1
fi

echo "Detected distribution: $PRETTY_NAME"
echo "Distribution id (dist): $dist"
echo "Distribution version (code): $code"

echo
$is_ubuntu_dist && echo "Dist: Ubuntu"
$is_debian_dist && echo "Dist: Debian"
$is_centos_dist && echo "Dist: CentOS"

echo "Distribution and release codename:"
$is_ubuntu_eoan && echo "Ubuntu Eoan"
$is_ubuntu_bionic && echo "Ubuntu Bionic"
$is_ubuntu_xenial && echo "Ubuntu Xenial"
$is_ubuntu_trusty && echo "Ubuntu Trusty"
$is_debian_buster && echo "Debian Buster"
$is_debian_stretch && echo "Debian Stretch"
$is_debian_jessie && echo "Debian Jessie"
$is_debian_wheezy && echo "Debian Wheezy"
$is_centos_7 && echo "CentOS 7"
}

getoscode

echo -n "Your os codename is $codename"

updatesystem(){
	if [[ $dist = centos ]]; then
    yum update
 elif [[ $dist = ubuntu ]]; then
    apt-get update
 elif [[ $dist = debian ]]; then
    apt-get update
 else
    echo "error can't update system"
    exit 1;
 fi
}

updatesystem

upgradesystem(){
	if [[ $dist = centos ]]; then
    yum upgrade -y
 elif [[ $dist = ubuntu ]]; then
    apt-get upgrade -y
 elif [[ $dist = debian ]]; then
    apt-get upgrade -y
 else
    echo "error can't upgrade system"
    exit 1;
 fi
}

installrely(){
	echo installing trojan-gfw nginx and acme
	if [[ $dist = centos ]]; then
    yum install curl socat xz-utils wget apt-transport-https -y
 elif [[ $dist = ubuntu ]]; then
    apt-get install curl socat xz-utils wget apt-transport-https -y
 elif [[ $dist = debian ]]; then
    apt-get install curl socat xz-utils wget apt-transport-https -y
 else
    echo "error can't update system"
    exit 1;
 fi
}

installrely

installtrojan-gfw(){
	bash -c "$(wget -O- https://raw.githubusercontent.com/trojan-gfw/trojan-quickstart/master/trojan-quickstart.sh)"
}

installtrojan-gfw

nginxyum(){
	yum install nginx -y
}

nginxapt(){
	wget https://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
	echo "deb https://nginx.org/packages/mainline/debian/ $code nginx" >> /etc/apt/sources.list
	echo "deb-src https://nginx.org/packages/mainline/debian/ $code nginx" >> /etc/apt/sources.list
	apt-get update
	apt-get install nginx -y
}

nginxubuntu(){
	wget https://nginx.org/keys/nginx_signing.key
	apt-key add nginx_signing.key
	echo "deb https://nginx.org/packages/mainline/ubuntu/ $code nginx" >> /etc/apt/sources.list
	echo "deb-src https://nginx.org/packages/mainline/ubuntu/ $code nginx" >> /etc/apt/sources.list
	apt-get update
	apt-get install nginx -y
}

installnignx(){
	if [[ $dist = centos ]]; then
    nginxyum
 elif [[ $dist = ubuntu ]]; then
    nginxubuntu
 elif [[ $dist = debian ]]; then
    nginxapt
 else
    echo "error can't install nginx"
    exit 1;
 fi
}

installnignx

installacme(){
	curl https://get.acme.sh | sh
	mkdir /etc/trojan/
}

installacme

issuecert(){
	sudo ~/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
}
echo "issueing let\'s encrypt certificate"

issuecert

installcert(){
	sudo ~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/trojan/trojan.crt --keypath /etc/trojan/trojan.key --ecc
}

echo "issue complete,installing certificate"

installcert

echo "certificate install complete!"

installkey(){
	chmod +r /etc/trojan/trojan.key
}
echo "giving private key read authority"

installkey

changepasswd(){
	sed  -i 's/path/etc/g' /usr/local/etc/trojan/config.json
	sed  -i 's/to/trojan/g' /usr/local/etc/trojan/config.json
	sed  -i 's/certificate.crt/trojan.crt/g' /usr/local/etc/trojan/config.json
	sed  -i 's/private.key/trojan.key/g' /usr/local/etc/trojan/config.json
	sed  -i "s/password1/$password1/g" /usr/local/etc/trojan/config.json
	sed  -i "s/password2/$password2/g" /usr/local/etc/trojan/config.json
}

changepasswd
echo "trojan-gfw config complete!"
echo "starting trojan-gfw and nginx | setting up boot autostart"
autostart(){
	systemctl start trojan
	systemctl start nginx
	systemctl enable nginx
	systemctl enable trojan
}
autostart
tcp-bbr(){
	echo "net.ipv4.tcp_slow_start_after_idle = 0" >> /etc/sysctl.d/99-sysctl.conf
	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.d/99-sysctl.conf
	sysctl -p
}
echo "Setting up tcp-bbr boost technology"
tcp-bbr

echo "Install Success,Enjoy it!"