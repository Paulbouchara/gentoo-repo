# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )
inherit flag-o-matic python-any-r1 toolchain-funcs wine

WINE_GECKO=2.47.4
WINE_MONO=10.4.1

# dlls/xgameruntime is a submodule pinned to its main branch, but the
# XUser support needs the xuser branch, so it is fetched separately
XGAMERUNTIME_URI="https://github.com/xodus-gaming/xgameruntime"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/xodus-gaming/wine.git"
	EGIT_BRANCH="bleeding-edge"
	EGIT_SUBMODULES=()
else
	WINE_COMMIT="eab69739f15180b96797645ccade44c1c4414980"
	XGAMERUNTIME_COMMIT="44d97de1e084be61243323062ed49e307d28728c"
	SRC_URI="
		https://github.com/xodus-gaming/wine/archive/${WINE_COMMIT}.tar.gz -> ${P}.tar.gz
		${XGAMERUNTIME_URI}/archive/${XGAMERUNTIME_COMMIT}.tar.gz
			-> ${P}-xgameruntime.tar.gz
	"
	S="${WORKDIR}/wine-${WINE_COMMIT}"
	KEYWORDS="-* ~amd64"
fi

DESCRIPTION="Xodus Gaming's fork of Wine with GDK and Xbox PC compatibility"
HOMEPAGE="https://github.com/xodus-gaming/wine"

LICENSE="
	LGPL-2.1+
	BSD BSD-2 IJG MIT OPENLDAP ZLIB gsm libpng2 libtiff public-domain
	|| ( WTFPL-2 public-domain )
"
SLOT="${PV}"
IUSE="
	+X +alsa crossdev-mingw +dbus ffmpeg +fontconfig +gecko +gstreamer
	llvm-libunwind +mono nls perl pulseaudio +sdl selinux +ssl udev
	+unwind usb v4l wayland video_cards_amdgpu xinerama
"
REQUIRED_USE="
	|| ( X wayland )
	udev? ( sdl )
"

RESTRICT="test"

WINE_DLOPEN_DEPEND="
	dev-libs/libgcrypt:=[${WINE_USEDEP}]
	media-libs/freetype[${WINE_USEDEP}]
	media-libs/libglvnd[X?,${WINE_USEDEP}]
	media-libs/vulkan-loader[X?,wayland?,${WINE_USEDEP}]
	X? (
		x11-libs/libXcomposite[${WINE_USEDEP}]
		x11-libs/libXcursor[${WINE_USEDEP}]
		x11-libs/libXfixes[${WINE_USEDEP}]
		x11-libs/libXi[${WINE_USEDEP}]
		x11-libs/libXrandr[${WINE_USEDEP}]
		x11-libs/libXrender[${WINE_USEDEP}]
		x11-libs/libXxf86vm[${WINE_USEDEP}]
		xinerama? ( x11-libs/libXinerama[${WINE_USEDEP}] )
	)
	dbus? ( sys-apps/dbus[${WINE_USEDEP}] )
	fontconfig? ( media-libs/fontconfig[${WINE_USEDEP}] )
	sdl? ( media-libs/libsdl2[haptic,joystick,${WINE_USEDEP}] )
	ssl? (
		dev-libs/gmp:=[${WINE_USEDEP}]
		net-libs/gnutls:=[${WINE_USEDEP}]
	)
	v4l? ( media-libs/libv4l[${WINE_USEDEP}] )
"
WINE_COMMON_DEPEND="
	${WINE_DLOPEN_DEPEND}
	X? (
		x11-libs/libX11[${WINE_USEDEP}]
		x11-libs/libXext[${WINE_USEDEP}]
	)
	alsa? ( media-libs/alsa-lib[${WINE_USEDEP}] )
	ffmpeg? ( media-video/ffmpeg:=[${WINE_USEDEP}] )
	gstreamer? (
		dev-libs/glib:2[${WINE_USEDEP}]
		media-libs/gst-plugins-base:1.0[opengl,${WINE_USEDEP}]
		media-libs/gstreamer:1.0[${WINE_USEDEP}]
	)
	pulseaudio? ( media-libs/libpulse[${WINE_USEDEP}] )
	udev? ( virtual/libudev:=[${WINE_USEDEP}] )
	unwind? (
		llvm-libunwind? ( llvm-runtimes/libunwind[${WINE_USEDEP}] )
		!llvm-libunwind? ( sys-libs/libunwind:=[${WINE_USEDEP}] )
	)
	usb? ( dev-libs/libusb:1[${WINE_USEDEP}] )
	video_cards_amdgpu? ( x11-libs/libdrm[video_cards_amdgpu,${WINE_USEDEP}] )
	wayland? (
		dev-libs/wayland[${WINE_USEDEP}]
		x11-libs/libxkbcommon[${WINE_USEDEP}]
	)
"
RDEPEND="
	${WINE_COMMON_DEPEND}
	gecko? (
		app-emulation/wine-gecko:${WINE_GECKO}[${WINE_USEDEP}]
		wow64? ( app-emulation/wine-gecko[abi_x86_32] )
	)
	mono? ( app-emulation/wine-mono:${WINE_MONO} )
	perl? (
		dev-lang/perl
		dev-perl/XML-Simple
	)
	selinux? ( sec-policy/selinux-wine )
"
DEPEND="
	${WINE_COMMON_DEPEND}
	X? ( x11-base/xorg-proto )
"
BDEPEND="
	${PYTHON_DEPS}
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
	nls? ( sys-devel/gettext )
"

PATCHES=(
	"${FILESDIR}"/xgameruntime-makefile.patch
	"${FILESDIR}"/xgameruntime-config.patch
)

src_unpack() {
	if [[ ${PV} == 9999 ]]; then
		local xgr_id="${CATEGORY}/${PN}/${SLOT%/*}-xgameruntime"

		git-r3_src_unpack
		git-r3_fetch "${XGAMERUNTIME_URI}" refs/heads/xuser "${xgr_id}"
		git-r3_checkout "${XGAMERUNTIME_URI}" "${S}"/dlls/xgameruntime "${xgr_id}"
	else
		default
		if [[ -d ${S}/dlls/xgameruntime ]]; then
			rmdir "${S}"/dlls/xgameruntime || die
		fi
		mv "${WORKDIR}"/xgameruntime-${XGAMERUNTIME_COMMIT} "${S}"/dlls/xgameruntime || die
	fi
}

src_prepare() {
	sed -i "s/wine_build[^1]*1/& (Wine-Xodus-${PV})/" configure.ac || die

	# read pre-fetched RPS tickets from ~/xodustickets/ instead of the stub
	"${EPYTHON}" "${FILESDIR}"/inject_get_rps_tickets.py \
		dlls/xgameruntime/xuser.c || die "inject_get_rps_tickets failed"

	# implement the private exports that are still stubs
	local stub
	for stub in 'DllCanUnloadNow()' 'UninitializeApiImpl()' 'XErrorReport(long str)'; do
		sed -i "s/@ stub -private ${stub}/@ stdcall -private ${stub}/" \
			dlls/xgameruntime/xgameruntime.spec || die
	done
	cat "${FILESDIR}"/xgameruntime-stubs.c >> dlls/xgameruntime/main.c || die

	wine_src_prepare

	tools/make_specfiles || die
	dlls/winevulkan/make_vulkan -X video.xml -x vk.xml || die
}

src_configure() {
	tc-is-gcc || unset AR AS CC CPP CXX LD NM OBJ{COPY,DUMP} RANLIB READELF STRIP
	tc-ld-is-bfd || append-ldflags -fuse-ld=bfd
	strip-unsupported-flags

	local wineconfargs=(
		--with-freetype
		--with-opengl
		--with-vulkan
		--without-capi
		--without-cups
		--without-gphoto
		--without-gssapi
		--without-hwloc
		--without-krb5
		--without-netapi
		--without-opencl
		--without-pcap
		--without-pcsclite
		--without-sane
		ac_cv_header_bluetooth_bluetooth_h=no
		ac_cv_header_bluetooth_rfcomm_h=no
		ac_cv_lib_soname_odbc=

		$(use_enable gecko mshtml)
		$(use_enable mono mscoree)
		$(use_enable video_cards_amdgpu amd_ags_x64)
		--disable-tests

		$(use_with X x)
		$(use_with alsa)
		$(use_with dbus)
		--without-ffmpeg
		$(use_with fontconfig)
		$(use_with gstreamer)
		$(use_with nls gettext)
		--without-oss
		$(use_with pulseaudio pulse)
		$(use_with sdl)
		$(use_with ssl gnutls)
		$(use_with udev)
		$(use_with unwind)
		$(use_with usb)
		$(use_with v4l v4l2)
		$(use_with wayland)
		$(use_with xinerama)
	)

	wine_src_configure
}

src_install() {
	wine_src_install
	dodoc ANNOUNCE* AUTHORS README* documentation/README*
}
