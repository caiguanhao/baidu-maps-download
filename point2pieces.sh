#!/bin/bash

set -e

BC=$(which bc)

CURL=$(which curl)

ARG_1=${1//,/}
ARG_2=$2
ARG_3=${3//,/}
ARG_4=$4

if [[ $ARG_1 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]] && 
   [[ $ARG_2 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]] && 
   [[ $ARG_3 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]] && 
   [[ $ARG_4 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]
then
    START_X=$ARG_1
    START_Y=$ARG_2
    END_X=$ARG_3
    END_Y=$ARG_4
else
    echo "Please provide two points."
    exit 1
fi

if [[ $5 =~ ^[0-9]+$ ]] && [[ $5 -le 19 ]] && [[ $5 -ge 1 ]]; then
	LEVEL=$5
else
	LEVEL=12
fi

case $6 in
	sate)
		TYPE=sate
		MODE=46
		;;
	*)
		TYPE=web
		MODE=44
		;;
esac

VER="015"

MAPS="`pwd`/maps"

if [[ ! -d ${MAPS} ]]; then
	mkdir "${MAPS}"
else
	rm -f "${MAPS}"/*
fi

ceil()
{
	if [[ $(echo "${!1} == ${!1/.*}" | $BC ) -eq 1 ]]; then
		eval "${1}=\${!1/.*}"
	else
		eval "${1}=\$((\${!1/.*}+1))"
	fi
}

set_block_num_of()
{
	local BN=$((${!3}-18))
	BN=${BN/-/}
	BN=$(echo "scale=10; ${!1} / 2 ^ ${BN} / 256" | $BC )
	ceil BN
	eval "${5}=\${BN}"
}

download()
{
	SERVER=$((RANDOM%8+1))
	SERVER="http://q${SERVER}.baidu.com/it/"
	if [[ ! -f "${MAPS}/${1},${2}.png" ]]; then
		$CURL -L -s -o "${MAPS}/${1},${2}.png"\
			"${SERVER}u=x=${1};y=${2};z=${3};v=${5};type=${4}&fm={$6}" &
	fi
}

set_block_num_of START_X at_level LEVEL to START_BLOCK_X
set_block_num_of START_Y at_level LEVEL to START_BLOCK_Y

set_block_num_of END_X at_level LEVEL to END_BLOCK_X
set_block_num_of END_Y at_level LEVEL to END_BLOCK_Y

if [[ $START_BLOCK_X -eq $END_BLOCK_X ]] && [[ $START_BLOCK_Y -eq $END_BLOCK_Y ]]; then
	download $START_BLOCK_X $END_BLOCK_X $LEVEL $TYPE $VER $MODE
elif [[ $START_BLOCK_X -eq $END_BLOCK_X ]] && [[ $START_BLOCK_Y -gt $END_BLOCK_Y ]]; then
	for (( J=$END_BLOCK_Y ; J<$START_BLOCK_Y ; J++ )) ;	do
		download $START_BLOCK_X $J $LEVEL $TYPE $VER $MODE
	done
elif [[ $START_BLOCK_X -lt $END_BLOCK_X ]] && [[ $START_BLOCK_Y -eq $END_BLOCK_Y ]]; then
	for (( J=$START_BLOCK_X; J<$END_BLOCK_X; J++ )) ; do
		download $J $START_BLOCK_Y $LEVEL $TYPE $VER $MODE
	done
elif [[ $START_BLOCK_X -lt $END_BLOCK_X ]] && [[ $START_BLOCK_Y -gt $END_BLOCK_Y ]]; then
	for (( J=$START_BLOCK_Y; J>$END_BLOCK_Y; J-- )) ; do
		for (( K=$START_BLOCK_X; K<$END_BLOCK_X; K++ )) ; do
			download $K $J $LEVEL $TYPE $VER $MODE
		done
		wait
	done
fi

wait
