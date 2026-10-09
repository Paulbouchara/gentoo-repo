# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# @Eclass:
# @Copyright: Copyright 2026 Gentoo Authors
# @Distributed under: the terms of the GNU General Public License v2
# @Eclassename: artcraft
# @ShortDescription: Package the prebuilt Linux build of an ArtCraft crafting app.
# @Description:
# Upstream (github.com/storytold) publishes, for every app and every release, one
# relocatable tar.gz per arch containing bin/, share/applications, share/icons,
# share/metainfo, share/mime and share/doc. Nothing is compiled: this eclass is
# packaging only. The binaries are nearly static (libc/libm/libgcc) but dlopen()
# their graphics stack at runtime (EGL, Vulkan, wayland-client, xkbcommon, X11,
# dbus), so those libraries are RDEPEND, not DEPEND.
#
# Each ebuild only has to set DESCRIPTION/HOMEPAGE/LICENSE and KEYWORDS.

case ${EAPI:-0} in
	8) ;;
	*) die "artcraft.eclass requires EAPI 8" ;;
esac

# @ECLASS_VARIABLE: ARTCRAFT_ARCH
# @DEFAULT_UNSET
# @DESCRIPTION:
# Arch suffix used in the release asset name. Detected from ARCH, can be
# overridden by the ebuild.

if [[ -z ${ARTCRAFT_ARCH} ]]; then
	case ${ARCH} in
		amd64) ARTCRAFT_ARCH="x86_64" ;;
		arm64) ARTCRAFT_ARCH="aarch64" ;;
		*) die "artcraft.eclass: unsupported ARCH: ${ARCH}" ;;
	esac
fi

SRC_URI="https://github.com/storytold/${PN}/releases/download/v${PV}/${PN}-${PV}-linux-${ARTCRAFT_ARCH}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${PN}-${PV}-linux-${ARTCRAFT_ARCH}"

# Prebuilt ELF: do not strip, and the fetch is a GitHub release asset.
RESTRICT="strip mirror"

# Pas de version plancher : ces bibliothèques sont dlopen() au runtime, et
# l'installation de l'utilisateur a libglvnd 9999 (unkeyworded), ce qu'un atom
# versionné masquerait.
RDEPEND="
	sys-apps/dbus
	media-libs/libglvnd
	media-libs/vulkan-loader
	dev-libs/wayland
	x11-libs/libxkbcommon
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcursor
	x11-libs/libXi
	media-libs/alsa-lib
"

src_install() {
	dobin bin/*

	insinto /usr/share
	doins -r share/.

	# Les .desktop d'upstream appellent le binaire par son nom, ce qui correspond
	# à dobin : rien à réécrire. Ils sont déjà dans share/.
}
