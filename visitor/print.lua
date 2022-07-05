-- A visitor that prints an overview of an XDG menu.
local srep = string.rep

local class = require('gnome_menu.visitor'):new({
    indent = 0,
    output = io.stderr,
})

function class:println_with_indent(msg)
    self.output:write(srep(" ", self.indent) .. msg .. "\n")
end

function class:visit_directory_start(directory)
    local dir_name = directory:get_name()
    self:println_with_indent('| ' .. dir_name)

    self.indent = self.indent + 4
    return self
end

function class:visit_directory_element(_directory, _ret)
end

function class:visit_directory_end(directory)
    self.indent = self.indent - 4
end

function class:visit_header(header)
    -- Untested
    local header_name = header:get_directory():get_name()
    self:println_with_indent('---- ' .. header_name .. ' ----')
end

function class:visit_separator(_separator)
    self:println_with_indent('---- menu separator ----')
end

function class:visit_alias_start(alias)
    self:println_with_indent('x The following entry is aliased:')
    return self, nil
end

function class:visit_entry(entry)
    local app_info = entry:get_app_info()

    local app_name = app_info:get_name()
    local app_cmd = app_info:get_commandline()

    self:println_with_indent('* ' .. app_name .. ' -> ' .. app_cmd)
end

return class
