# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.98.0"

inherit cargo git-r3

DESCRIPTION="Xbox GDK and Game Pass compatibility layer for Linux"
HOMEPAGE="https://github.com/xodus-gaming/xodus"
EGIT_REPO_URI="https://github.com/xodus-gaming/xodus.git"

LICENSE="GPL-3+"
SLOT="0"

RDEPEND="
	dev-libs/glib:2
	dev-libs/openssl:=
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-build/cmake
	dev-libs/protobuf[protoc(+)]
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-run-exe-match.patch
)

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_install() {
	dobin "$(cargo_target_dir)"/xodus-{cli,service}
	dodoc README.md
	dodoc -r docs/.
}
