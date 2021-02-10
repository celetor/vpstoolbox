#!/usr/bin/env bash

## Node.js模组 Node.js moudle

install_nodejs(){
if [[ ${dist} == debian ]]; then
  curl -sL https://deb.nodesource.com/setup_15.x | bash -
 elif [[ ${dist} == ubuntu ]]; then
  curl -sL https://deb.nodesource.com/setup_15.x | sudo -E bash -
 else
  echo "fail"
fi
apt-get update
apt-get install -q -y nodejs
}