# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font

DESCRIPTION="Material Design icons by Google (Material Symbols - 4 axis variable font)"
HOMEPAGE="https://fonts.google.com/icons https://github.com/google/material-design-icons"

COMMIT="e083cc60a0828fdd3b404cea0cb8a5b900e9c23e"
SRC_URI="
	https://raw.githubusercontent.com/google/material-design-icons/${COMMIT}/variablefont/MaterialSymbolsOutlined%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf -> MaterialSymbolsOutlined.ttf
	https://raw.githubusercontent.com/google/material-design-icons/${COMMIT}/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf -> MaterialSymbolsRounded.ttf
	https://raw.githubusercontent.com/google/material-design-icons/${COMMIT}/variablefont/MaterialSymbolsSharp%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf -> MaterialSymbolsSharp.ttf
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

FONT_SUFFIX="ttf"

src_unpack() {
	mkdir -p "${S}" || die
	cp "${DISTDIR}/MaterialSymbolsOutlined.ttf" "${S}/" || die
	cp "${DISTDIR}/MaterialSymbolsRounded.ttf" "${S}/" || die
	cp "${DISTDIR}/MaterialSymbolsSharp.ttf" "${S}/" || die
}
