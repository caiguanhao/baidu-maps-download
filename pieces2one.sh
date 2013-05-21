#!/bin/bash

set -e

CONVERT=$(which convert)

MAPS="`pwd`/maps"

DRY_RUN=""
for arg in "$@"
do
	case "$arg" in
		--dry-run)
			shift
			DRY_RUN="echo"
			echo "#!/bin/bash"
			;;
	esac
done

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
	ALL_PIECES=($(tr ' ' '\n' <<< "${PIECES[@]}" | sort -nru | tr '\n' ' '))
	$DRY_RUN $CONVERT ${ALL_PIECES[@]} -append ${CROP} "${MAPS}/done.png"
else
	for (( i = 0; i < ${#Y[@]}; i++ )); do
		ALL_PIECES=()
		for EX in "${X[@]}"; do
			ALL_PIECES=( "${ALL_PIECES[@]}" "${MAPS}/${EX},${Y[$i]}.png" )
		done
		ROW="${MAPS}/row${i}.png"
		$DRY_RUN $CONVERT ${ALL_PIECES[@]} +append $ROW
		ROWS[${#ROWS[@]}]=$ROW
	done

	$DRY_RUN $CONVERT ${ROWS[@]} -append ${CROP} "${MAPS}/done.png"

	$DRY_RUN rm -f ${ROWS[@]}
fi

$DRY_RUN rm -f ${PIECES[@]}
