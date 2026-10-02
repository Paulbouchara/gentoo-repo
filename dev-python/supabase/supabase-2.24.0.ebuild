# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=uv-build
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Supabase client for Python"
HOMEPAGE="
	https://github.com/supabase/supabase-py/
	https://pypi.org/project/supabase/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	<dev-python/httpx-0.29[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.26[${PYTHON_USEDEP}]
	~dev-python/postgrest-${PV}[${PYTHON_USEDEP}]
	~dev-python/realtime-${PV}[${PYTHON_USEDEP}]
	~dev-python/storage3-${PV}[${PYTHON_USEDEP}]
	~dev-python/supabase-auth-${PV}[${PYTHON_USEDEP}]
	~dev-python/supabase-functions-${PV}[${PYTHON_USEDEP}]
"

# The sdist ships no tests.
