#!/usr/bin/env bash

## 系统升级模组 System upgrade moudle

upgrade_system(){
  set +e

## Install lastest ubuntu lts
if [[ $(lsb_release -cs) == bionic ]] || [[ $(lsb_release -cs) == xenial ]] || [[ $(lsb_release -cs) == trusty ]]; then
  ubuntu18_install=1
fi
## Install lastest stable debian
if [[ $(lsb_release -cs) == stretch ]] || [[ $(lsb_release -cs) == buster ]]; then
  debian10_install=1
fi

 if [[ $dist == ubuntu ]]; then
  if [[ $ubuntu18_install == 1 ]]; then
    cat > '/etc/apt/sources.list' << EOF
deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse
deb http://archive.canonical.com/ubuntu focal partner
EOF
fi
  apt-get update --fix-missing
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt --fix-broken install -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get autoremove -qq -y'
  clear
 elif [[ $dist == debian ]]; then
  apt-get update --fix-missing
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get upgrade -y'
  if [[ ${debian10_install} == 1 ]]; then
    cat > '/etc/apt/sources.list' << EOF
deb http://deb.debian.org/debian/ stable main contrib non-free
deb http://deb.debian.org/debian/ stable-updates main contrib non-free
deb http://deb.debian.org/debian-security stable-security main
EOF
fi
  apt-get update --fix-missing
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade -q -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt --fix-broken install -y'
  sh -c 'echo "y\n\ny\ny\ny\ny\ny\ny\ny\n" | DEBIAN_FRONTEND=noninteractive apt-get autoremove -qq -y'
  clear
 else
  clear
  TERM=ansi whiptail --title "error can't upgrade system" --infobox "error can't upgrade system" 8 68
  exit 1;
 fi

if [[ -f /etc/apt/sources.list.d/nginx.list ]]; then
  cat > '/etc/apt/sources.list.d/nginx.list' << EOF
deb https://nginx.org/packages/mainline/${dist}/ $(lsb_release -cs) nginx
EOF
apt-get update
fi
}
