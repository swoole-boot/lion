--
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 6:20 PM
-- To change this template use File | Settings | File Templates.
--

local _M ={
    _VERSION = "1.0.0"
}

--- table合并
-- @param ...
--
function _M.merge(...)
    local tabs = {...}
    if not tabs then
        return {}
    end

    local origin = tabs[1]

    for i = 2,#tabs do
        if tabs[i] then
            for key,value in pairs(tabs[i]) do
                if type(key) == "string" then
                    origin[ key ] = value
                else
                    table.insert(origin,value)
                end

            end
        end
    end

    return origin
end

return _M

