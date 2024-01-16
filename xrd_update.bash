#!/bin/bash

#  501 74968     1   0  9:00AM ??         0:01.33 /Library/Application Support/X-Rite/Frameworks/XRiteDevice.framework/Versions/B/Resources/XRD Software Update.app/Contents/MacOS/XRD Software Update
for pid in $(ps -ef | grep -e "XRD Software Update" | awk '{printf $2"\n"}'); do kill $pid > /dev/null 2>&1 ; done
