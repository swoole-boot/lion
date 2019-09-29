-- 语言级通用扩展
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 18:26
-- To change this template use File | Settings | File Templates.
--

local _M = { _VERSION = '1.x' }

--- 判断是否为空
-- @param value
--
function _M.empty(value)
    if type(value) == 'table' then
        return next(value) == nil
    end
    return value == nil or value == false or value == ''
end

--- 判断类型是否为table
-- @param value
--
function _M.isTable(value)
    return type(value) == "table"
end

--- 块赋值
-- @param table object
-- @param table config
--
function _M.block(object,config)
    for property,value in pairs(config) do
        object[ property ] = value
    end
    return object
end

return _M

