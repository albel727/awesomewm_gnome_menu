-- The base class for XDG menu visitors.

local class = {}

-- Overridable methods.

function class:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function class:visit_entry(entry)
end

function class:visit_directory_start(directory)
    return self, nil
end

function class:visit_directory_element(directory, ret)
end

function class:visit_directory_end(directory)
end

function class:visit_header(header)
end

function class:visit_separator(separator)
end

function class:visit_alias_start(alias)
    return self, nil
end

function class:visit_alias_end(alias, ret)
    return ret
end

-- Final methods.

function class:accept_alias(alias)
    local vis, ret = self:visit_alias_start(alias)
    if not vis then
        return ret
    end

    local item_type = alias:get_aliased_item_type()

    if item_type == "ENTRY" then
        ret = vis:visit_entry(alias:get_aliased_entry())
    elseif item_type == "DIRECTORY" then
        ret = vis:accept_directory(alias:get_aliased_directory())
    else
        -- Should be impossible to reach.
        error("Unexpected aliased item type: " .. item_type)
    end

    return self:visit_alias_end(alias, ret)
end

function class:accept_directory(directory)
    local vis, immediate_ret = self:visit_directory_start(directory)

    if not vis then
        return immediate_ret
    end

    local it = directory:iter()

    while true do
        local item_type = it:next()
        local ret = nil

        if item_type == "INVALID" then
            break
        elseif item_type == "ENTRY" then
            ret = vis:visit_entry(it:get_entry())
        elseif item_type == "DIRECTORY" then
            ret = vis:accept_directory(it:get_directory())
        elseif item_type == "HEADER" then
            ret = vis:visit_header(it:get_header())
        elseif item_type == "SEPARATOR" then
            ret = vis:visit_separator(it:get_separator())
        elseif item_type == "ALIAS" then
            ret = vis:accept_alias(it:get_alias())
        else
            -- Should be impossible to reach.
            error("Unknown item type: " .. item_type)
        end

        self:visit_directory_element(directory, ret)
    end

    return self:visit_directory_end(directory)
end

function class:accept_menu(menu)
    local menu_dir = menu:get_root_directory()
    return self:accept_directory(menu_dir)
end

return class
