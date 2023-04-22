#!/bin/bash
svr="radio.kaupu.family:/var/madsonic/mp3"
log="/Users/bako/.logs/radio.kaupu.family.log"
sshkey="/Users/bako/.ssh/cronjob-id_rsa"

pid="$$"
lockfile="/tmp/madsonic-sync.pid"

function PREP {
    if [ -f "$lockfile" ]; then
        printf "\n\nMadsonic sync is already running (%s)...\n\n\n" "$(cat $lockfile)"
        exit 1
    else
        echo $pid > $lockfile
    fi
}
function RUNSYNC {
    ssh -i $sshkey radio.kaupu.family "hostname" 2>&1 > /dev/null
    if [ "$?" == "0" ]; then
        rsync -Wvvcrmzhi --filter="- *.strings" --filter="- *.plist" --filter="- *DS_Store" --filter="- *.[mM][pP]4" --filter="+ *.[mM][pP]3" --log-file=$log --delete-after --rsh="ssh -vvv -i $sshkey" /Users/bako/Music/Music/Media.localized/Music/ $svr 2>&1 >> $log
        rsynccode="$?"
        if [ "$rsynccode" == "12" ]; then
            osascript -e "display notification \"RSYNC has the stupid code 12 error again. Trying again in ten minutes.\" with title \"Madsonic Sync failed\""
            cat $log | mailx -s "Madsonic failed code 12 sync log" boyd.hanalei.ako@gmail.com
            rm -f $log
            sleep 600
            RUNSYNC
        fi
    else
        osascript -e "display notification \"Unable to reach $svr sleeping for five minutes and trying again.\" with title \"Madsonic Sync to $svr\""
        sleep 300
        RUNSYNC
    fi
}
function CLEANUP {
    rm -f $lockfile
    if [ "$rsynccode" == "0" ]; then
        osascript -e "display notification \"Sync has completed successfully!\" with title \"Madsonic Sync to $svr\""
    else 
        osascript -e "display notification \"Sync failed. Error Code: $rsynccode\" with title \"Madsonic Sync to $svr\""
    fi
    cat $log | mailx -s "Madsonic sync log" boyd.hanalei.ako@gmail.com
    rm -f $log
}
function MADSONICSYNC {
    PREP
    RUNSYNC
    CLEANUP
}
MADSONICSYNC
