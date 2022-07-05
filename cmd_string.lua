local module = {}

-- This procures a spawn()-able command string.
-- This implementation is currently neither full nor correct with respect to
-- the XDG desktop entry spec, but it will work in the most cases.
function module.app_info_to_cmd(app_info)
    local cmdline = app_info:get_commandline()
    -- Remove some desktop entry special percent codes.
    cmdline = cmdline:gsub('%%[fuFUki]', '')
    return cmdline
end

return module
