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
REC_DATE=`date +%Y%m%d-%H%M`
if (( $HOUR >= 6 )); then
  if [[ $4 == *"bandi"* ]]; then
    REC_DATE=`date --date="-1 day" +%Y%m%d-%H%M`
  fi
fi

MP3_FILE_NAME=$PROGRAM_NAME"_"$REC_DATE.mp3
FILENAME=${PROGRAM_NAME}"_"`date +%Y%m%d`*.mp3

SavedIFS="$IFS"
IFS=":."
Time=($RECORD_MINS)
Seconds=$(( ${Time[0]}*60 + ${Time[1]}))
IFS="$SavedIFS"

if [[ -n $(find $HOME -maxdepth 1 -type f -name "${FILENAME}") ]]
then
    echo "same file ${FILENAME}"
    #/usr/local/bin/telegram-send "Skip to resend"
else
    echo "no file"
    ffmpeg -t $RECORD_MINS -y -i $RADIO_ADDR $MP3_FILE_NAME &>/dev/null
    echo "try to send file $MP3_FILE_NAME"

    if [ -f "$MP3_FILE_NAME" ]; then
        FILESIZE=$(stat -c%s "$MP3_FILE_NAME")
        echo "$MP3_FILE_NAME is $FILESIZE bytes"
        if (( $FILESIZE < $(( $Seconds * 15000)) )) ; then
            echo "too small, try to delete for next recording $FILESIZE"
	    /usr/local/bin/telegram-send "too small, try to delete for next recording $FILESIZE"
            rm -rf "$MP3_FILE_NAME"
        else
            #time /usr/local/bin/telegram-send --caption "$3" --file "$MP3_FILE_NAME" --timeout 120.0
            /usr/local/bin/telegram-send --caption "$3" --file "$MP3_FILE_NAME"
            if [[ $PROGRAM_NAME == *"Power"* ]]; then
	        DIAL_MP3_FILE_NAME=$PROGRAM_NAME"Dialogue_"$REC_DATE.mp3
                ffmpeg -ss 2:10 -i $MP3_FILE_NAME -to 3:00 $DIAL_MP3_FILE_NAME
                if [ -f $HOME/getebs/inaSpeechSegEnv/bin/activate ]; then
		    . $HOME/getebs/inaSpeechSegEnv/bin/activate
		elif [ -f $HOME/inaSpeechSegEnv/bin/activate ]; then
		    . $HOME/inaSpeechSegEnv/bin/activate
		fi
                python getclip.py -i $DIAL_MP3_FILE_NAME
            fi
        fi
    else
        echo "can not record the file($MP3_FILE_NAME)"
	/usr/local/bin/telegram-send "can not record the file($MP3_FILE_NAME)"
    fi

fi
find $HOME -maxdepth 1 -type f -mtime +50 -name "$PROGRAM_NAME*" -exec rm -rf {} \;
RECDATEONLY=`date +%Y%m%d` 
TOTALMP3SIZE=`du -chb *"$RECDATEONLY"* | grep total | awk '{print $1}'`
TOTALMP3COUNT=`ls *"$RECDATEONLY"* |  wc | awk '{print $1}'`
echo $TOTALMP3SIZE, $TOTALMP3COUNT
if (( $TOTALMP3SIZE >= 55000000 && $TOTALMP3COUNT >= 5 )); then
        echo "enough size, turn off"
        /usr/local/bin/telegram-send "enough size, turn off"
        sudo shutdown -P +1
else
        echo "not enough wait more"
fi
