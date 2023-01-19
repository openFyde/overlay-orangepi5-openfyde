#!/bin/sh

LOADER_DIR=/usr/share/orangepi5

main() {
 local target="$1"
 local type="$2"
 local loader=""

 if [ "$type" = 'SATA' ]; then
    loader="${LOADER_DIR}/rkspi_loader_sata.img"
 else
    loader="${LOADER_DIR}/rkspi_loader.img"
 fi

 echo "installing $loader to $target"
 dd if=$loader of=$target status=progress bs=1024 conv=fdatasync
 echo "done"
}

main "$@"
