-- client
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/29
-- Time: 11:47
-- To change this template use File | Settings | File Templates.
--
local ext       = require "lion.extension"

local _M = {
    _VERSION   = "1.0.0",
}

---
-- @param client
-- @param config
--
function _M:new (client,config)
    client = client or {}
    setmetatable(client, self)

    self.__index = self
    if config and ext.isTable(config) then
        self = ext.block(self,config)
    end

    return client
end

return _M