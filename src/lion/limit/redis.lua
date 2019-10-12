-- redis限速
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 18:26
-- To change this template use File | Settings | File Templates.
--
local ext    = require "lion.extension"

local _M = {
    _VERSION = "1.0.0",
    driver   = {},
    client   = nil
}

--- 实例化
---@param instance table|nil
---@param config   table
---
function _M:new(instance, config)
    instance = instance or {}
    setmetatable(instance,self)
    self.__index = self

    if config and ext.isTable(config) then
        ext.block(self,config)
    end
    return instance
end

---获取redis实例
---
function _M:redis()
    if self.client then
        return self.client
    end

    if ext.empty(self.driver.class) then
        return nil
    end

    self.client = require("lion.ext.redis"):new(nil, self.driver)

    return self.client
end

function _M:token(key)
    _M:redis():redis()
end

return _M
