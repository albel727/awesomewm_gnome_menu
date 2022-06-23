local module = {}

-- This creates a menu action function, that awful.menu will execute on click.
-- The function uses Gio for launching applications from XDG desktop entries.
function module.app_info_to_cmd(app_info)
    local app_cmd = function()
        return false, -- hide the containing menu on click
            function() -- execute the command after hiding the menu
                app_info:launch()
            end
    end
    return app_cmd
end

return module
