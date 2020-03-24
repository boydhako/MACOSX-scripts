#!/bin/bash 
log="/Users/void/Downloads/wake_up.txt"
eventname="Wake Up"
xid=""
day="$(date +%m%d)"
PATH="/usr/local/Cellar/ical-buddy/1.10.1/bin:$PATH"

for calname in $(icalBuddy --ect Local,Subscription,Birthday calendars | sed -e 's~• ~~g' -e 's~ ~_~g' | egrep -v -e "^.*type:" -e "^.*UID:" | sort | uniq); do
	if [ "$(echo $calname | sed -e 's~_~ ~g')" != "Boyd H. Ako" ]; then
		xid="$xid $(icalBuddy --ect Local,Subscription,Birthday calendars | egrep -A 2 -e "$(echo $calname | sed -e 's~_~ ~g')" | awk '$1 == "UID:" {printf $NF"\n"}')"
	fi
done

function WATCHTIME {
	time="$(icalBuddy --ect Local,Subscription,Birthday -ec $(echo $xid | sed -e 's~ ~,~g') -uid -b \> -nc -ps "|>|>|" -tf "%H%M.%S" -po "title,datetime" eventsToday | sort | uniq | egrep -e "$eventname" | awk -F \> '{printf $3}' | awk '{printf $1}')"
	daytime="$day$time"
	runtime="$(date -j "$day$time" +%s)"
	curtime="$(date +%s)"
	sleeptime="$(expr $runtime - $curtime)"

	#printf "Day=%s\nTime=%s\n" "$day" "$time"
	#echo $sleeptime
	printf "SETTIME:%s\n" "$time" >> $log
	
	if [[ "$sleeptime" -le "0" ]]; then
		printf "Script ran at %s with sleeptime at %s.\n" "$(date)" "$sleeptime" >> $log
		exit 0
	elif [[ "$sleeptime" -lt "3601" ]]; then
		printf "Script ran at %s with sleeptime at %s.\n" "$(date)" "$sleeptime" >> $log
		sleep $sleeptime
		printf "DATE:%s\n" "$(date)" >> $log
	else
		printf "---\nNot running\nChecked at: DATE:%s\nDAYTIME:%s\nRUNTIME:%s\n\n" "$(date)" "$daytime" "$runtime" >> $log
		exit 2
	fi
}
WATCHTIME
