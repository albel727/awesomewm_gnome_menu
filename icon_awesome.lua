local awesome_lookup_icon = require('menubar.utils').lookup_icon
local lgi = require("lgi")

local gio = lgi.Gio

local module = {}

function module.resolve_gicon(icon)
    if not icon then
        return nil
    elseif gio.ThemedIcon:is_type_of(icon) then
        local icon_names = icon:get_names()
        -- print('icon (themed): ' .. table.concat(icon_names, ' '))
        for _, icon_name in ipairs(icon_names) do
            local icon_path = awesome_lookup_icon(icon_name)
            if icon_path then
                return icon_path
            end
        end
        return nil
    elseif gio.FileIcon:is_type_of(icon) then
        local icon_path = icon:get_file():get_path()
        -- print('icon (file): ' .. icon_path)
        return icon_path
    else
        error("Unsupported type of icon: " .. tostring(icon._type))
    end
end

return module
