#!/bin/bash
#install ffmpeg
sudo apt install ffmpeg -y
#install pip
sudo apt-get install pip python3-pip -y
#install telegram-send
sudo pip3 install telegram-send
chmod +x getebsfm.sh
ln -sf $PWD/getebsfm.sh $HOME
sudo timedatectl set-timezone Asia/Seoul
touch $HOME/EBSRecoding_cron.log
telegram-send --configure
