#!/bin/bash

set -e

echo -e "\x1B[37m> Testing center2pieces.sh...\x1B[39m"

$BASH center2pieces.sh 12616085.15, 2628677.18 15 web-alt 500 500 | xargs $BASH pieces2one.sh

ls -l maps

sleep 3

echo -e "\x1B[37m> Testing points2pieces.sh...\x1B[39m"

$BASH points2pieces.sh 12550000.00, 2650000.00 12650000.00, 2550000.00 && $BASH pieces2one.sh

ls -l maps

echo -e "\x1B[92mAll tests were passed.\x1B[39m"
exit 0
