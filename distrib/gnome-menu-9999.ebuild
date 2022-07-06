# Copyright 2022 Alex Belykh
# Distributed under the terms of the GNU General Public License v3

EAPI=7

DESCRIPTION="Yet another Freedesktop Menu parsing library for x11-wm/awesome"
HOMEPAGE="https://github.com/albel727/awesomewm_gnome_menu"

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/albel727/awesomewm_gnome_menu.git"
	inherit git-r3
else
	SRC_URI="https://github.com/albel727/awesomewm_gnome_menu/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64 x86 ~alpha ~amd64-linux ~arm ~ia64 ~ppc ~ppc64 ~ppc-macos ~riscv ~sparc ~x86-linux ~x86-solaris"
	S="${WORKDIR}/awesomewm_gnome_menu-${PV}"
fi

LICENSE="GPL-3+"
SLOT="0"
IUSE="+gtk3"

RDEPEND="
	x11-wm/awesome
	gnome-base/gnome-menus:3[introspection]
	gtk3? ( x11-libs/gtk+:3[introspection] )
"

DOCS=( README.md )

src_install() {
	insinto /usr/share/awesome/lib/gnome_menu
	doins *.lua
	doins -r visitor

	einstalldocs
}
