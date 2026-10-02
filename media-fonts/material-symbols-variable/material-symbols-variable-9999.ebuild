# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font git-r3

DESCRIPTION="Material Design icons by Google (Material Symbols - 4 axis variable font)"
HOMEPAGE="https://fonts.google.com/icons https://github.com/google/material-design-icons"
EGIT_REPO_URI="https://github.com/google/material-design-icons.git"
EGIT_CLONE_TYPE="single"

LICENSE="Apache-2.0"
SLOT="0"

FONT_SUFFIX="ttf"
FONT_S="${S}/variablefont"

src_unpack() {
	git-r3_src_unpack
}

src_install() {
	font_src_install
}
