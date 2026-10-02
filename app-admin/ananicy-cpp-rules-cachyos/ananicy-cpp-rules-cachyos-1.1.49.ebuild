# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="ananicy-rules"

DESCRIPTION="CachyOS ananicy-cpp rules (process nice/ionice/sched rules for ananicy-cpp)"
HOMEPAGE="https://github.com/CachyOS/ananicy-rules"
SRC_URI="https://github.com/CachyOS/${MY_PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="app-admin/ananicy-cpp"

src_compile() { :; }

src_install() {
	insinto /etc/ananicy.d
	doins 00-cgroups.cgroups 00-types.types ananicy.conf
	doins -r 00-default

	dodoc README.md
}

pkg_postinst() {
	elog "CachyOS ananicy-cpp rules installed to /etc/ananicy.d"
	elog "Enable/start with: systemctl enable --now ananicy-cpp"
}
