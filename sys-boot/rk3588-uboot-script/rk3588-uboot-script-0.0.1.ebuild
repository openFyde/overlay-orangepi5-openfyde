# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"

DESCRIPTION="empty project"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}
  virtual/linux-sources
"

S=${WORKDIR}

src_compile() {
  if [ -z "${ROCKCHIP_DTS}" ]; then
    die "Need set ROCKCHIP_DTS in make.conf"
  fi
  cat ${FILESDIR}/boot.cmd | sed -e "s/#ROCKCHIP_DTS#/${ROCKCHIP_DTS}/g" > boot.cmd
  mkimage -A arm -O linux -T script -C none -a 0 -e 0 \
    -n "boot" -d boot.cmd boot.scr.uimg || die
}

src_install() {
  insinto /boot
  doins boot.scr.uimg
}
