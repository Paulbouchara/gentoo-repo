# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake optfeature

# Since v2.4.0 the shell no longer fetches the M3Shapes QML module with
# FetchContent; upstream expects it to be installed separately (qt6-m3shapes-git).
# It is not packaged anywhere, so build the commit pinned in upstream's flake.nix.
M3SHAPES_COMMIT="32ad9ce328bb77ed349b40a3be10ee9ea610b8ab"

DESCRIPTION="Desktop shell for the Caelestia dotfiles and Hyprland"
HOMEPAGE="https://github.com/caelestia-dots/shell"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/caelestia-dots/shell.git"
else
	SRC_URI="https://github.com/caelestia-dots/shell/releases/download/v${PV}/${PN}-v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/${PN}-v${PV}"
	KEYWORDS="~amd64 ~arm64"
fi
SRC_URI+="
	https://github.com/soramanew/m3shapes/archive/${M3SHAPES_COMMIT}.tar.gz
		-> m3shapes-${M3SHAPES_COMMIT}.tar.gz
"

# GPL-3: shell, Apache-2.0: bundled M3Shapes, OFL-1.1: bundled Google Sans Flex
LICENSE="GPL-3 Apache-2.0 OFL-1.1"
SLOT="0"

COMMON_DEPEND="
	dev-qt/qtbase:6[concurrent,dbus,gui,network,sql]
	dev-qt/qtdeclarative:6
	media-libs/aubio
	media-sound/libcava
	media-video/pipewire:=
	sci-libs/libqalculate:=
	sys-apps/lm-sensors:=
"
RDEPEND="${COMMON_DEPEND}
	app-misc/brightnessctl
	app-misc/ddcutil
	app-shells/fish
	dev-qt/qtbase:6[sqlite]
	dev-qt/qtimageformats:6
	dev-qt/qtsvg:6
	gui-apps/caelestia-cli
	gui-apps/quickshell
	media-fonts/material-symbols-variable
	net-misc/networkmanager
	x11-misc/xkeyboard-config
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	dev-qt/qtshadertools:6
	virtual/pkgconfig
"

# Run a cmake.eclass function against the bundled M3Shapes sources
_m3shapes() {
	local CMAKE_USE_DIR="${WORKDIR}/m3shapes-${M3SHAPES_COMMIT}"
	local BUILD_DIR="${CMAKE_USE_DIR}_build"
	"$@"
}

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		git-r3_src_unpack
	fi
	default
}

src_prepare() {
	cat > plugin/src/caelestia-pch.hpp <<-'EOF'
	#pragma once
	#include <qobject.h>
	#include <qqmlintegration.h>
	#include <qstring.h>
	#include <qqmlengine.h>
	#include <qjsengine.h>
	#include <qloggingcategory.h>
	#include <qvariant.h>
	#include <qtimer.h>
	#include <qdir.h>
	#include <qlist.h>
	#include <qstringlist.h>
	#include <qpointer.h>
	EOF

	cat > plugin/cmake/pch.cmake <<-'EOF'
	add_library(caelestia-pch INTERFACE)
	target_compile_options(caelestia-pch INTERFACE "-include" "${CMAKE_CURRENT_LIST_DIR}/../src/caelestia-pch.hpp")
	EOF

	cmake_src_prepare
	_m3shapes cmake_prepare
}

src_configure() {
	local mycmakeargs=(
		-DINSTALL_QMLDIR="${EPREFIX}/usr/$(get_libdir)/qt6/qml"
		# the QML plugin loads its backing library from the same directory
		-DCMAKE_INSTALL_RPATH='$ORIGIN'
	)
	_m3shapes cmake_src_configure

	mycmakeargs=(
		-DVERSION="${PV}"
		-DGIT_REVISION="${PV}"
		-DDISTRIBUTOR="Gentoo (gentoo-overlay)"
		-DENABLE_MODULES="extras;plugin;shell"
		# caelestia-cli runs /usr/lib/caelestia/version and the shell
		# defaults CAELESTIA_LIB_DIR to /usr/lib/caelestia
		-DINSTALL_LIBDIR="${EPREFIX}/usr/lib/caelestia"
		-DINSTALL_QMLDIR="${EPREFIX}/usr/$(get_libdir)/qt6/qml"
		-DINSTALL_QSCONFDIR="${EPREFIX}/usr/share/quickshell/caelestia"
	)
	cmake_src_configure
}

src_compile() {
	_m3shapes cmake_src_compile
	cmake_src_compile
}

src_install() {
	DESTDIR="${D}" _m3shapes cmake_build install
	cmake_src_install

	# Quickshell only looks up named configs (qs -c caelestia) under the XDG
	# config dirs; keep the QML tree out of CONFIG_PROTECT and link it there.
	dosym -r /usr/share/quickshell/caelestia /etc/xdg/quickshell/caelestia
}

pkg_postinst() {
	optfeature "power profile switching in the battery popout" sys-power/power-profiles-daemon
	optfeature "the default monospace font (CaskaydiaCove Nerd Font)" "media-fonts/nerdfonts[cascadiacode]"
}
