local gtable_crush = require("gears.table").crush
local gtimer = require("gears.timer")
local object = require("gears.object")

local module = {}

local class = {}

function class:get_parsed_menu()
    local ret = rawget(self, "parsed_menu")
    if ret ~= nil then
        -- Return the cached value, when available.
        return ret
    end
    ret = self.menu_parser(self.raw_menu)
    rawset(self, "parsed_menu", ret)
    return ret
end

function class:set_raw_menu()
    error("Cannot set 'raw_menu' property, because it is read-only")
end

function class:signal_menu_change()
    rawset(self, "parsed_menu", nil)
    self:emit_signal("gnome_menu::changed")
end

-- Runs a given function immediately once, and then after every menu change.
function class:run_on_menu_change(handler)
    self:connect_signal("gnome_menu::changed", handler)
    handler(self)
end

function module.new(args)
    args = args or {}
    assert(args.raw_menu)
    assert(args.menu_parser)

    local ret = object({
        -- class = class,
        enable_properties = true,
        enable_auto_signals = true,
    })

    -- Copy over class methods.
    gtable_crush(ret, class, true)
    -- Init properties.
    rawset(ret, "raw_menu", args.raw_menu)
    rawset(ret, "menu_parser", args.menu_parser)
    rawset(ret, "parsed_menu", nil)

    -- Invalidate parsed menu cache too, if the user happens to change the menu parser.
    ret:connect_signal("property::menu_parser", function(o) o:signal_menu_change() end)

    local signal_scheduled = false

    args.raw_menu.on_changed = function()
        -- Throttle/coalesce the signals to avoid getting DoS-ed with inotify events,
        -- otherwise a malicious program that quickly adds/removes a .menu file
        -- in the watched dirs can hang awesome for good.
        if signal_scheduled then
            return
        end
        signal_scheduled = true
        gtimer.delayed_call(function()
            signal_scheduled = false
            ret:signal_menu_change()
        end)
    end

    return ret
end

return module
