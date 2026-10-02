# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

RUST_MIN_VER="1.88.0"

inherit cargo git-r3

DESCRIPTION="Xbox GDK and Game Pass compatibility layer for Linux"
HOMEPAGE="https://github.com/xodus-gaming/xodus"
EGIT_REPO_URI="https://github.com/xodus-gaming/xodus.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS=""

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
	virtual/pkgconfig
"

src_prepare() {
	sed -i 's/return ExitCode::SUCCESS;/continue;/' crates/xodus-cli/src/commands/download.rs || die
	sed -i '/println!("ContentID: {content_id}");/i \    if dry_run { return ExitCode::SUCCESS; }' crates/xodus-cli/src/commands/download.rs || die
	sed -i 's/if exe == fd.0 {/if exe.trim_start_matches('\''\\\\'\'').eq_ignore_ascii_case(fd.0.trim_start_matches('\''\\\\'\'')) {/' crates/xodus-cli/src/commands/run.rs || die
	default
}

src_unpack() {
	git-r3_src_unpack
	cargo_live_src_unpack
}

src_install() {
	dobin target/release/xodus-cli target/release/xodus-service
	dodoc README.md
	if [[ -d docs ]]; then
		dodoc -r docs/*
	fi
}
