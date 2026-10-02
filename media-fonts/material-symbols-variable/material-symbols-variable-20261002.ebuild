# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Material Design icons by Google (Material Symbols - 4 axis variable font)"
HOMEPAGE="https://fonts.google.com/icons https://github.com/google/material-design-icons"

# snapshot of upstream master on the date in PV
COMMIT="737e3324305806514d7909874fa1818ae1808232"
SRC_URI="
	https://raw.githubusercontent.com/google/material-design-icons/${COMMIT}/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf -> ${P}-Outlined.ttf
	https://raw.githubusercontent.com/google/material-design-icons/${COMMIT}/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf -> ${P}-Rounded.ttf
	https://raw.githubusercontent.com/google/material-design-icons/${COMMIT}/variablefont/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf -> ${P}-Sharp.ttf
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

FONT_SUFFIX="ttf"

src_unpack() {
	mkdir -p "${S}" || die
	local style
	for style in Outlined Rounded Sharp; do
		cp "${DISTDIR}/${P}-${style}.ttf" "${S}/MaterialSymbols${style}.ttf" || die
	done
}
