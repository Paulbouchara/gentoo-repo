# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit font git-r3

DESCRIPTION="Space Grotesk OTF - the Ryoku shell and Hub UI brand font"
HOMEPAGE="https://github.com/floriankarsten/space-grotesk"
EGIT_REPO_URI="https://github.com/floriankarsten/space-grotesk.git"

LICENSE="OFL-1.1"
SLOT="0"

FONT_SUFFIX="otf"

src_install() {
	if [[ -d "${S}/fonts/otf" ]]; then
		FONT_S="${S}/fonts/otf"
	elif [[ -d "${S}/otf" ]]; then
		FONT_S="${S}/otf"
	fi
	font_src_install
}
