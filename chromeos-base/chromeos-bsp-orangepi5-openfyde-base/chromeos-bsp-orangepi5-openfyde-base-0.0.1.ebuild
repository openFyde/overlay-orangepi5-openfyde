# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="7"

inherit udev user

DESCRIPTION="empty project"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="chromeos-base/chromeos-base"

RDEPEND="
    sys-kernel/armbian-firmware
    sys-boot/orangepi5-loaders
    chromeos-base/os_install_service
    chromeos-base/fake-camera-config
    app-misc/brcm_patchram_plus
    chromeos-base/workaround-for-8852be
    chromeos-base/fydeos-power-daemon-go
"

DEPEND="${RDEPEND}"

S="${FILESDIR}"

src_install() {
    insinto "/etc/init"
    doins init/*conf

    exeinto "/usr/sbin"
    doexe scripts/*.sh

    exeinto "/usr/share/orange"
    doexe scripts/common.sh

    insinto /lib/udev/rules.d
    doins  udev/99-tun.rules

    insinto "/lib/firmware"
    doins firmware/*

    insinto /etc/powerd/board
    doins board/*
}
