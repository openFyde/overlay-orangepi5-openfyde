# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Generic ebuild which satisifies virtual/chromeos-bsp-test.
This is a direct dependency of virtual/target-chromium-os-test, but is expected
to be overridden in an overlay for each specialized board.  A typical
non-generic implementation will install any board-specific test-only files and
executables which are not suitable for inclusion in a generic board
overlay."
HOMEPAGE="http://src.chromium.org"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="*"
IUSE=""
RDEPEND="chromeos-base/wifi_commandline_utils
         chromeos-base/fydeos-adbd"
DEPEND="${RDEPEND}"
