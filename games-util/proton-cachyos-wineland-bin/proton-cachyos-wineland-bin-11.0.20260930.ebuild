# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_VER="11.0"
MY_REL="${PV#${MY_VER}.}"
MY_PV="${MY_VER}-${MY_REL}"
MY_P="proton-wineland-${MY_PV}"
TAG="wineland-${MY_PV}"

DESCRIPTION="Proton-CachyOS Wineland: Wayland-native Proton build with launcher fixes"
HOMEPAGE="https://github.com/nanomatters/proton-cachyos"

SRC_URI="
	cpu_flags_x86_avx2? (
		https://github.com/nanomatters/proton-cachyos/releases/download/${TAG}/${MY_P}-x86_64_v3.tar.xz
	)
	!cpu_flags_x86_avx2? (
		https://github.com/nanomatters/proton-cachyos/releases/download/${TAG}/${MY_P}-x86_64.tar.xz
	)
"

LICENSE="BSD BSD-2 GPL-2 GPL-3 LGPL-2.1+ MIT MPL-2.0"
SLOT="${PV}"
KEYWORDS="~amd64"
IUSE="cpu_flags_x86_avx2"

RESTRICT="binchecks strip test"
QA_PREBUILT="usr/share/steam/compatibilitytools.d/*"

RDEPEND="
	media-libs/vulkan-loader
"

src_unpack() {
	default
	if use cpu_flags_x86_avx2; then
		S="${WORKDIR}/${MY_P}-x86_64_v3"
	else
		S="${WORKDIR}/${MY_P}-x86_64"
	fi
}

src_install() {
	local dest="/usr/share/steam/compatibilitytools.d/Proton-CachyOS-Wineland-${MY_PV}"
	dodir "${dest%/*}"

	# mv rather than doins to keep the modes of the prebuilt tree
	# (wine loaders, preloaders and protonfixes helpers must stay executable)
	mv "${S}" "${ED}${dest}" || die
	fowners -R root:root "${dest}"
}

pkg_postinst() {
	local variant="x86_64"
	use cpu_flags_x86_avx2 && variant="x86_64_v3"

	elog "Proton-CachyOS Wineland has been installed into /usr/share/steam/compatibilitytools.d/"
	elog "Restart Steam to see '${MY_P}-${variant}' in Steam Play compatibility tools."
	elog ""
	elog "Wineland is tailored for native Wayland driver usage (e.g. launchers, CEF, cursor confinement):"
	elog "  PROTON_ENABLE_WAYLAND=1 %command%"
	elog ""
	elog "For Wayland HDR support:"
	elog "  ENABLE_HDR_WSI=1 PROTON_ENABLE_WAYLAND=1 DXVK_HDR=1 %command%"
}
