# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=uv-build
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python client library for Supabase Auth"
HOMEPAGE="
	https://github.com/supabase/supabase-py/
	https://pypi.org/project/supabase-auth/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/cryptography[${PYTHON_USEDEP}]
	dev-python/h2[${PYTHON_USEDEP}]
	<dev-python/httpx-0.29[${PYTHON_USEDEP}]
	>=dev-python/httpx-0.26[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.10[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-2.10.1[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"

# The sdist ships no tests.
