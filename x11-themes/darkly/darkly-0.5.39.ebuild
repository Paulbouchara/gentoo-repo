# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Modern Qt application style (Lightly/Breeze fork) with translucency support"
HOMEPAGE="https://github.com/Bali10050/Darkly"
SRC_URI="https://github.com/Bali10050/Darkly/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/Darkly-${PV}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-qt/qtbase:6=[dbus,gui,widgets]
	dev-qt/qtdeclarative:6
	kde-frameworks/frameworkintegration:6
	kde-frameworks/kcmutils:6
	kde-frameworks/kcolorscheme:6
	kde-frameworks/kconfig:6
	kde-frameworks/kcoreaddons:6
	kde-frameworks/kguiaddons:6
	kde-frameworks/ki18n:6
	kde-frameworks/kiconthemes:6
	kde-frameworks/kirigami:6
	kde-frameworks/kwindowsystem:6
"
RDEPEND="${DEPEND}"
BDEPEND="kde-frameworks/extra-cmake-modules:0"

src_configure() {
	# Qt6 style only: Klassy provides the window decoration
	local mycmakeargs=(
		-DBUILD_QT5=OFF
		-DBUILD_QT6=ON
		-DWITH_DECORATIONS=OFF
		-DBUILD_TESTING=OFF
	)
	cmake_src_configure
}
