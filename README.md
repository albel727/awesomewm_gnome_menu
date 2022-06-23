# Synopsis
* Install the [gnome-menus] (GMenu-3.0) and (optionally) Gtk-3.0 libraries.
* Install this library into somewhere, where `awesomewm` can pick it up, e.g. into the `~/.config/awesome/gnome_menu/` directory.
* Modify your `rc.lua` as follows.

```lua
-- Somewhere at the top:
local gnome_menu = require("gnome_menu")
-- Somewhere in the middle:
mymainmenu = awful.menu({ items = {
                                    gnome_menu.load_menu(), -- <-- This is the important new line.
                                    { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })
```

# Introduction

`gnome_menu for awesomewm` is a lua library for the [awesome] window manager,
that enables parsing Freedesktop(XDG)-standard Menu files, to e.g. present your typical application menu.

I know of several projects that aim to do the same:
* awesome's built-in [menubar] module, which implements XDG Menu parsing in pure Lua.
* [awesome-freedesktop], which internally uses `menubar`.
* [xdg-menu-to-awesome-wm], which is a python program for statically generating a lua file with the menu.

Unfortunately, at the time of writing, all of them fell short of my needs.
`menubar` seems to limit itself to showing only some predefined set of application categories/submenus,
so a lot of stuff ends up simply missing, compared to `xdg-menu-to-awesome-wm`, but the latter requires
one to manually regenerate the menu file every time a program is (un)installed, which is annoying.

I didn't have time to try and improve `menubar`, so I've decided to quickly whip up something,
utilizing some tried and tested XDG Menu parsing library, which ended up being [gnome-menus].
With this, everything is shown like I want it and on the fly.


# Icon lookup and Gtk-3.0

This library automatically detects and attempts to use the Gtk-3.0 library for looking up menu icons, if it's available.
It's (much) faster than awesome's native icon lookup, and it honors user's selected Gtk theme.

As a bonus, you can even make awesomewm universally use the Gtk-3.0 icon lookup for stuff
like notification icons. Look around in the `icon_gtk.lua` for how, if you're interested.

#### Caveats:
* I've heard that Gtk-3.0 might not play well with Lua and multiple threads, so it might become an
  additional instability source for the awesome window manager. On the other hand, I've used Gtk-3.0
  from awesomewm for years and haven't had any crashes, so there's that. If that doesn't reassure you,
  it's possible to disable the usage of Gtk-3.0 altogether, you just need to change the
  `gnome_menu.icon_resolver` setting accordingly.
* Gtk-3.0 is old, there's Gtk-4 already, but it purportedly doesn't play along with Lua altogether.
  So the happy speed-up is likely to end, when your distro stops shipping Gtk-3.0. Alas.

# Known bugs and limitations

* This library doesn't honor the `OnlyShowIn`/`NotShowIn` Desktop Entry directives.
  I.e. you might see menu items, that only make sense in KDE, for example.
  The proper behavior can be implemented, but I deem the effort not worth the result at this moment.
* The `gnome-menus` library has a bug with parsing of the `applications.menu` file, when it is a symlink to a differently named file.
  E.g. if `/etc/xdg/menus/applications.menu` is actually a symlink to a `kf5-applications.menu` file, then it will,
  in violation of the specification, ignore menu files in `/etc/xdg/menus/applications-merged` directory,
  and look in the `kf5-applications-merged` directory instead.
  The workaround is to symlink the `applications-merged` directory to the expected name.

# License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.

[awesome]: https://awesomewm.org/
[gnome-menus]: https://gitlab.gnome.org/GNOME/gnome-menus
[menubar]: https://awesomewm.org/doc/api/libraries/menubar.html
[awesome-freedesktop]: https://github.com/lcpz/awesome-freedesktop
[xdg-menu-to-awesome-wm]: https://github.com/albel727/xdg-menu-to-awesome-wm
