#!/usr/bin/env bash

## Chia Fullnode模组 Chia Fullnode moudle

#---Author Info---
ver="1.0.0"
Author="johnrosen1"
url="https://johnrosen1.com/"
github_url="https://github.com/johnrosen1/vpstoolbox"
#-----------------

install_chia() {
    apt-get install git -y
    git clone https://github.com/Chia-Network/chia-blockchain.git -b latest
    cd chia-blockchain
    sh install.sh
    . ./activate
    chia init
    chia keys generate
    chia start node
    echo -e "Chia Full node installation success"
}
install_chia