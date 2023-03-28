#!/bin/bash

skip_blacklist_check=1
skip_test_image_content=1

image_dir="${ROOT}/usr/share/orangepi5"
install_bootloader() {
  local image="$1"

  info "Installing uboot firmware on ${image}"
  dd if="${image_dir}/idbloader.img" of="$image" \
    conv=notrunc,fsync \
    seek=64 || die "fail to install idbloader"
  dd if="${image_dir}/u-boot.itb" of="$image" \
    conv=notrunc,fsync \
    seek=16384 || die "fail to install u-boot"
  info "Installed bootloader to ${image}."
}

install_boot_scr() {
  local image="$1"
  local efi_offset_sectors=$(partoffset "$1" 12)
  local efi_size_sectors=$(partsize "$1" 12)
  local efi_offset=$((efi_offset_sectors * 512))
  local efi_size=$((efi_size_sectors * 512))
  local efi_dir=$(mktemp -d)

  info "Mounting EFI partition"
  sudo mount -o loop,offset=${efi_offset},sizelimit=${efi_size} "$1" \
    "${efi_dir}"

  info "Copying /boot/boot.scr.uimg"
  [ -d "${efi_dir}/boot" ] || sudo mkdir "${efi_dir}/boot"
  sudo cp "${ROOT}/boot/boot.scr.uimg" "${efi_dir}/boot/"
  sudo umount "${efi_dir}"
  rmdir "${efi_dir}"

  info "Installed /efi/boot.scr.uimg"
}

board_setup() {
  install_bootloader "$1"
  install_boot_scr "$1"
}
