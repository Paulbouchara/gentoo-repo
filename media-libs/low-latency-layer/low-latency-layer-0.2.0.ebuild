# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Vulkan layer for hardware agnostic input latency reduction (Anti-Lag 2 / Reflex)"
HOMEPAGE="https://github.com/Korthos-Software/low_latency_layer"
SRC_URI="https://github.com/Korthos-Software/low_latency_layer/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/low_latency_layer-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	dev-util/vulkan-headers
	dev-util/vulkan-utility-libraries
"
RDEPEND="media-libs/vulkan-loader"
BDEPEND="dev-build/cmake"

pkg_postinst() {
	elog "The layer is opt-in: set LOW_LATENCY_LAYER=1 in the game's environment"
	elog "(Steam launch options: LOW_LATENCY_LAYER=1 %command%)."
	elog "LOW_LATENCY_LAYER_REFLEX=1 exposes VK_NV_low_latency2 instead of VK_AMD_anti_lag."
	elog "Do not use LOW_LATENCY_LAYER_SPOOF_NVIDIA: it breaks Proton's FSR4 upgrade path."
}
