# Copyright (c) 2025 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="7"

inherit linux-info linux-mod

DESCRIPTION="BCMDHD sdio/pcie WiFi kernel drivers"
HOMEPAGE="https://github.com/armbian/bcmdhd-dkms/"
SRC_URI="https://github.com/armbian/bcmdhd-dkms/archive/refs/tags/101.10.591.52.27-5.tar.gz"

LICENSE="GPL-2"
KEYWORDS="amd64 arm64"

IUSE=""
RDEPEND="virtual/linux-sources"
DEPEND="${RDEPEND}"
S="${WORKDIR}/bcmdhd-dkms-101.10.591.52.27-5/src"

MODULE_NAMES=""
MODULE_VARIANTS=(sdio pcie)

pkg_setup() {
  export KERNEL_DIR="/mnt/host/source/src/third_party/kernel/v6.1-rockchip"
  export KBUILD_OUTPUT=${ROOT}/usr/src/linux
  linux-mod_pkg_setup
}

src_compile() {
  cros_allow_gnu_build_tools
  for variant in "${MODULE_VARIANTS[@]}"; do
    einfo "Compiling variant: ${variant} ..."
    emake CROSS_COMPILE=${CHOST}- bcmdhd_${variant} \
      || die "Failed to compile module variant: ${variant}"
  done
}

src_install() {
  insinto /lib/modules/${KV_FULL}/kernel/drivers/net/wireless/bcmdhd
  doins *.ko || die "doins modules failed"
}

PATCHES=(
  "${FILESDIR}/01-fix-for-chromium-os.patch"
)
