local gdebug = require("gears.debug")
local gmenu = require("gnome_menu.gmenu")
local table_sort = table.sort

local module = {}

-- Helper function for replacing the menu items of an already constructed
-- awful.menu widget with a given items table.
function module.replace_awful_menu_items(awful_menu, items)
    while awful_menu.items[1] do
        awful_menu:delete(1)
    end
    for _, v in ipairs(items) do
        awful_menu:add(v)
    end
end

-- Helper function for shallow-sorting an awful.menu items table by name.
function module.sort_menu_items_by_name(items)
    table_sort(items, function(a, b)
        local a_t = type(a.cmd) == "table"
        local b_t = type(b.cmd) == "table"
        if a_t ~= b_t then
            -- Sort submenus before normal entries.
            return a_t
        end
        return a.text <= b.text
    end)
end

-- Helper function for creating a GMenu instance with sane defaults.
function module.gmenu_new(menu_file, flags)
    menu_file = menu_file or "applications.menu"
    flags = flags or gmenu.TreeFlags.NONE
    --flags = flags or gmenu.TreeFlags.SORT_DISPLAY_NAME
    local menu = gmenu.Tree.new(menu_file, flags)
    return menu
end

-- Helper function for filling a GMenu instance from Freedesktop Menu file(s) with error logging.
function module.gmenu_load(menu)
    if not menu:load_sync() then
        gdebug.print_warning("Failed to find/load XDG Menu file: " .. tostring(menu.menu_path or menu.menu_basename))
        return false
    end
    return true
end

return module
