#!/bin/bash

set -e

BC=$(which bc)

CURL=$(which curl)

DRY_RUN=""
WITH_TRAFFIC=0
WITH_TRANSPORT=0
for arg in "$@"
do
    case "$arg" in
        --dry-run)
            shift
            DRY_RUN="echo"
            echo "#!/bin/bash"
            ;;
        --with-traffic)
            shift
            WITH_TRAFFIC=1
            ;;
        --with-transport)
            shift
            WITH_TRANSPORT=1
            ;;
        --with-transport-alt)
            shift
            WITH_TRANSPORT=2
            ;;
    esac
done

ARG_1=${1//,/}
ARG_2=$2

if [[ $ARG_1 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]] && 
   [[ $ARG_2 =~ ^[+-]?[0-9]*\.?[0-9]+$ ]]
then
    POINT_X=$ARG_1
    POINT_Y=$ARG_2
else
    echo "Please provide one point."
    exit 1
fi

if [[ $3 =~ ^[0-9]+$ ]] && [[ $3 -le 19 ]] && [[ $3 -ge 1 ]]; then
    LEVEL=$3
else
    LEVEL=12
fi

VER_DEFAULT="015"
VER=$VER_DEFAULT

TRANS_MODE=47

case $4 in
    sate)
        TYPE=sate
        MODE=46
        VER="009"
        if [[ $WITH_TRANSPORT -eq 2 ]]; then
            TRANS_MODE=48
        fi
        ;;
    web-alt)
        TYPE=web
        if [[ $LEVEL -gt 9 ]] && [[ $LEVEL -lt 19 ]]; then
            MODE=41
        else
            MODE=44
        fi
        if [[ $WITH_TRAFFIC -eq 1 ]]; then
            MODE=44
        fi
        WITH_TRANSPORT=0
        ;;
    *)
        TYPE=web
        MODE=44
        WITH_TRANSPORT=0
        ;;
esac

if [[ $5 =~ ^[0-9]+$ ]]; then
    WIDTH=$5
else
    WIDTH=2000
fi

if [[ $6 =~ ^[0-9]+$ ]]; then
    HEIGHT=$6
else
    HEIGHT=2000
fi

TILE_SIZE=256

MAPS="`pwd`/maps"

if [[ ! -d ${MAPS} ]]; then
    $DRY_RUN mkdir "${MAPS}"
else
    $DRY_RUN rm -f "${MAPS}"/*
fi

calc()
{
    RESULT=$(echo "scale=10; ${3}" | $BC)
    eval "${1}=\$RESULT"
}

ceil()
{
    if [[ $(echo "${!1} == 0${!1/.*}" | $BC ) -eq 1 ]]; then
        eval "${1}=\${!1/.*}"
    else
        eval "${1}=\$((\${!1/.*}+1))"
    fi
}

download()
{
    SERVER=$((RANDOM%8+1))
    SERVER="http://q${SERVER}.baidu.com/it/"
    TRAFFIC="http://its.map.baidu.com:8002/traffic/TrafficTileService?time=0&label=web2D"

    if [[ ${#DRY_RUN} -eq 0 ]]; then
        if [[ ! -f "${MAPS}/${1},${2}.png" ]]; then
            $CURL -L -s -o "${MAPS}/${1},${2}.png"\
                "${SERVER}u=x=${1/-/M};y=${2/-/M};z=${3};v=${5};type=${4}&fm=${6}" &
            if [[ $WITH_TRAFFIC -eq 1 ]]; then
                $CURL -L -s -o "${MAPS}/${1},${2}.png.traffic"\
                    "${TRAFFIC}&v=${5}&level=${3}&x=${1/-/M}&y=${2/-/M}" &
            fi
            if [[ $WITH_TRANSPORT -gt 0 ]]; then
                $CURL -L -s -o "${MAPS}/${1},${2}.png.transport"\
                    "${SERVER}u=x=${1/-/M};y=${2/-/M};z=${3};v=${VER_DEFAULT};type=trans&fm=${TRANS_MODE}" &
            fi
        fi
    else
        echo $CURL -L -s -o \""${MAPS}/${1},${2}.png\""\
                \""${SERVER}u=x=${1/-/M};y=${2/-/M};z=${3};v=${5};type=${4}&fm=${6}\"" \&
        if [[ $WITH_TRAFFIC -eq 1 ]]; then
            echo $CURL -L -s -o \""${MAPS}/${1},${2}.png.traffic\""\
                    \""${TRAFFIC}&v=${5}&level=${3}&x=${1/-/M}&y=${2/-/M}\"" \&
        fi
        if [[ $WITH_TRANSPORT -gt 0 ]]; then
            echo $CURL -L -s -o \""${MAPS}/${1},${2}.png.transport\""\
                    \""${SERVER}u=x=${1/-/M};y=${2/-/M};z=${3};v=${VER_DEFAULT};type=trans&fm=${TRANS_MODE}\"" \&
        fi
    fi
}

calc ZOOM_FACTOR = "2 ^ (18 - $LEVEL) * 256"

calc L1 = "$POINT_X / $ZOOM_FACTOR"
ceil L1

calc G1 = "$POINT_Y / $ZOOM_FACTOR"
ceil G1

calc L2 = "( $POINT_X - $L1 * $ZOOM_FACTOR ) / $ZOOM_FACTOR * $TILE_SIZE"

calc G2 = "( $POINT_Y - $G1 * $ZOOM_FACTOR ) / $ZOOM_FACTOR * $TILE_SIZE"

E=( $L1 $G1 $L2 $G2 )

calc T1 = "( $WIDTH / 2 - ${E[2]} ) / $TILE_SIZE"
ceil T1
calc T1 = "${E[0]} - ${T1} "

calc T2 = "( $HEIGHT / 2 - ${E[3]} ) / $TILE_SIZE"
T2R=$T2
ceil T2
calc T2 = "${E[1]} - ${T2} "
calc T2R = "${E[1]} - ${T2R}"

calc T3 = "( $WIDTH / 2 + ${E[2]} ) / $TILE_SIZE"
if [[ $(echo "$T3 < 1" | $BC) -eq 1 ]]; then
    T3=0
fi
ceil T3
calc T3 = "${E[0]} + ${T3} "

calc T4 = "( $HEIGHT / 2 + ${E[3]} ) / $TILE_SIZE"
if [[ $(echo "$T4 < 1" | $BC) -eq 1 ]]; then
    T4=0
fi
T4R=$T4
ceil T4
calc T4 = "${E[1]} + ${T4} "
calc T4R = "${E[1]} + ${T4R}"

calc OFFSET_X = "($POINT_X / $ZOOM_FACTOR - $T1) * $TILE_SIZE"
calc OFFSET_X = "$OFFSET_X - $WIDTH / 2"
ceil OFFSET_X

calc OFFSET_Y = "($T4 - $POINT_Y / $ZOOM_FACTOR) * $TILE_SIZE"
calc OFFSET_Y = "$OFFSET_Y - $HEIGHT / 2"

calc TX = "$T4R - $T2R"
if [[ $(echo "0${TX/.*} % 2" | $BC) -eq 1 ]]; then
    calc OFFSET_Y = "$OFFSET_Y + $TILE_SIZE"
fi

ceil OFFSET_Y

for (( J=$T1; J<=$T3; J++ )) ; do
    for (( K=$T2; K<=$T4; K++ )) ; do
        download $J $K $LEVEL $TYPE $VER $MODE
    done

    $DRY_RUN wait
done

$DRY_RUN wait

if [[ ${#DRY_RUN} -eq 0 ]]; then
    echo "${WIDTH}x${HEIGHT}+${OFFSET_X}+${OFFSET_Y}"
else
    echo "$(which bash) pieces2one.sh ${WIDTH}x${HEIGHT}+${OFFSET_X}+${OFFSET_Y}"
fi
