local utils = require("gnome_menu.utils")

local module = {
    -- Use Gio launcher by default, b/c it probably handles some special XDG entries better.
    cmd_resolver = require("gnome_menu.cmd_gio").app_info_to_cmd,
    -- Autodetect, if we can use Gtk to resolve icons, fall back to awesome's resolver instead.
    icon_resolver = require("gnome_menu.icon_autodetect").resolve_gicon,
    -- Re-export gnome_menu.utils for quick user access.
    utils = utils,
}

-- An awful.menu builder instance that respects our cmd_resolver/icon_resolver settings.
local awful_menu_builder = require('gnome_menu.visitor.awful_menu'):new(module)

function module.reload_menu(menu)
    if not utils.gmenu_load(menu) then
        -- A dummy fallback menu, that doesn't crash Awesome, like nil would,
        -- but makes it obvious to the user, that something went wrong.
        return { text = 'Error loading XDG Menu file' }
    end
    return awful_menu_builder:accept_menu(menu)
end

-- Produces a single item for awful.menu from a given XDG menu file.
function module.load_menu(menu_file, flags)
    local menu = utils.gmenu_new(menu_file, flags)
    return module.reload_menu(menu)
end

function module.watch_menu(menu_file, flags)
    local watcher = require("gnome_menu.watcher")
    local menu = utils.gmenu_new(menu_file, flags)
    local ret = watcher.new({
        raw_menu = menu,
        menu_parser = module.reload_menu,
    })
    return ret
end

return module
