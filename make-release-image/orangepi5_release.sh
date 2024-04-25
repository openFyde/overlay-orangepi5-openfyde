#!/bin/bash
#
shell_lines=295         # Adjust it if the script changes
version_string=r114
targetdir=orangepi5-openfyde
TMPROOT=${TMPDIR:=./}
target=""
m2=""
TMP="$(mktemp -d ${TMPROOT}/XXXXXX)"

NVME_MAGIC='NVME'
SATA_MAGIC='SATA'
EMMC_MAGIC='EMMC'

BOARD_MAGIC=""
ORANGEPI5="orangepi5"
ORANGEPI5B="orangepi5b"
ORANGEPI5PLUS="orangepi5plus"

declare -A BOARD_MAP=(
    ["$ORANGEPI5"]="OP5 "
    ["$ORANGEPI5B"]="OP5B"
    ["$ORANGEPI5PLUS"]="OP5P"
)

board=""

SECTOR_SIZE=512
# Write magic to the last sector of RESERVED partition of ChromiumOS
MAGIC_SECTOR=65598

# board magic to the last 2 sector of RESERVED partition of ChromiumOS
BOARD_MAGIC_SECTOR=65597

self=$(realpath $0)
skip="false"
inplace="false"
src=""

cleanup()
{
    [ -d "$TMP" ] && rm -rf $TMP
}

usage()
{
    echo ""
    echo "$0 [options]"
    echo ""
    echo "options:"
    echo "  '--help/-h'"
    echo "      This message"
    echo "  '--src/-i [src]'"
    echo "      path of src image"
    echo "  '--target/-o [target]'"
    echo "      path of target image"
    echo "  '--skip/-s"
    echo "      src image is plain, skip uncompression"
    echo "  '--inplace/-p"
    echo "      do not copy src to target, modify it inplace"
    echo "  '--boot sata/nvme/emmc'"
    echo "      generates images supporting boot from SATA/NVME/EMMC"
    echo "  '--board orangepi5/orangepi5b/orangepi5plus'"
    echo "      generates images for orange pi 5/5b/5plus (experimental)"
    exit 1;
}

err()
{
    echo "$@"
    exit 1
}

read_cmd_line() {
    while [ "$1" ]; do
       case "$1" in
           "--help"|"-h")
               usage;
               ;;
           "--src"|"-i")
               if [ "$2" ]; then
                   src="$2"
                   shift;
               else
                   err "ERROR: --src: no src specified."
               fi
               ;;
           "--target"|"-o")
               if [ "$2" ]; then
                   target="$2"
                   shift;
               else
                   err "ERROR: --target: no target specified."
               fi
               ;;
           "--skip"|"-s")
               skip="true"
               ;;
           "--inplace"|"-p")
               inplace="true"
               ;;
           "--board")
               [ -z "$2" ] && usage

               _board="$(echo "$2" | tr '[:upper:]' '[:lower:]')"

               for b in "${!BOARD_MAP[@]}"; do
                  if [ "$b" == "$_board" ]; then
                      board="$b"
                      shift
                      break
                  fi
               done

               [ -z "$board" ] && err "unsupported board: $_board"
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
}

enter_menu()
{
    while :
    do
       clear
       echo "*****************************"
       echo "* Supported boards *"
       echo "*****************************"
       echo "[1] orange pi 5"
       echo "[2] orange pi 5b"
       echo "[3] orange pi 5 plus"
       echo "[4] Quit"
       echo "-----------------------------"
       echo "Enter your choice:"

       read your_choice
       case $your_choice in
           1) board=$ORANGEPI5; break ;;
           2) board=$ORANGEPI5B; break ;;
           3) board=$ORANGEPI5PLUS; break ;;
           4) exit 0;;
           *) err "Invalid choice, please choose between 1-4"; sleep 2 ;;
       esac
    done

    [ "$board" == "ORANGEPI5B" ] && return 0

    if [ "$board" == "$ORANGEPI5" ]; then
    while :
    do
       clear
       echo "*****************************"
       echo "* Supported boot storage *"
       echo "*****************************"
       echo "[1] M.2 NVME"
       echo "[2] M.2 SATA"
       echo "[3] Quit"
       echo "-----------------------------"
       echo "Enter your choice:"

       read your_choice
       case $your_choice in
           1) m2=nvme; break ;;
           2) m2=sata; break ;;
           3) exit 0;;
           *) err "Invalid choice, please choose between 1-3"; sleep 2 ;;
       esac
    done
    fi

    if [ "$board" == "$ORANGEPI5PLUS" ]; then
    while :
    do
       clear
       echo "*****************************"
       echo "* Supported boot storage *"
       echo "*****************************"
       echo "[1] M.2 NVME"
       echo "[2] EMMC"
       echo "[3] Quit"
       echo "-----------------------------"
       echo "Enter your choice:"

       read your_choice
       case $your_choice in
           1) m2=nvme; break ;;
           2) m2=emmc; break ;;
           3) exit 0;;
           *) err "Invalid choice, please choose between 1-3"; sleep 2 ;;
       esac
    done
    fi
}

num_arg=$#

if [ "$num_arg" -eq 0 ]; then
    enter_menu
else
    read_cmd_line "$@"
fi

[ "$board" == "$ORANGEPI5B" ] && m2="emmc"

[ -z "$board" ] && err "option '--board orangepi5/orangepi5b/orangepi5plus' is required"

[ -z "$m2" ] && err "option '--boot sata/nvme/emmc' is required"

echo "*****************************"
echo "* board: $board, supported install storage: $m2 *"
echo "*****************************"

cwd="$(pwd)"

if [ -z "$target" ] && [ "$inplace" != "true" ] && [ -z "$src" ]; then
   target="$(echo "$0" | sed s/.run/.img/g)"
   echo "$target" | grep -q '.img' || target="${target}.img"
fi

if [ -f "$target" ]; then
    rm $target || err "$target already exists, please remove it first"
fi

[ -d "$target" ] && err "$target already exists, please remove it first"

command -v "tar" > /dev/null 2>&1 || err "command tar is not found"

if [ "$skip" == "false" ]; then
    cat $self | tail -n +${shell_lines} | tar xJf - -C $TMP

    if [ "$?" -ne 0 ]; then
        rm "$target"
        err "failed to uncompress image"
    fi
else
    if [ "$inplace" == "false" ]; then
        cp $src $target || err "failed to cp $src $target"
    else
        target="$src"
    fi
fi

[ "$inplace" == "false" ] && mv "$(find $TMP -maxdepth 1 -name "*.img" -or -name "*.bin" )" $target || err "failed to cp $src $target"


if [ "$m2" == "nvme" ]; then
    magic=$NVME_MAGIC
elif [ "$m2" == "emmc" ]; then
    magic=$EMMC_MAGIC
else
    magic=$SATA_MAGIC
fi

board_magic="${BOARD_MAP[$board]}"
[ -z "$board_magic" ] && err "empty board_magic for board $board"

echo "board: $board storage: $magic"

echo -n "$magic" | dd of="$target" bs=$SECTOR_SIZE seek="$MAGIC_SECTOR" conv=fdatasync,notrunc &>/dev/null
echo -n "$board_magic" | dd of="$target" bs=$SECTOR_SIZE seek="$BOARD_MAGIC_SECTOR" conv=fdatasync,notrunc &>/dev/null
echo "Generated image: $(realpath ${target})"

image_dir="${TMP}/${board}"
image="$target"

echo "Installing uboot firmware on ${image}"
dd if="${image_dir}/idbloader.img" of="$image" \
    conv=notrunc,fsync \
    seek=64 &>/dev/null || err "fail to install idbloader"

dd if="${image_dir}/u-boot.itb" of="$image" \
    conv=notrunc,fsync \
    seek=16384 &>/dev/null || err "fail to install u-boot"

echo "Installed bootloader to ${image}"

cleanup

exit 0
