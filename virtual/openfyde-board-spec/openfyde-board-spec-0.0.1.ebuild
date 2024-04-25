# Copyright (c) 2018 The Fyde OS Authors. All rights reserved.
# Distributed under the terms of the BSD

EAPI="7"

DESCRIPTION="empty project"
HOMEPAGE="http://fydeos.com"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
  virtual/fydemina
  chromeos-base/chromeos-bsp-inaugural
  chromeos-base/chromeos-bsp-inaugural-openfyde
  chromeos-base/chromeos-bsp-orangepi5-openfyde-base
"

DEPEND="${RDEPEND}"
