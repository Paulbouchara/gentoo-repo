# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1

DESCRIPTION="The main CLI for the Caelestia dotfiles and desktop shell"
HOMEPAGE="https://github.com/caelestia-dots/cli"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/caelestia-dots/cli.git"
else
	SRC_URI="https://github.com/caelestia-dots/cli/releases/download/v${PV}/caelestia-${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/caelestia-${PV}"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="GPL-3"
SLOT="0"

RDEPEND="
	dev-python/pillow[${PYTHON_USEDEP}]
	dev-python/materialyoucolor[${PYTHON_USEDEP}]
	gui-apps/grim
	gui-apps/slurp
	gui-apps/swappy
	gui-apps/fuzzel
	gui-apps/wl-clipboard
	app-misc/cliphist
	x11-libs/libnotify
"
BDEPEND="
	dev-python/hatch-vcs[${PYTHON_USEDEP}]
"

python_install_all() {
	distutils-r1_python_install_all
	if [[ -f completions/caelestia.fish ]]; then
		insinto /usr/share/fish/vendor_completions.d
		doins completions/caelestia.fish
	fi
}
