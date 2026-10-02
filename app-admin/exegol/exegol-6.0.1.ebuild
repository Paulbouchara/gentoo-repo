# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=pdm-backend
PYTHON_COMPAT=( python3_{12..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python wrapper for Exegol, a container-based hacking environment"
HOMEPAGE="
	https://exegol.com/
	https://github.com/ThePorgs/Exegol
	https://pypi.org/project/exegol/
"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64"

# Upstream pins with ~= (compatible release); only the lower bounds are kept.
RDEPEND="
	>=dev-python/argcomplete-3.6.3[${PYTHON_USEDEP}]
	>=dev-python/cryptography-46.0.3[${PYTHON_USEDEP}]
	>=dev-python/docker-7.1.0[${PYTHON_USEDEP}]
	>=dev-python/gitpython-3.1.43[${PYTHON_USEDEP}]
	>=dev-python/ifaddr-0.2.0[${PYTHON_USEDEP}]
	>=dev-python/pydantic-2.12.4[${PYTHON_USEDEP}]
	>=dev-python/pyjwt-2.10.1[${PYTHON_USEDEP}]
	>=dev-python/pyyaml-6.0.3[${PYTHON_USEDEP}]
	>=dev-python/requests-2.32.5[${PYTHON_USEDEP}]
	>=dev-python/rich-14.2.0[${PYTHON_USEDEP}]
	>=dev-python/supabase-2.24.0[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
	>=dev-python/tzlocal-5.4[${PYTHON_USEDEP}]
	app-containers/docker
	dev-vcs/git
"

# Upstream has no tests yet (its tests/ only holds an empty __init__.py and is
# excluded from the sdist).
