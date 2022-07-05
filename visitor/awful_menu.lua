-- A visitor that converts an XDG menu into awful.menu item table.

local table_insert = table.insert

local class = require('gnome_menu.visitor'):new({
    cmd_resolver = nil,
    icon_resolver = nil,
})

function class:visit_directory_start(_directory)
    self.items = {}
    return self:new()
end

function class:visit_directory_element(_directory, ret)
    table_insert(self.items, ret)
end

function class:visit_directory_end(directory)
    local dir_name = directory:get_name()
    local dir_icon = directory:get_icon()
    local items = self.items
    self.items = nil

    -- utils.sort_menu_items_by_name(items)

    return {
        text = dir_name,
        cmd = items,
        icon = self.icon_resolver(dir_icon),
    }
end

function class:visit_entry(entry)
    local app_info = entry:get_app_info()

    local app_name = app_info:get_name()
    local app_icon = app_info:get_icon()
    local app_cmd = self.cmd_resolver(app_info)

    return {
        text = app_name,
        cmd = app_cmd,
        icon = self.icon_resolver(app_icon),
    }
end

return class
