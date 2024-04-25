#!/bin/bash

ENV_FILE=/mnt/stateful_partition/fyde/Env.txt
NVME_MAGIC='NVME'
SATA_MAGIC='SATA'
SECTOR_SIZE=512
# should be sam as write location
MAGIC_SECTOR=65598
BOARD_MAGIC_SECTOR=65597
COUNT=4
rootdev=""
m2=""

err()
{
    echo "$@" > /dev/kmsg
    exit 1
}

declare -A dtb_map=(
    ["OP5 "]="rk3588s-orangepi-5.dtb"
    ["OP5B"]="rk3588s-orangepi-5b.dtb"
    ["OP5P"]="rk3588-orangepi-5-plus.dtb"
)

board=""

offset=$(( SECTOR_SIZE * MAGIC_SECTOR ))
rootdev="$(findmnt -n -o source / | sed 's/p[0-9]//g')"
m2="$(dd if="$rootdev" bs=1 skip=$offset count=$COUNT 2>/dev/null)"

mkdir -p "$(dirname $ENV_FILE)" || true

if [ "$m2" == "$SATA_MAGIC" ]; then
    echo 'overlays=rk3588-ssd-sata' >> $ENV_FILE
fi

offset=$(( SECTOR_SIZE * BOARD_MAGIC_SECTOR ))
_board="$(dd if="$rootdev" bs=1 skip=$offset count=$COUNT 2>/dev/null)"
dtb="${dtb_map[$_board]}"

[ -z "$dtb" ] && err "can't recognize board type from $rootdev offset $offset"
echo "fdtfile=$dtb" >> $ENV_FILE

reboot
