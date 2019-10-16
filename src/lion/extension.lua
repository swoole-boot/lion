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

---创建随机数
---@param len  number
---@param seed string
---
function _M.createRandStr(len, seed)
    len    = len    or 5
    seed = seed or "123456789abcdef"

    local str = ""
    local index = 1
    local now = ngx.now() * 1000
    for i = len, 1, -1 do
        math.randomseed(now + i)
        index = math.random(1,#seed)
        str = str..string.sub(seed, index ,index)
    end
    return str;
end

---创建一个指定长度的唯一id,长度最小为 14+ #prefix
---@param prefix string
---@param length number
---
function _M.uniqueId(prefix, length)
    length = length or 32
    prefix = prefix or ""
    local randLength = length - 13 - #prefix
    if randLength < 1 then
        randLength = 1
    end

    return prefix..tostring(ngx.now() * 1000).._M.createRandStr(randLength)
end

return _M

