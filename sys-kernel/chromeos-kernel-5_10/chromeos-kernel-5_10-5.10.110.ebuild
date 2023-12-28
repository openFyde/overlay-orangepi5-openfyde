# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
# CROS_WORKON_REPO is internal git url example: http://git.xxxx/repo
CROS_WORKON_REPO="https://github.com/orangepi-xunlong"
# CROS_WORKON_COMMIT is internel kernel commit
CROS_WORKON_COMMIT="7639c684a04b6f0ad068400da05d6c2ed2b7f18e"

CROS_WORKON_PROJECT="linux-orangepi"
# clone the kernel resource to ~/trunk/src/third_party/kernel/v5.10-rockchip to speed up the compiling.
CROS_WORKON_LOCALNAME="kernel/v5.10-rockchip"
CROS_WORKON_EGIT_BRANCH="orange-pi-5.10-rk3588"
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_MANUAL_UPREV=1
#ECLASS_DEBUG_OUTPUT="on"
EGIT_MASTER="orange-pi-5.10-rk3588"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

HOMEPAGE="https://www.chromium.org/chromium-os/chromiumos-design-docs/chromium-os-kernel"
DESCRIPTION="Chromium OS Linux kernel 5.10 for rockchip"
KEYWORDS="*"

# Change the following (commented out) number to the next prime number
# when you change "cros-kernel2.eclass" to work around http://crbug.com/220902
#
# NOTE: There's nothing magic keeping this number prime but you just need to
# make _any_ change to this file.  ...so why not keep it prime?
#
# Don't forget to update the comment in _all_ chromeos-kernel-x_x-9999.ebuild
# files (!!!)
#
# The coolest prime number is: 149
