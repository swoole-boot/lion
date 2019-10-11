-- 配置
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/29
-- Time: 11:27
-- To change this template use File | Settings | File Templates.
--
local shared = require "lion.ext.shared"


local _M = {
    _VERSION = "1.0.0"
}

--- 获取远程配置文件根key
function _M.configRootKey()
    local configKey = _M.get("configRootKey")
    return ext.emptyDefault(configKey,"lion-gateway")
end

--- 获取配置
--- @param key string
--
function _M.get(key)
    return shared.get(ngx.shared.config, key)
end

--- 变更配置
---@param key   string
---@param value any
---
function _M.set(key,value)
    return shared.set(ngx.shared.config, key, value)
end

return _M

