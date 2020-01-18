#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your DAPSCOIN masternodes.      *"
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
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get install -y nano htop git
  sudo apt-get install -y autoconf
  sudo apt-get install -y automake unzip
  sudo apt-get update
  sudo apt update && sudo apt upgrade -y
  

  ## INSTALL
  wget https://github.com/DAPSCoin/DAPSCoin/releases/download/1.0.5/dapscoin-v1.0.5.7-linux.zip
  sudo apt-get install unzip
  sudo unzip dapscoin-v1.0.5.7-linux.zip -d /usr/local/bin
  chmod +x /usr/local/bin/dapscoind
  chmod +x /usr/local/bin/dapscoin-cli
  chmod +x /usr/local/bin/dapscoin-qt
  sudo chmod 755 daspcoin*
  sudo mv dapscoin* /usr/bin
  cd
  rm -rf dapscoin-v1.0.5.7-linux.zip

  echo "Setting up and enabling fail2ban..."
  sudo apt-get install fail2ban -y
  sudo ufw allow ssh
  sudo ufw allow 53572
  sudo ufw allow 53573
  sudo ufw enable

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
fi

## Setup conf
mkdir -p ~/bin
IP=$(curl -s4 theiexplorers.com)
NAME="dapscoin"
CONF_FILE=dapscoin.conf

MNCOUNT=""
re='^[0-7]+$'
while ! [[ $MNCOUNT =~ $re ]] ; do
   echo ""
   echo "How many nodes do you want to create on this server?, followed by [ENTER]:"
   read MNCOUNT
done

for i in `seq 1 1 $MNCOUNT`; do
  echo ""
  echo "Enter alias for new node"
  read ALIAS  

  echo ""
  echo "Enter IPV6 for node $ALIAS (enter your ipv6 address here)"
  read IPADDRESS

  echo ""
  echo "Enter RPC Port (Any valid free port: i.E. 9001)"
  read RPCPORT

  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  ALIAS=${ALIAS,,}
  CONF_DIR=~/.${NAME}_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/${NAME}d_$ALIAS.sh
  echo "${NAME}d -daemon -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' >> ~/bin/${NAME}d_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/${NAME}-cli_$ALIAS.sh
  echo "${NAME}-cli -conf=$CONF_DIR/${NAME}.conf -datadir=$CONF_DIR "'$*' >> ~/bin/${NAME}-cli_$ALIAS.sh
  chmod 755 ~/bin/${NAME}*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> ${NAME}.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> ${NAME}.conf_TEMP
  echo "rpcport=$RPCPORT" >> ${NAME}.conf_TEMP
  echo "listen=0" >> ${NAME}.conf_TEMP
  echo "server=1" >> ${NAME}.conf_TEMP
  echo "daemon=1" >> ${NAME}.conf_TEMP
  echo "logtimestamps=1" >> ${NAME}.conf_TEMP
  echo "maxconnections=256" >> ${NAME}.conf_TEMP
  echo "IPADDRESS=[$IPADDRESS]" >> ${NAME}.conf_TEMP
  echo "externalip=[$IPADDRESS]" >> ${NAME}.conf_TEMP
  echo "masternodeaddr=[$IPADDRESS]:53572" >> ${NAME}.conf_TEMP
  echo "bind=[$IPADDRESS]:53572" >> ${NAME}.conf_TEMP
  echo "masternode=1" >> ${NAME}.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> ${NAME}.conf_TEMP
  echo "addnode=212.241.70.213:53572" >> ${NAME}.conf_TEMP
  echo "addnode=51.158.179.2:53572" >> ${NAME}.conf_TEMP
  echo "addnode=62.109.23.159:53572" >> ${NAME}.conf_TEMP
  echo "addnode=213.159.214.54:53572" >> ${NAME}.conf_TEMP
  echo "addnode=198.50.158.52:53572" >> ${NAME}.conf_TEMP
  echo "addnode=51.15.60.223:53572" >> ${NAME}.conf_TEMP
  echo "addnode=34.70.115.113:53572" >> ${NAME}.conf_TEMP
  echo "addnode=155.138.147.104:53572" >> ${NAME}.conf_TEMP
  echo "addnode=34.83.218.180:53572" >> ${NAME}.conf_TEMP
  echo "addnode=92.242.40.112:53572" >> ${NAME}.conf_TEMP
  echo "addnode=95.216.217.62:53572" >> ${NAME}.conf_TEMP
  echo "addnode=51.158.162.17:53572" >> ${NAME}.conf_TEMP
  echo "addnode=51.15.126.86:53572" >> ${NAME}.conf_TEMP
  echo "addnode=185.224.135.143:53572" >> ${NAME}.conf_TEMP
  
  sudo ufw allow [$IPADDRESS]:53572/tcp

  mv ${NAME}.conf_TEMP $CONF_DIR/${NAME}.conf
  
  echo "Downloading bootstrap..."
  wget -o https://github.com/DAPSCoin/BootStrap/releases/download/latest/peers.dat
  cp peers.dat $CONF_DIR/peers.dat
  rm -rf bootstrap.zip
  wget --no-check-certificate --content-disposition https://github.com/DAPSCoin/BootStrap/releases/download/latest/bootstrap.zip
  echo "Removing old blocks, chainstate, and database folders...."
  rm -rf $CONF_DIR/blocks $CONF_DIR/chainstate $CONF_DIR/database
  echo "Installing new blocks folders..."
  sudo unzip -o bootstrap.zip -d $CONF_DIR
  rm -rf bootstrap.zip
  echo "Bootstrap installed!"

  sh ~/bin/${NAME}d_$ALIAS.sh
done
