#!/bin/bash
#
shell_lines=102         # Adjust it if the script changes
version_string=r102-r1
targetdir=orangepi5-openfyde
TMPROOT=${TMPDIR:=./}
target=""
m2="nvme"
NVME_MAGIC='NVME'
SATA_MAGIC='SATA'
SECTOR_SIZE=512
# Write magic to the last sector of RESERVED partition of ChromiumOS
MAGIC_SECTOR=65598
self=$(realpath $0)

usage()
{
    echo ""
    echo "$0 [options]"
    echo ""
    echo "options:"
    echo "  '--help/-h'"
    echo "      This message"
    echo "  '--target/-o [target]'"
    echo "      path target image"
    echo "  '--boot sata'"
    echo "      generates images supporting boot from SATA"
    echo "  '--boot nvme'"
    echo "      generates images supporting boot from NVME"
    exit 1;
}

err()
{
    echo "$@"
    exit 1
}

while [ "$1" ]; do
   case "$1" in
       "--help"|"-h")
           usage;
           ;;
       "--target")
           if [ "$2" ]; then
               target="$2"
               shift;
           else
               err "ERROR: --target: no target specified."
           fi
           ;;
       "--boot")
           if [ "$2" == "nvme" -o "$2" == "NVME" ]; then
               m2=nvme
               shift;
           elif [ "$2" == "sata" -o "$2" == "SATA" ]; then
               m2=sata
               shift;
           else
               err "--boot requires an argument"
           fi
           ;;
       *)
           usage
           ;;
    esac
    shift
done


cwd="$(pwd)"
temp="${TMPDIR}/openfyde.XXXXXXXXXXXXXX"

[ -z "$target" ] && target="$(echo "$0" | sed s/.run/.img/g)"
echo "$target" | grep -q '.img' || target="${target}.img"

[ -f "$target" ] && err "$target already exists, please remove it first"
[ -d "$target" ] && berr "$target already exists, please remove it first"


mkdir -p "$temp"

command -v "unxz" > /dev/null 2>&1 || err "command unxz is not found"

cat $self | tail -n +${shell_lines} | unxz > $target

if [ "$?" -ne 0 ]; then
   rm "$target"
   err "failed to unxz image"
fi


if [ "$m2" == "nvme" ]; then
    magic=$NVME_MAGIC
else
    magic=$SATA_MAGIC
fi

echo -n "$magic" | dd of="$target" bs=$SECTOR_SIZE seek="$MAGIC_SECTOR" conv=fdatasync,notrunc

exit 0
