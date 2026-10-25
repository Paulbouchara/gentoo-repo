# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry-core
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python client library for Supabase Realtime"
HOMEPAGE="
	https://github.com/supabase/supabase-py/
	https://pypi.org/project/realtime/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.11.7[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.14.0[${PYTHON_USEDEP}]
	>=dev-python/websockets-11[${PYTHON_USEDEP}]
"

src_prepare() {
	distutils-r1_src_prepare

	# Upstream caps websockets below 16, but realtime only uses connect(),
	# asyncio.client.ClientConnection (iterate/send/close) and the
	# ConnectionClosedError/OK exceptions, all unchanged in websockets 16
	# and 17; ::gentoo has nothing older than 16.
	sed -i -e '/"websockets /s:,<16::' pyproject.toml || die
}

# The sdist ships no tests.
