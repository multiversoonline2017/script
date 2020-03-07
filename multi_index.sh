#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 16.04 is the recommended opearting system for this install.       *"
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
  

  ## INSTALL
  wget https://github.com/IndexChain/Index/releases/download/v0.13.9.2/index-0.13.9-x86_64-linux-gnu.tar.gz
  sudo apt-get install unzip
  sudo apt-get install tar
  sudo tar xzvf index-0.13.9-x86_64-linux-gnu.tar.gz -d /usr/local/bin
  chmod +x /usr/local/bin/indexd
  chmod +x /usr/local/bin/index-cli
  chmod +x /usr/local/bin/index-qt
  sudo chmod 755 IndexChain*
  sudo mv IndexChain* /usr/bin
  cd
  rm -rf index-0.13.9-x86_64-linux-gnu.tar.gz

  echo "Setting up and enabling fail2ban..."
  sudo apt-get install fail2ban -y
  sudo ufw allow ssh
  sudo ufw allow 7082
  sudo ufw enable

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
fi

## Setup conf
mkdir -p ~/bin
IP=$(curl -s4 http://ip.42.pl/raw)
NAME="index"
CONF_FILE=index.conf

MNCOUNT=""
re='^[0-5]+$'
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
  echo "maxconnections=64" >> ${NAME}.conf_TEMP
  echo "IPADDRESS=[$IPADDRESS]" >> ${NAME}.conf_TEMP
  echo "externalip=[$IPADDRESS]" >> ${NAME}.conf_TEMP
  echo "znodeaddr=[$IPADDRESS]:7082" >> ${NAME}.conf_TEMP
  echo "bind=[$IPADDRESS]:7082" >> ${NAME}.conf_TEMP
  echo "znode=1" >> ${NAME}.conf_TEMP
  echo "znodeprivkey=$PRIVKEY" >> ${NAME}.conf_TEMP
  
  sudo ufw allow [$IPADDRESS]:7082/tcp

  mv ${NAME}.conf_TEMP $CONF_DIR/${NAME}.conf
  
  sh ~/bin/${NAME}d_$ALIAS.sh
done
