-- ngx.shared级限速
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 18:26
-- To change this template use File | Settings | File Templates.
--
local ext = require "lion.extension"

local _M = {
    _VERSION = '1.0.0'
}

--- 实例化
---@param instance table|nil
---@param config   table
---
function _M:new(instance,config)
    instance = instance or {}
    setmetatable(instance,self)
    self.__index = self

    if config and ext.isTable(config) then
        ext.block(self,config)
    end

    return instance
end

return _M