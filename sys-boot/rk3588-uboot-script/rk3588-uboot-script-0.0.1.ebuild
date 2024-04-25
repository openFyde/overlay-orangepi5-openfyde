# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="7"

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
  cp ${FILESDIR}/boot.cmd boot.cmd
  mkimage -A arm -O linux -T script -C none -a 0 -e 0 \
    -n "boot" -d boot.cmd boot.scr.uimg || die
}

src_install() {
  insinto /boot
  doins boot.scr.uimg
}
