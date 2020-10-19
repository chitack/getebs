#!/bin/bash
#install ffmpeg
sudo apt install ffmpeg -y
#install pip
sudo apt-get install python3-pip -y
#install telegram-send
sudo pip3 install telegram-send
sudo apt-get install virtualenv -y
chmod +x getebsfm.sh
ln -sf $PWD/getebsfm.sh $HOME
ln -sf $PWD/getclip.py $HOME
sudo timedatectl set-timezone Asia/Seoul
touch $HOME/EBSRecoding_cron.log
telegram-send --configure
cd $HOME
virtualenv -p python3 inaSpeechSegEnv
echo source inaSpeechSegEnv/bin/activate
echo pip install tensorflow-gpu
echo pip install tensorflow
echo pip install inaSpeechSegmenter
