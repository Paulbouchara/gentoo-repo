# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=uv-build
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python client library for Supabase Edge Functions"
HOMEPAGE="
	https://github.com/supabase/supabase-py/
	https://pypi.org/project/supabase-functions/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

# strenum is declared unconditionally but only imported with Python < 3.11
RDEPEND="
	dev-python/h2[${PYTHON_USEDEP}]
	<dev-python/httpx-0.29[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.26[${PYTHON_USEDEP}]
	>=dev-python/yarl-1.20.1[${PYTHON_USEDEP}]
"

# The sdist ships no tests.
