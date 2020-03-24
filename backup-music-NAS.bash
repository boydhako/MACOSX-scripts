#!/bin/bash
#rsync -vcrzhie "ssh" --log-file=music_to_nas.log /Volumes/The\ Glove/Audio/ nas:/mnt/RAIDZ/Media/Music/
rsync -vcrzhie "ssh" --log-file=music_to_nas.log /Volumes/The\ Glove/iTunes-The_Glove/ nas:/mnt/RAIDZ/Media/iTunes/
