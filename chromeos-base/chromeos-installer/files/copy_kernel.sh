#!/bin/bash
#
disk_dev=$1
EFI_NUM=12

help() {
  echo "$0 [root_partition_num] [disk_dev]"
}

die() {
  echo $@
  help
  exit 1
}

remove_old_kernel() {
  local efi_mnt=$1

  rm -f "${efi_mnt}/boot/Image"
  rm -rf "${efi_mnt}/boot/rockchip"
}

copy_kernel_to() {
  local efi_mnt=$1

  [ -f /mnt/stateful_partition/fyde/Env.txt ] && \
      cp /mnt/stateful_partition/fyde/Env.txt "${efi_mnt}/boot/"
  cp /boot/Image "${efi_mnt}/boot/Image"
  cp -r /boot/rockchip "${efi_mnt}/boot/"
}

main() {
 local disk_dev=$1
 [ -z "${disk_dev}" ] && disk_dev=$(rootdev -d)

 local tmpdir=$(mktemp -d)
 local efi_dev=""

 if [[ $disk_dev =~ [a-z]$ ]]; then
   efi_dev=${disk_dev}${EFI_NUM}
 else
   efi_dev=${disk_dev}p${EFI_NUM}
 fi

 mount $efi_dev $tmpdir || die "error mounting efi"
 remove_old_kernel $tmpdir || die "error removing old kernel"
 copy_kernel_to $tmpdir || die "error copy new kernel"

 umount $tmpdir
 rmdir $tmpdir
}

main $@
