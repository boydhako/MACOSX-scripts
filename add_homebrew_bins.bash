#!/bin/bash
cellar="/usr/local/Cellar"

for bindir in $(find $cellar -type d -name "bin");do
	if [ "$(echo $PATH | grep -e ":$bindir:" | wc -l)" -lt "1" ]; then
		PATH="$PATH:$bindir"
	fi
done
