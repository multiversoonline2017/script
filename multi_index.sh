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
  
  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc

fi

## COMPILE AND INSTALL
wget https://github.com/IndexChain/Index/releases/download/v0.13.10.5/index-0.13.10.5-x86_64-linux-gnu.tar.gz
sudo apt-get install unzip
sudo apt-get install tar
sudo tar xzvf index-0.13.10.5-x86_64-linux-gnu.tar.gz 
sudo chmod 755 Ubuntu/IndexChain*
sudo mv Ubuntu/IndexChain* /usr/bin
sudo mv IndexChain* /usr/bin
rm -rf index-0.13.10.5-x86_64-linux-gnu.tar.gz

CONF_DIR=~/.IndexChain/
mkdir $CONF_DIR
CONF_FILE=index.conf
PORT=7082

IP=$(curl -s4 icanhazip.com)

echo ""
echo "Enter masternode private key for node $ALIAS"
read PRIVKEY
 
echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> $CONF_DIR/$CONF_FILE
echo "rpcallowip=127.0.0.1" >> $CONF_DIR/$CONF_FILE
echo "listen=1" >> $CONF_DIR/$CONF_FILE
echo "server=1" >> $CONF_DIR/$CONF_FILE
echo "daemon=1" >> $CONF_DIR/$CONF_FILE
echo "logtimestamps=1" >> $CONF_DIR/$CONF_FILE
echo "maxconnections=16" >> $CONF_DIR/$CONF_FILE
echo "indexnode=1" >> $CONF_DIR/$CONF_FILE
echo "" >> $CONF_DIR/$CONF_FILE
echo "" >> $CONF_DIR/$CONF_FILE
echo "port=$PORT" >> $CONF_DIR/$CONF_FILE
echo "indexnodeaddr=$IP:$PORT" >> $CONF_DIR/$CONF_FILE
echo "indexnodeprivkey=$PRIVKEY" >> $CONF_DIR/$CONF_FILE

echo "addnode=45.76.196.198:7082" >> $CONF_DIR/$CONF_FILE
echo "addnode=5.3.65.34:7082" >> $CONF_DIR/$CONF_FILE
echo "addnode=167.86.108.169:7082" >> $CONF_DIR/$CONF_FILE
echo "addnode=173.212.227.202:7082" >> $CONF_DIR/$CONF_FILE
echo "addnode=45.76.56.185:7082" >> $CONF_DIR/$CONF_FILE

sudo ufw allow $PORT/tcp



indexd -daemon
