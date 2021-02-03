#!/bin/bash
PROGRAM_NAME=PowerEnglish
HOUR=$((`date +%H`))
if (( $HOUR >= 6 )); then
    REC_DATE=`date +%Y%m%d-%H%M`
else
    REC_DATE=`date --date="-1 day" +%Y%m%d-%H%M`
fi
MP3_FILE_NAME=$1
DIAL_MP3_FILE_NAME=$PROGRAM_NAME"Dialogue_"$REC_DATE.mp3
ffmpeg -ss 2:10 -i $MP3_FILE_NAME -to 3:00 $DIAL_MP3_FILE_NAME
if [ -f $HOME/getebs/inaSpeechSegEnv/bin/activate ]; then
. $HOME/getebs/inaSpeechSegEnv/bin/activate
elif [ -f $HOME/inaSpeechSegEnv/bin/activate ]; then
. $HOME/inaSpeechSegEnv/bin/activate
fi
python getclip.py -i $DIAL_MP3_FILE_NAME
