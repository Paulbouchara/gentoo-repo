# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Upstream renamed prowl-agent to prowl (binary cmd/prowl, `replaces=prowl-agent`
# in release/packages/prowl/PKGBUILD) and ryoku-rashin now depends on `prowl`.
# Ryoku pins a commit; at ryoku v1.0.1 that commit (5ba05eb) is the v0.17.2 tag,
# so this tracks the tag. app-misc/prowl-agent shares no files and can stay
# installed until you remove it.
inherit go-module

COMMIT="5ba05eb922ff023e3cbc2b9a3768829179bca980"

DESCRIPTION="Prowl: model gateway and code-intelligence indexer for the Ryoku agent OS"
HOMEPAGE="https://github.com/neur0map/prowl"
SRC_URI="https://github.com/neur0map/prowl/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

# MIT: upstream's LICENSE. The rest are the Go modules linked into the binary:
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

	# main.managedBy=portage: flips prowl's self-update guard so a hand-run
	# `prowl update` defers to the package manager instead of overwriting a
	# portage-owned binary (Arch's build stamps "pacman").
	ego build -tags sqlite_fts5 \
		-ldflags "-X main.version=v${PV} -X main.commit=${COMMIT} -X main.managedBy=portage" \
		-o prowl ./cmd/prowl
}

src_install() {
	dobin prowl
	dodoc NOTICE.md
	einstalldocs
}
