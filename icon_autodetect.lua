local protected_call = require("gears.protected_call")

local module = {
    resolve_gicon = nil,
}

local infinite_recursion = false

-- This function will replace itself with Gtk's or awesome's resolver on the first call.
local function autodetector(...)
    local gnome_menu = require("gnome_menu")
    local parent_resolver = gnome_menu.icon_resolver
    -- Short-circuit to the currently chosen resolver, in case someone has this function still saved.
    if parent_resolver and (parent_resolver ~= autodetector) then
        if infinite_recursion then
            require("gears.debug").print_error("Bug! Infinite recursion.")
            return nil
        end
        infinite_recursion = true
        local result = protected_call(parent_resolver, ...)
        infinite_recursion = false
        return result
    end

    -- Autodetect, if we can use Gtk to resolve icons, fall back to awesome's resolver instead.
    local icon_gtk = protected_call(require, "gnome_menu.icon_gtk")

    local icon_resolver = icon_gtk and icon_gtk.build_gicon_resolver()
    if not icon_resolver then
        require("gears.debug").print_warning(
            "gnome_menu: Gtk-3.0 not found or failed. Falling back to awesomewm's native icon resolution."
        )
        icon_resolver = require("gnome_menu.icon_awesome").resolve_gicon
    end

    -- Override self and the parent setting.
    module.resolve_gicon = icon_resolver
    gnome_menu.icon_resolver = icon_resolver

    return icon_resolver(...)
end

module.resolve_gicon = autodetector

return module
