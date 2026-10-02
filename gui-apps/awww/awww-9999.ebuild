# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES=""

inherit cargo

DESCRIPTION="Efficient animated wallpaper daemon for Wayland"
HOMEPAGE="https://codeberg.org/LGFae/awww"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://codeberg.org/LGFae/awww.git"
else
	SRC_URI="https://codeberg.org/LGFae/awww/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/awww"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="GPL-3+"
SLOT="0"

RDEPEND="
	app-arch/lz4:=
"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
"

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
		cargo_live_src_unpack
	else
		cargo_src_unpack
	fi
}

src_install() {
	cargo_src_install
	if [[ -d completions ]]; then
		[[ -f completions/awww.bash ]] && newbashcomp completions/awww.bash awww
		[[ -f completions/awww.fish ]] && dofishcomp completions/awww.fish
		[[ -f completions/_awww ]] && dozshcomp completions/_awww
	fi
	einstalldocs
}
