#!/bin/bash
vpncfg="PIA-Random-US"

function GETCFGS {
osascript <<EOF
tell application "Tunnelblick"
	get configurations
end tell
EOF
}
function GETSTATE {
osascript <<EOF
tell application "Tunnelblick"	
	get state of first configuration where name = "$1"
end tell
EOF
}
function CONNECTVPN {
osascript <<EOF
tell application "Tunnelblick"	
	connect "$1"
end tell
EOF
}
function DISCONNECTVPN {
osascript <<EOF
tell application "Tunnelblick"	
	disconnect "$1"
end tell
EOF
}
function CHECKVPN {
	for cfg in $(GETCFGS | sed 's/configuration //g' | sed 's/,//g'); do
		if [ $cfg == "$vpncfg" ]; then
			state="$(GETSTATE $cfg)"
			case $state in
				EXITING)
					CONNECTVPN $cfg > /dev/null 2>&1
					sleep 30
					CHECKVPN
				;;
				WAIT)
					DISCONNECTVPN $cfg > /dev/null 2>&1
					sleep 30
					CHECKVPN
				;;
				*)
					printf "%s is %s at %s\n" "$cfg" "$state" "$(date +%F-%H%M%S%Z)"
				;;
			esac
		fi
	done
}

CHECKVPN
