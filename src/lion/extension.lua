-- 语言级通用扩展
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 18:26
-- To change this template use File | Settings | File Templates.
--

local _M = {
    _VERSION = '1.0.0'
}

--- 判断是否为空
--- @param value any
---
function _M.empty(value)
    if type(value) == "table" then
        return next(value) == nil
    end
    return value == nil or value == false or value =="" or value == ngx.null or value == "null"
end

--- 判断是否为空，如果为空给默认值
---@param value        any
---@param defaultValue any
---
function _M.emptyDefault(value,defaultValue)
    if _M.empty(value) then
        return defaultValue or nil
    end
    return value
end

--- 判断类型是否为table
--- @param value any
---
function _M.isTable(value)
    return type(value) == "table"
end

--- 块赋值
---@param object table
---@param config table
---
function _M.block(object,config)
    for property,value in pairs(config) do
        object[ property ] = value
    end
    return object
end

---
---@param str string 字符串
---@param sep string 分隔符
---
function _M.split(str, sep)
    local rtlist= {}
    string.gsub(str, '[^'.. sep ..']+', function(w)
        table.insert(rtlist, w)
    end)
    return rtlist
end

return _M

