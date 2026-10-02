# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font git-r3

DESCRIPTION="Fraunces: A vintage-inspired variable serif typeface with display axes"
HOMEPAGE="https://github.com/undercasetype/Fraunces"
EGIT_REPO_URI="https://github.com/undercasetype/Fraunces.git"

LICENSE="OFL-1.1"
SLOT="0"

FONT_SUFFIX="ttf"
FONT_S="${S}/fonts/variable"

src_unpack() {
	git-r3_src_unpack
	# Use compiled variable font instances
	if [[ ! -d "${S}/fonts/variable" ]]; then
		mkdir -p "${S}/fonts/variable" || die
		find "${S}/documentation" -name "Fraunces*-VF.ttf" -exec cp {} "${S}/fonts/variable/" \;
	fi
}

src_compile() {
	:
}
