#!/bin/bash

function PYVERSIONS {
	for pdir in $(echo $PATH | tr ":" "\n"); do
		for bin in $(find $pdir -type f -iname "*python*" 2>/dev/null | egrep -e "python[[:digit:]].[[:digit:]]$"); do
			version="$($bin -V| awk '{printf $NF}')"
			printf "%s\n" "$version"
		done
	done
}

PYVERSIONS | sort -n -r | uniq | awk '{printf $0" "}'
