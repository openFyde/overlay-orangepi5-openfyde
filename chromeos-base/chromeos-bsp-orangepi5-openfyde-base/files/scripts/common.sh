#!/bin/bash

ENV_FILE=/mnt/stateful_partition/fyde/Env.txt

ORANGEPI5="orangepi5"
ORANGEPI5B="orangepi5b"
ORANGEPI5PLUS="orangepi5plus"
DEFAULT_BOARD="$ORANGEPI5"

BOARD=""

declare -A dtb_rmap=(
    ["rk3588s-orangepi-5.dtb"]="$ORANGEPI5"
    ["rk3588s-orangepi-5b.dtb"]="$ORANGEPI5B"
    ["rk3588-orangepi-5-plus.dtb"]="$ORANGEPI5PLUS"
)


dtb="$(cat "$ENV_FILE" | grep fdtfile | sed 's/fdtfile=//g')"

if [ -z "${dtb_rmap[$dtb]}" ]; then
    BOARD=$DEFAULT_BOARD
else
    BOARD=${dtb_rmap[$dtb]}
fi
