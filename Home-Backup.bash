#!/bin/bash

if [ "`networksetup -getcurrentlocation`"="Home" ]
then
	printf "Start:\t`date`\n" >> backups.log
	printf "Start System Backup:\t`date`\n" >> backups.log
	tmutil startbackup
	printf "Start Lightroom Backup:\t`date`\n" >> backups.log
	rsync -vcrzhie "ssh" --log-file=Lightroom_to_nas.log /Volumes/The\ Glove/Lightroom\ Catalogs/ nas:/mnt/RAIDZ/HOME/binary/Lightroom_Catalogs/
	printf "Start Music Backup:\t`date`\n" >> backups.log
	rsync -vcrzhie "ssh" --log-file=music_to_nas.log /Volumes/The\ Glove/iTunes-The_Glove/ nas:/mnt/RAIDZ/Media/iTunes/
	printf "Stop:\t`date`\n" >> backups.log
else
	Printf "You are not home."
fi
