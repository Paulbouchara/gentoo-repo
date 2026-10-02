# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Fraunces: A vintage-inspired variable serif typeface with display axes"
HOMEPAGE="https://fraunces.undercasetype.com/ https://github.com/undercasetype/Fraunces"
SRC_URI="https://github.com/undercasetype/Fraunces/archive/refs/tags/1.000.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/Fraunces-1.000"

LICENSE="OFL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

FONT_SUFFIX="ttf"
FONT_S="${S}/fonts/variable"

src_unpack() {
	default
	# Use compiled variable font instances
	if [[ ! -d "${S}/fonts/variable" ]]; then
		mkdir -p "${S}/fonts/variable" || die
		find "${S}/documentation" -name "Fraunces*-VF.ttf" -exec cp {} "${S}/fonts/variable/" \;
	fi
}

src_compile() {
	:
}

