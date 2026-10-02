# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=pdm-backend
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1 git-r3

DESCRIPTION="Python wrapper for Exegol, a container-based hacking environment"
HOMEPAGE="https://github.com/ThePorgs/Exegol"
EGIT_REPO_URI="https://github.com/ThePorgs/Exegol.git"

LICENSE="GPL-3+"
SLOT="0"

RDEPEND="
	dev-python/docker[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/rich[${PYTHON_USEDEP}]
	dev-python/gitpython[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/argcomplete[${PYTHON_USEDEP}]
	dev-python/ifaddr[${PYTHON_USEDEP}]
	dev-python/pydantic[${PYTHON_USEDEP}]
	dev-python/pyjwt[${PYTHON_USEDEP}]
	dev-python/cryptography[${PYTHON_USEDEP}]
	app-containers/docker
	dev-vcs/git
"
BDEPEND="
	dev-python/pdm-backend[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest
