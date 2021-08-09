#!/usr/bin/python
# -*- encoding:utf-8-*-
# -*- coding: utf-8 -*-

from inaSpeechSegmenter import Segmenter, seg2csv 
import os,datetime
#media = '/home/abat/pyAudioAnalysis/powerenglish/PowerEnglishDialogue_20200804-0743.mp3'

def getclips(media):
    newname = "%d_%s.mp3" %  ( datetime.datetime.now().weekday(), datetime.datetime.now().strftime("%Y%m%d") )
    seg = Segmenter()
    segmentation = seg(media)
    print("all seg", segmentation)
    mm = [ i for i in segmentation if i[0] == 'music']
    for i in mm: print(i)
    timestamp = []
    for i in range(0, len(mm)-1):
        start = mm[i][1]
        end = mm[i+1][2]
        lengtha = end - start
        if lengtha < 30: # less than 30 sec
            print("Too short, wait more", lengtha)
            continue
        elif lengtha > 55 : # over than 55 sec
            print("Too long?")
            continue
        print("%d-%f~%f:%f " % (i, start, end, lengtha))

        print("ffmpeg -ss %f -i %s -to %f %s -y " % ( start, media, end-start, newname))
        os.system("ffmpeg -ss %f -i %s -to %f %s -y" % ( start, media, (end-start), newname))
        os.system("/usr/local/bin/telegram-send --caption %d_%s --file %s" % ( datetime.datetime.now().weekday(), datetime.datetime.now().strftime("%Y%m%d"), newname))

    return

import argparse
parser = argparse.ArgumentParser(description='Process clip')
parser.add_argument('-i', '--input', help='Input media to analyse', required=True)
args = parser.parse_args()

if __name__ == '__main__': 
    getclips(args.input)

