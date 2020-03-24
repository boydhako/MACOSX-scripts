#!/bin/bash
file="$1"

function PREP { 
	if [ -z "$file" ]; then
		printf "Please specify a single file.\n"
		exit 1
	else
		for prop in $(file $file | awk -F: '{printf $NF}' | sed 's/,/\n/g' | sed -e 's/^ //g' -e 's/ /_/g'); do
			if [ "$prop" == "WAVE_audio" ]; then
				export wav="1"
			elif [ "$prop" == "24_bit" ]; then
				export pcm="24"
			elif [ "$prop" == "stereo_48000_Hz" ]; then
				export channel="stereo"
				export sfreq="48"
			fi

			if [ $(echo $prop | egrep -i endian | wc -l) == "1" ]; then
				if [ $(echo $prop | egrep -i little-endian | wc -l) == "1" ]; then
					export datatype="little"
				elif [ $(echo $prop | egrep -i big-endian | wc -l) == "1" ]; then
					export datatype="big"
				fi
			fi

		done

		if [ "$wav" != "1" -a -z $datatype ]; then
			printf "oops. Wrong type of file.\n"
			exit 1
		fi
	fi
};

function GETTAGS {
	export tt="$(kid3-cli -c "get Title" $file)"
	export ta="$(kid3-cli -c "get Artist" $file)"
	export tl="$(kid3-cli -c "get Album" $file)"
	export tn="$(kid3-cli -c "get Track Number" $file)"
	export tc="$(kid3-cli -c "get" $file)"
}

function CONVERTWAV2MP3 {
	PREP
	GETTAGS
	#lame --verbose --replaygain-accurate --clipdetect -s $sfreq --resample $sfreq --preset insane --bitwidth $pcm --signed --$datatype-endian --cbr -b 320 -q 0 --strictly-enforce-ISO --tt "$tt" --ta "$ta" --tl "$tl" --tn "$tn" --tc "$tc" $file $(basename -s .wav $file).mp3
	lame --verbose --replaygain-accurate --preset insane --bitwidth $pcm --signed --strictly-enforce-ISO --tt "$tt" --ta "$ta" --tl "$tl" --tn "$tn" --tc "$tc" $file $(basename -s .wav $file).mp3
}
CONVERTWAV2MP3
