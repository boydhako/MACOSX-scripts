#!/bin/bash -xv
log="/Users/void/Downloads/wake_up.txt"
eventname="Wake Up"
xid=""
day="$(date +%m%d)"

for calname in $(icalBuddy --ect Local,Subscription,Birthday calendars | sed -e 's~• ~~g' -e 's~ ~_~g' | egrep -v -e "^.*type:" -e "^.*UID:" | sort | uniq); do
	if [ "$(echo $calname | sed -e 's~_~ ~g')" != "Boyd H. Ako" ]; then
		xid="$xid $(icalBuddy --ect Local,Subscription,Birthday calendars | egrep -A 2 -e "$(echo $calname | sed -e 's~_~ ~g')" | awk '$1 == "UID:" {printf $NF"\n"}')"
	fi
done

function WATCHTIME {
	icalBuddy --ect Local,Subscription,Birthday -ec $(echo $xid | sed -e 's~ ~,~g') -uid -b \> -nc -ps "|>|>|" -tf "%H%M.%S[%z]" -po "title,datetime" eventsToday | sort | uniq | awk -F\> -v ename="$eventname" '/ename/ {printf $0"\n"}'
}
WATCHTIME
