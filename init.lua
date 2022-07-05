--local gdebug = require("gears.debug")
local gmenu = require("gnome_menu.gmenu")
local table_insert = table.insert
local table_sort = table.sort

local module = {
    -- Use Gio launcher by default, b/c it probably handles some special XDG entries better.
    cmd_resolver = require("gnome_menu.cmd_gio").app_info_to_cmd,
    -- Autodetect, if we can use Gtk to resolve icons, fall back to awesome's resolver instead.
    icon_resolver = require("gnome_menu.icon_autodetect").resolve_gicon,
}

-- Converts an XDG menu entry into awful.menu item table.
function module.itemize_menu_entry(entry)
    --gdebug.dump(entry:get_desktop_file_id())
    --gdebug.dump(entry:get_desktop_file_path())
    local app_info = entry:get_app_info()

    local app_name = app_info:get_name()
    local app_icon = app_info:get_icon()
    local app_cmd = module.cmd_resolver(app_info)
    return {
        text = app_name,
        cmd = app_cmd,
        icon = module.icon_resolver(app_icon),
    }
end

-- Helper function for shallow-sorting an awful.menu items table.
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

-- Converts an XDG submenu into awful.menu item table.
function module.traverse_menu_directory(directory)
    local dir_name = directory:get_name()
    local dir_icon = directory:get_icon()
    local it = directory:iter()
    local items = {}

    while true do
        local item_type = it:next()
        if item_type == "INVALID" then
            break
        elseif item_type == "ENTRY" then
            local entry = it:get_entry()
            local entry_item = module.itemize_menu_entry(entry)
            table_insert(items, entry_item)
        elseif item_type == "DIRECTORY" then
            local dir_item = module.traverse_menu_directory(it:get_directory())
            table_insert(items, dir_item)
        elseif item_type == "HEADER" then
            -- TODO: make a custom menu entry that shows as a header
        elseif item_type == "SEPARATOR" then
            -- TODO: make a custom menu entry that shows as a separator
        elseif item_type == "ALIAS" then
            -- TODO: untested, because I don't actually have menus with aliases.
            local alias = it:get_alias()
            if alias:get_aliased_item_type() == "ENTRY" then
                local entry = alias:get_aliased_entry()
                local entry_item = module.itemize_menu_entry(entry)
                table_insert(items, entry_item)
            else
                error("Unexpected aliased item type: " .. alias:get_aliased_item_type())
            end
        else
            -- Should be impossible to reach.
            error("Unknown item type: " .. item_type)
        end
    end

    module.sort_menu_items_by_name(items)

    return {
        text = dir_name,
        cmd = items,
        icon = module.icon_resolver(dir_icon),
    }
end

function module.reload_menu(menu)
    if not menu:load_sync() then
        require("gears.debug").print_warning("Failed to find/load XDG Menu file: " .. tostring(menu.menu_path or menu.menu_basename))
        return { text = 'Error loading XDG Menu file' }
    end
    local menu_dir = menu:get_root_directory()

    return module.traverse_menu_directory(menu_dir)
end

-- Produces a single item for awful.menu from a given XDG menu file.
function module.load_menu(menu_file, flags)
    menu_file = menu_file or "applications.menu"
    flags = flags or gmenu.TreeFlags.NONE
    --flags = flags or gmenu.TreeFlags.SORT_DISPLAY_NAME
    local menu = gmenu.Tree.new(menu_file, flags)
    return module.reload_menu(menu)
end

return module
