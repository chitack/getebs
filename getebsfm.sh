#!/bin/bash --login

#Old URL
#RADIO_ADDR="http://new_iradio.ebs.co.kr/iradio/iradiolive_m4a/playlist.m3u8"
#RADIO_ADDR="http://bandibook.ebs.co.kr/bandibook/live_m4a/playlist.m3u8"
#RADIO_ADDR="http://ebsonairiosaod.ebs.co.kr/fmradiobandiaod/bandiappaac/playlist.m3u8"

if [[ $4 == *"fm"* ]]; then
    RADIO_ADDR="http://ebsonair.ebs.co.kr/fmradiofamilypc/familypc1m/playlist.m3u8"
elif [[ $4 == *"bandi"* ]]; then
    RADIO_ADDR="http://ebsonair.ebs.co.kr/iradio/iradiolive_m4a/playlist.m3u8"
else
    RADIO_ADDR="http://ebsonair.ebs.co.kr/fmradiofamilypc/familypc1m/playlist.m3u8"
fi

PROGRAM_NAME=$1
RECORD_MINS=$2
#DEST_DIR=$3

HOUR=$((`date +%H`))
if (( $HOUR >= 6 )); then
    REC_DATE=`date +%Y%m%d-%H%M`
else
    REC_DATE=`date --date="-1 day" +%Y%m%d-%H%M`
fi

MP3_FILE_NAME=$PROGRAM_NAME"_"$REC_DATE.mp3
FILENAME=${PROGRAM_NAME}"_"`date +%Y%m%d`*.mp3

if [[ -n $(find $HOME -maxdepth 1 -type f -name "${FILENAME}") ]]
then
    echo "same file ${FILENAME}"
    #/usr/local/bin/telegram-send "Skip to resend"
else
    echo "no file"
    ffmpeg -t $RECORD_MINS -y -i $RADIO_ADDR $MP3_FILE_NAME &>/dev/null

    #mkdir -p $DEST_DIR
    #mv $MP3_FILE_NAME $DEST_DIR
    #https://pypi.org/project/telegram-send/#installation
    if [[ $PROGRAM_NAME == *"Dial"* ]]; then
        echo "dialogue"
	. $HOME/inaSpeechSegEnv/bin/activate
	python getclip.py -i "$MP3_FILE_NAME"
    else
        /usr/local/bin/telegram-send --caption "$3" --file "$MP3_FILE_NAME"
    fi
fi
find $HOME -maxdepth 1 -type f -mtime +50 -name "$PROGRAM_NAME*" -exec rm -rf {} \;
RECDATEONLY=`date +%Y%m%d` 
TOTALMP3SIZE=`du -chb  *"$RECDATEONLY"* | grep total | awk '{print $1}'`
echo $TOTALMP3SIZE
if (( $TOTALMP3SIZE >= 37000000 )); then
        echo "enough size, turn off"
        /usr/local/bin/telegram-send "enough size, turn off"
        sudo shutdown -P +1
else
        echo "not enough wait more"
fi
