-- ngx.shared扩展，支持存table
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 11:37 AM
-- To change this template use File | Settings | File Templates.
--
local json = require "cjson"
local ext  = require "lion.extension"

local _M ={
    _VERSION = '1.0.0'
}

--- 存储任意类型数据
--- @param share
--- @param key     string
--- @param value   any
--- @param timeout number
--
function _M.set(share, key, value, timeout)
    timeout = timeout or 0
    if timeout == 0 then
        return share:set(key,json.encode(value))
    end
    return share:set(key, json.encode(value), timeout)
end

--- 批量存储
--- @param share
--- @param table   table
--
function _M.mset(share, table)
    local success,error,forcible = true, nil, nil
    for key,value in pairs(table) do
        success,error,forcible = _M.set(share, key, value)
        if success == false then
            break;
        end
    end
    return success,error,forcible
end

--- 获取值
--- @param share
--- @param key    string
--
function _M.get(share, key)
    local value, flags = share:get(key)
    if ext.empty(value) then
        return value
    end
    return json.decode(value)
end

return _M



