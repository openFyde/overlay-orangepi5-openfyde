#!/bin/sh

m2=""
NVME_MAGIC='NVME'
SATA_MAGIC='SATA'
SECTOR_SIZE=512
# should be sam as write location
MAGIC_SECTOR=65598
rootdev=""

rootdev="$(findmnt -n -o source / | sed 's/p[0-9]//g')"
m2="$(dd if="$rootdev" bs=1 skip=33586176 count=4 2>/dev/null)"

if [ "$m2" = "SATA" ]; then
    echo overlays=ssd-sata >> /mnt/stateful_partition/unencrypted/Env.txt
    reboot
fi
