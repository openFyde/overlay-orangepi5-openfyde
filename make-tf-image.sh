#!/bin/bash
#

usage()
{
    echo "$0 $chromiumos_image $loaders_dir"
    exit 1
}

err()
{
    echo "$1"
    exit 2
}

src=$1
loaders=$2

[ ! -f "$src" ] && err "src image not found"

[ ! -f "${loaders}/idbloader.img" ] && err "${loaders}/idbloader.img not found"
[ ! -f "${loaders}/u-boot.itb" ] && err "${loaders}/u-boot.itb not found"

 dd if="${loaders}/idbloader.img" of="$src" seek=64 conv=notrunc,fdatasync status=progress || err "write failed"
 dd if="${loaders}/u-boot.itb" of="$src" seek=16384 conv=notrunc,fdatasync status=progress || err "write failed"

 echo "Writes to ${src} done"
