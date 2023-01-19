#!/bin/bash
#

script="orangepi5_release.sh"

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

src=$1
target=$2

[ -z "$src" ] && usage
[ -z "$target" ] && usage


[ ! -f "$src" ] && err "src image not found"
[ ! -f "$script" ] && err "$script not found"

[ -f $target ] && rm $target

echo "compressing image"
xz -fk "$src"

cat "$script" > "$target"
cat ${src}.xz >> "$target"

chmod +x "$target"
echo "Generated $target"
