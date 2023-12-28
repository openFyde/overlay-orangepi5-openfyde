# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="5"

inherit udev user

DESCRIPTION="empty project"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
    sys-kernel/armbian-firmware
    sys-boot/orangepi5-loaders
    chromeos-base/os_install_service
    app-misc/brcm_patchram_plus
"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
    insinto "/etc/init"
    doins ${FILESDIR}/init/*conf

    exeinto "/usr/sbin"
    doexe ${FILESDIR}/scripts/*.sh

    exeinto "/usr/share/orange"
    doexe ${FILESDIR}/scripts/common.sh
}
