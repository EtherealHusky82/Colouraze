local class = {}
-- function that copies the tables in the level files, to prevent updating of those tables which are still required when a level is reloaded.
-- credit to http://lua-users.org/wiki/CopyTable 
function class.deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[class.deepCopy(orig_key)] = class.deepCopy(orig_value)
        end
        setmetatable(copy, class.deepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return class