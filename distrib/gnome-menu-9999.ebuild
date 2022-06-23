# Copyright 2022 Alex Belykh
# Distributed under the terms of the GNU General Public License v3

EAPI=7

inherit git-r3

DESCRIPTION="Yet another Freedesktop Menu parsing library for x11-wm/awesome"
HOMEPAGE="https://github.com/albel727/awesomewm_gnome_menu"
EGIT_REPO_URI="https://github.com/albel727/awesomewm_gnome_menu.git"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+gtk3"

RDEPEND="
	x11-wm/awesome
	gnome-base/gnome-menus:3[introspection]
	gtk3? ( x11-libs/gtk+:3 )
"

DOCS=( README.md )

src_install() {
	insinto /usr/share/awesome/lib/gnome_menu
	doins *.lua

	einstalldocs
}
