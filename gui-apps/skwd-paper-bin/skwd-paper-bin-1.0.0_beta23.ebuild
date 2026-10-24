# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# skwd-paper: the still/video/Wallpaper Engine renderer Ryogami drives
# (release/packages/skwd-paper-bin/PKGBUILD in Ryoku, pinned to the same
# release). Upstream (liixini/skwd-wall, Rust) ships only this prebuilt Arch
# package, FFmpeg 9.0.1 bundled privately in /usr/lib/skwd-paper (see
# share/licenses/skwd-paper/ffmpeg/SOURCE); unpacked by hand like the PKGBUILD.

MY_TAG="v${PV/_beta/-beta.}"
MY_ASSET="skwd-paper-${PV/_beta/_beta.}-1-x86_64.pkg.tar.zst"

DESCRIPTION="skwd-paper: still, video and Wallpaper Engine wallpaper renderers (prebuilt)"
HOMEPAGE="https://github.com/liixini/skwd-wall"
SRC_URI="https://github.com/liixini/skwd-wall/releases/download/${MY_TAG}/${MY_ASSET} -> ${P}.pkg.tar.zst"
S="${WORKDIR}"

# skwd-wall is GPL-3.0-or-later (see its LICENSE); the bundled FFmpeg is LGPL.
LICENSE="GPL-3+ LGPL-2.1+"
SLOT="0"
KEYWORDS="-* ~amd64"

# Runtime libraries of the prebuilt binaries (upstream .PKGINFO); FFmpeg itself
# ships privately. media-libs/dav1d must provide libdav1d.so.7.
RDEPEND="
	media-libs/alsa-lib
	media-libs/dav1d
	media-libs/libglvnd
	media-libs/libpulse
	media-libs/libva
	media-libs/libyuv
	media-libs/shaderc
	media-libs/vulkan-loader
	dev-libs/wayland
	sys-libs/zlib
	x11-libs/libdrm
	x11-libs/libxkbcommon
"
BDEPEND="app-arch/zstd"

RESTRICT="strip"
QA_PREBUILT="usr/bin/* usr/lib/skwd-paper/*"
# the binaries find their private FFmpeg via $ORIGIN/../lib/skwd-paper
QA_MULTILIB_PATHS="usr/lib/skwd-paper/.*"

src_unpack() {
	# a pacman package: take usr/ only, never .PKGINFO/.MTREE/.BUILDINFO
	# (stdin, not a path: zstd refuses the symlinked DISTDIR entry)
	zstd -dc < "${DISTDIR}/${P}.pkg.tar.zst" | tar -x -C "${WORKDIR}" usr \
		|| die "unpacking the upstream package failed"
}

src_install() {
	dobin usr/bin/*

	exeinto /usr/lib/skwd-paper
	doexe usr/lib/skwd-paper/skwd-paper-tinier
	local lib
	for lib in usr/lib/skwd-paper/*.so*; do
		if [[ -L ${lib} ]]; then
			dosym "$(readlink "${lib}")" "/usr/lib/skwd-paper/${lib##*/}"
		else
			exeinto /usr/lib/skwd-paper
			doexe "${lib}"
		fi
	done

	insinto /usr/share/licenses/skwd-paper
	doins -r usr/share/licenses/skwd-paper/.
}
