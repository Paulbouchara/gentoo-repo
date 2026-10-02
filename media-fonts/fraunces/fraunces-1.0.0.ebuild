# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Fraunces: A vintage-inspired variable serif typeface with display axes"
HOMEPAGE="https://github.com/undercasetype/Fraunces"
# upstream tags font versions as M.mmm: 1.000 = 1.0.0, 1.001 = 1.0.1
MY_PV="$(ver_cut 1).$(ver_cut 2)0$(ver_cut 3)"
SRC_URI="https://github.com/undercasetype/Fraunces/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Fraunces-${MY_PV}"

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
