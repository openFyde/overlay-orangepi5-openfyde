# Copyright (c) 2025 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="7"

inherit gcc-linux-mod

DESCRIPTION="BCMDHD sdio/pcie WiFi kernel drivers"
HOMEPAGE="https://github.com/armbian/bcmdhd-dkms/"
SRC_URI="https://github.com/armbian/bcmdhd-dkms/archive/refs/tags/101.10.591.52.27-5.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64"

IUSE=""
RDEPEND=""
DEPEND="${RDEPEND}"

USER_KERNEL_SRC="/mnt/host/source/src/third_party/kernel/v6.1-rockchip"
S="${WORKDIR}/bcmdhd-dkms-101.10.591.52.27-5/src"

MODULE_NAMES=""
MODULE_VARIANTS=(
  "sdio:CONFIG_BCMDHD_SDIO=y CONFIG_BCMDHD_PCIE="
  "pcie:CONFIG_BCMDHD_PCIE=y CONFIG_BCMDHD_SDIO="
)

src_compile() {
  cros_allow_gnu_build_tools
  for variant_info in "${MODULE_VARIANTS[@]}"; do
    local suffix="${variant_info%%:*}"
    local kconfig_flags="${variant_info#*:}"

    einfo "Compiling variant: ${suffix} with flags: ${kconfig_flags}"
    eval "emake HOSTCC=\"$(tc-getBUILD_CC)\" \
			CROSS_COMPILE=${CHOST}- \
			LDFLAGS=\"$(get_abi_LDFLAGS)\" \
			${BUILD_FIXES} \
			${BUILD_PARAMS} \
			${kconfig_flags} \
			${BUILD_TARGETS} " \
         || die "Unable to emake HOSTCC="$(tc-getBUILD_CC)" CROSS_COMPILE=${CHOST}- LDFLAGS="$(get_abi_LDFLAGS)" ${BUILD_FIXES} ${BUILD_PARAMS} ${BUILD_TARGETS}"
done

  umount_kernel
}

src_install() {
  insinto /lib/modules/${KV_FULL}/kernel/extra/bcmdhd
  doins *.ko || die "doins modules failed"
}

PATCHES=(
  "${FILESDIR}/01-fix-for-chromium-os.patch"
)
