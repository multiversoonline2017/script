#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 18.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your IndexChain masternodes.      *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [[ $DOSETUP =~ "y" ]] ; then
  sudo apt-get update
  sudo apt-get install -y unzip
  sudo apt-get install -y zip
  sudo apt-get install -y tar
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get install -y nano htop git
  sudo apt-get install -y autoconf
  sudo apt-get install -y automake unzip
  sudo apt-get update
  sudo apt update && sudo apt upgrade -y
  sudo apt-get --assume-yes install git unzip build-essential libssl-dev libdb++-dev libboost-all-dev libcrypto++-dev libqrencode-dev libminiupnpc-dev libgmp-dev libgmp3-dev autoconf autogen automake libtool


  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=5120
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  sudo sysctl vm.swappiness=50
  echo “vm.swappiness = 50” >> /etc/sysctl.conf 
  cd
  

  ## INSTALL
  wget https://github.com/IndexChain/Index/releases/download/v0.13.10.5/index-0.13.10.5-x86_64-linux-gnu.tar.gz
  sudo apt-get install unzip
  sudo apt-get install tar
  sudo tar xzvf index-0.13.10.5-x86_64-linux-gnu.tar.gz 
  rm -rf index-0.13.10.5-x86_64-linux-gnu.tar.gz

  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw allow 7082/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

fi

## Setup conf
mkdir -p ~/.IndexChain
nano ~/.IndexChain/index.conf

rpcuser=xxx
rpcpassword=xxxxxx
rpcallowip=127.0.0.1
rpcport=8888
port=7082
-listen=0
server=1
daemon=1
logtimestamps=1
maxconnections=64
txindex=1
indexnode=1
externalip=xxxxxxxxxxx:7082
indexnodeprivkey=xxxxxxxxxxxxxxxxx
addnode=45.76.196.198:7082
addnode=5.3.65.34:7082
addnode=167.86.108.169:7082
addnode=173.212.227.202:7082
addnode=45.76.56.185:7082

 
done
