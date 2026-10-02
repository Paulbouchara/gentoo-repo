# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Same commit Ryoku's own PKGBUILD (release/packages/prowl-agent) pins, mirrored
# here since Gentoo has no package for it (ryoku-desktop-9999's README says so).
inherit go-module git-r3

DESCRIPTION="Prowl: code-intelligence indexer and MCP server for the Ryoku agent OS"
HOMEPAGE="https://github.com/neur0map/prowl-agent"
EGIT_REPO_URI="https://github.com/neur0map/prowl-agent.git"
EGIT_COMMIT="506e54fb7b049ceea556255205f8acd3ee20ac9e"

LICENSE="custom"
SLOT="0"
KEYWORDS="~amd64"

# cgo (sqlite_fts5, mattn/go-sqlite3's bundled amalgamation) - gcc does the
# linking, no external sqlite lib needed at build or run time.
BDEPEND="virtual/pkgconfig >=dev-lang/go-1.26.4"

# Upstream carries no vendor/ tree (unlike the ryoku-desktop monorepo), so the
# module graph has to be fetched at build time same as the Arch PKGBUILD does.
RESTRICT="test network-sandbox"

src_unpack() {
	git-r3_src_unpack
}

src_compile() {
	go-module_src_configure
	export CGO_ENABLED=1
	export GOFLAGS="-mod=mod -trimpath"
	export GOTOOLCHAIN=local

	pushd cmd/prowl-agent >/dev/null || die
	# main.managedBy=portage (Arch's build stamps "pacman"; that flag flips
	# prowl-agent's self-update guard so a hand-run `prowl-agent update` defers
	# to the package manager instead of overwriting a portage-owned binary).
	ego build -tags sqlite_fts5 \
		-ldflags "-s -w -X main.version=v0.15.6 -X main.managedBy=portage" \
		-o "${T}/prowl-agent" . || die "go build failed"
	popd >/dev/null || die
}

src_install() {
	dobin "${T}/prowl-agent"
}
