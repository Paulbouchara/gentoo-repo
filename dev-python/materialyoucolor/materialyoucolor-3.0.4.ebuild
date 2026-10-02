# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_EXT=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Material You color algorithms for python"
HOMEPAGE="
	https://github.com/T-Dynamos/materialyoucolor-python
	https://pypi.org/project/materialyoucolor/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# guru only carries a live ebuild with RESTRICT=network-sandbox. The sdist
# bundles every C++ source of the quantizer extension (stb_image.h included);
# the only build-time need is pybind11, declared below, so nothing is fetched.
RDEPEND="dev-python/pillow[${PYTHON_USEDEP}]"
BDEPEND=">=dev-python/pybind11-2.11.0[${PYTHON_USEDEP}]"

distutils_enable_tests import-check
