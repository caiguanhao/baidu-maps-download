#!/bin/bash

set -e

CONVERT=$(which convert)

MAPS="`pwd`/maps"

if [[ ! -d ${MAPS} ]]; then
	echo "${MAPS} does not exist."
	echo "Run point2pieces.sh first."
	exit 1
fi

PIECES=($(find "${MAPS}" -maxdepth 1 -name "*,*.png"))
if [[ ${#PIECES[@]} -eq 0 ]]; then
	echo "Images not found."
	exit
fi

CROP=""
if [[ ${#1} -gt 0 ]]; then
	CROP=" -crop ${1} "
fi

X=()
Y=()
for (( i = 0; i < ${#PIECES[@]}; i++ )); do
	N=${PIECES[$i]/${MAPS}\//}
	N=${N%.*}
	X[${#X[@]}]=${N%%,*}
	Y[${#Y[@]}]=${N##*,}
done
X=($(tr ' ' '\n' <<< "${X[@]}" | sort -nu | tr '\n' ' '))
Y=($(tr ' ' '\n' <<< "${Y[@]}" | sort -nru | tr '\n' ' '))

ROWS=()

if [[ ${#X[@]} -le 1 ]]; then
	PIECES=($(tr ' ' '\n' <<< "${PIECES[@]}" | sort -nru | tr '\n' ' '))
	$CONVERT ${PIECES[@]} -append ${CROP} "${MAPS}/done.png"
else
	for (( i = 0; i < ${#Y[@]}; i++ )); do
		PIECES=$(find "${MAPS}" -maxdepth 1 -name "*,${Y[$i]}.png")
		ROW="${MAPS}/row${i}.png"
		$CONVERT ${PIECES} +append $ROW
		ROWS[${#ROWS[@]}]=$ROW
	done

	$CONVERT ${ROWS[@]} -append ${CROP} "${MAPS}/done.png"

	rm -f ${ROWS[@]}
fi

rm -f ${PIECES[@]}
