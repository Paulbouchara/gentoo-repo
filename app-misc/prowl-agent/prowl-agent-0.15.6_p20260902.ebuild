# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Ryoku pins prowl-agent to a commit, not a release tag
# (release/packages/prowl-agent/PKGBUILD, identical at ryoku v0.75.3-beta.20
# and HEAD: _commit=506e54fb, pkgver=0.15.6). That commit is the v0.15.6 tag
# plus the managed-binary update guard (main.managedBy) and a docs commit; no
# tag points at it (it is an ancestor of v0.15.7), hence a 0.15.6 post-release
# snapshot. ryoku-rashin drives this exact build, so track Ryoku's pin rather
# than the newest prowl release (v0.16.x).
inherit go-module

COMMIT="506e54fb7b049ceea556255205f8acd3ee20ac9e"

DESCRIPTION="Prowl: code-intelligence indexer and MCP server for the Ryoku agent OS"
HOMEPAGE="https://github.com/neur0map/prowl"
SRC_URI="https://github.com/neur0map/prowl/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/prowl-${COMMIT}"

# MIT: upstream's LICENSE (added 2026-09-21 in 1c37ad6, first released in
# v0.16.1; the pinned snapshot predates the file and states no other licence).
# The rest are the Go modules linked into the binary (`go version -m`):
#   Apache-2.0    spf13/cobra, modelcontextprotocol/go-sdk (+MIT),
#                 gopkg.in/yaml.v3 (+MIT), sqlite-vec bindings (MIT or Apache)
#   BSD           golang.org/x/*, spf13/pflag, fsnotify, gofrs/flock,
#                 atotto/clipboard, yosida95/uritemplate
#   public-domain the SQLite amalgamation in mattn/go-sqlite3
# everything else (charm.land/*, go-sitter-forest grammars, tree-sitter,
# mattn/go-sqlite3, ...) is MIT.
LICENSE="MIT Apache-2.0 BSD public-domain"
SLOT="0"
KEYWORDS="~amd64"

# cgo (sqlite_fts5, mattn/go-sqlite3's bundled amalgamation) - gcc does the
# linking, no external sqlite lib needed at build or run time.
BDEPEND=">=dev-lang/go-1.26.4"

# Upstream carries no vendor/ tree and Gentoo has no dependency tarball for
# it, so go-module_src_unpack's `ego mod verify` fetches the module graph
# (checked against go.sum) at build time, same as the Arch PKGBUILD. Fine for
# this personal overlay; a hosted deps tarball would be the clean fix.
# The test suite is not wired up (the PKGBUILD runs none either).
RESTRICT="network-sandbox test"

src_compile() {
	export CGO_ENABLED=1
	export GOTOOLCHAIN=local
	# append: keep go-env's -buildmode=pie -modcacherw -buildvcs=false.
	export GOFLAGS+=" -mod=mod -trimpath"

	# main.managedBy=portage (Arch's build stamps "pacman"; that flag flips
	# prowl-agent's self-update guard so a hand-run `prowl-agent update` defers
	# to the package manager instead of overwriting a portage-owned binary).
	# main.version mirrors the PKGBUILD's v$pkgver (= the snapshot's base tag).
	ego build -tags sqlite_fts5 \
		-ldflags "-X main.version=v$(ver_cut 1-3) -X main.managedBy=portage" \
		-o prowl-agent ./cmd/prowl-agent
}

src_install() {
	dobin prowl-agent
	einstalldocs
}
