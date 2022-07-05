local gtk = require("gnome_menu.gtk")

-- Some sane defaults for when the user didn't specify anything.
local module = {
    gtk_theme = gtk.IconTheme.get_default(),
    icon_size = 32,
}

-- Builds a resolver function, that converts a given GIcon into a path to the icon file.
-- The icons will come from the specified Gtk theme and be (approximately) of the specified size.
function module.build_gicon_resolver(icon_size, gtk_theme)
    return function(icon)
        if not icon then
            return nil
        end
        local theme = gtk_theme or module.gtk_theme
        local icon_info = theme:lookup_by_gicon(icon, icon_size or module.icon_size, 0)
        return icon_info and icon_info:get_filename()
    end
end

-- Builds a function, that looks up icons by their names and returns a path to the icon file.
-- The icons will come from the specified Gtk theme and be (approximately) of the specified size.
--
-- The returned function CAN'T be used as gnome_menu.icon_resolver. BUT it can be used as a faster and
-- more robust substitute for the menubar.utils.lookup_icon() function, which is utilized by
-- menubar (awesome's XDG menu implementation) and naughty (awesome's DBUS notifications) modules.
--
-- 48px is the approximate size of notification icons (but it might be greater if you have a high DPI monitor),
-- so, the recommended usage (somewhere in the rc.lua, preferably at the top, before loading other modules) is:
--     require("menubar.utils").lookup_icon_uncached = require("gnome_menu.icon_gtk").build_icon_resolver(48)
function module.build_icon_resolver(icon_size, gtk_theme)
    return function(icon)
        if not icon then
            return nil
        end
        local theme = gtk_theme or module.gtk_theme
        local icon_info = theme:lookup_icon(icon, icon_size or module.icon_size, 0)
        return icon_info and icon_info:get_filename()
    end
end

--  An unfinished experiment for loading pixbufs directly instead of filenames.
--  This might be more reliable in the face of different subtypes of GIcon-s,
--  but it will need converting pixbufs to something, that awful.menu understands.
--
--  function module.build_gicon_resolver_to_pixbuf(icon_size, gtk_theme)
--      return function(icon)
--          if not icon then
--              return nil
--          end
--          local theme = gtk_theme or module.gtk_theme
--          local icon_info = theme:lookup_by_gicon(icon, icon_size or module.icon_size, 0)
--          return icon_info and icon_info:load_icon()
--      end
--  end

return module
