# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

S="${WORKDIR}/SpaceGrotesk-${PV}"
FONT_S="${S}/otf"
FONT_SUFFIX="otf"

inherit font

DESCRIPTION="Space Grotesk OTF - the Ryoku shell and Hub UI brand font"
HOMEPAGE="https://github.com/floriankarsten/space-grotesk"
SRC_URI="https://github.com/floriankarsten/space-grotesk/releases/download/${PV}/SpaceGrotesk-${PV}.zip -> ${P}.zip"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

BDEPEND="app-arch/unzip"
