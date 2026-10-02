# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Desktop shell for the Caelestia dotfiles and Hyprland"
HOMEPAGE="https://github.com/caelestia-dots/shell"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/caelestia-dots/shell.git"
else
	SRC_URI="https://github.com/caelestia-dots/shell/releases/download/v${PV}/${PN}-v${PV}.tar.gz -> ${P}.tar.gz"
	S="${WORKDIR}/release"
	KEYWORDS="~amd64 ~arm64"
fi

LICENSE="GPL-3"
SLOT="0"
RESTRICT="network-sandbox"

RDEPEND="
	gui-apps/caelestia-cli
	gui-apps/quickshell
	app-misc/brightnessctl
	media-sound/libcava
	media-libs/aubio
	media-video/pipewire
	sci-libs/libqalculate
	sys-apps/lm-sensors
	dev-qt/qtbase:6
	dev-qt/qtdeclarative:6
	dev-qt/qtimageformats:6
	dev-qt/qtsvg:6
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-qt/qtshadertools:6
	dev-vcs/git
	virtual/pkgconfig
"

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
}

src_configure() {
	local mycmakeargs=(
		-DVERSION="${PV}"
		-DGIT_REVISION="${PV}"
		-DDISTRIBUTOR="Gentoo (gentoo-overlay)"
		-DENABLE_MODULES="extras;plugin;shell;m3shapes"
		-DINSTALL_LIBDIR="${EPREFIX}/usr/$(get_libdir)/caelestia"
		-DINSTALL_QMLDIR="${EPREFIX}/usr/$(get_libdir)/qt6/qml"
		-DINSTALL_QSCONFDIR="${EPREFIX}/usr/share/quickshell/caelestia"
	)
	cmake_src_configure
}
