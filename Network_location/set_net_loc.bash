#!/bin/bash
locfile="$(dirname $0)/mac_net.txt"
defaultloc="Public"

for gwmac in $(netstat -rn | sed -e 's~%~ ~g' | awk '$1 == "default" {printf $2"\n"}' | sort | uniq | egrep -v -e "\." -e "::$"); do
	loc="$(awk -v gwmac="$gwmac" '$1 == gwmac {printf $2}' $locfile)"
	curloc="$(scselect | awk '$1 == "*" {printf $NF"\n"}' | sed -e 's~(~~g' -e 's~)~~g')"
	if [ "$curloc" != "$loc" ]; then
		if [ "$(awk -v loc="$loc" '$2 == loc {printf $0"\n"}' $locfile | wc -l)" -gt "0" ]; then
			scselect $loc
		else
			scselect $defaultloc
		fi
	fi
done
