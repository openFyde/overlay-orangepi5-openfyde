#!/bin/bash
LINKFILE=fydeos_raw_image.img

base_dir=$(dirname $(realpath $0))
loaders_dir="$base_dir/../sys-boot/orangepi5-loaders/files"
script="orangepi5_release.sh"

src=$1
target=$2

usage()
{
    echo "usage: $0 chromiumos_image target"
    exit 1
}

err()
{
    echo "$1"
    exit 2
}

create_link() {
  mkdir -p out
  target=out/$(basename $target)
  if [ -f $target ]; then
    rm $target
  fi
  ln -sf $src $LINKFILE
}

clean_tmp() {
  rm ${LINKFILE}.tar.xz $LINKFILE 2>/dev/null
}

trap clean_tmp EXIT

[ -z "$src" ] && usage
[ -z "$target" ] && usage


[ ! -f "$src" ] && err "src image not found"
[ ! -f "$script" ] && err "$script not found"

[ -f $target ] && rm $target

echo "compressing image"
create_link
XZ_OPT='-T0 -9' tar cJh --checkpoint=20000 -f "${LINKFILE}.tar.xz" $LINKFILE -C $loaders_dir .

cat "$script" > "$target"
cat ${LINKFILE}.tar.xz >> "$target"

chmod +x "$target"
echo "Generated $target"
