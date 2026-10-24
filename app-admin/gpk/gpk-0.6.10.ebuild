# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# GlazePKG: the terminal package-manager dashboard Ryoku's ryoku-desktop hard-
# depends on (release/packages/gpk/PKGBUILD pins v0.6.10 and repackages the
# release binary; this builds the same tag from source instead).
inherit go-module

DESCRIPTION="GlazePKG: every package manager on the system in one searchable terminal view"
HOMEPAGE="https://github.com/neur0map/glazepkg"
SRC_URI="https://github.com/neur0map/glazepkg/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/glazepkg-${PV}"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND=">=dev-lang/go-1.25.0"

# No vendor/ tree and no dependency tarball: go-module_src_unpack fetches the
# module graph (checked against go.sum) at build time, as with app-misc/prowl.
RESTRICT="network-sandbox test"

src_compile() {
	export CGO_ENABLED=0
	export GOTOOLCHAIN=local
	export GOFLAGS+=" -mod=mod -trimpath"

	# noselfupdate: `gpk update` must not overwrite a portage-owned binary
	# (the same tag Homebrew's formula uses).
	ego build -tags noselfupdate \
		-ldflags "-X main.version=v${PV}" \
		-o gpk ./cmd/gpk
}

src_install() {
	dobin gpk
	einstalldocs
}
