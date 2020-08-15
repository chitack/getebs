#!/usr/bin/python
# -*- encoding:utf-8-*-
# -*- coding: utf-8 -*-

from inaSpeechSegmenter import Segmenter, seg2csv 
import os,datetime
#media = '/home/abat/pyAudioAnalysis/powerenglish/PowerEnglishDialogue_20200804-0743.mp3'

def getclips(media):
    seg = Segmenter()
    segmentation = seg(media)
    print(segmentation)
    timestamp = []
    for i in segmentation:
        if i[0] == 'music':
            print(i)
            if len(timestamp) :
                timestamp[1] = i[2]
            else:   
                timestamp.append(i[1])
                timestamp.append(i[2])
    
    print(timestamp)
    for i in timestamp:
        print(int(i))

    newname = "%s.mp3" %  ( datetime.datetime.now().strftime("%Y%m%d") )
    print("ffmpeg -ss %d -i %s -to %d %s" % ( timestamp[0], media, int(timestamp[1]-timestamp[0])+1, newname))
    os.system("ffmpeg -ss %d -i %s -to %d %s" % ( timestamp[0], media, int(timestamp[1]-timestamp[0])+1, newname))
    os.system("/usr/local/bin/telegram-send --caption %s --file %s" % ( datetime.datetime.now().strftime("%Y%m%d"), newname))


import argparse
parser = argparse.ArgumentParser(description='Process clip')
parser.add_argument('-i', '--input', help='Input media to analyse', required=True)
args = parser.parse_args()

if __name__ == '__main__':
    getclips(args.input)

