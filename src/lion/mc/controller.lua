-- 控制器,只在content_by_lua*中使用
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/29
-- Time: 10:39
-- To change this template use File | Settings | File Templates.
--
local ext       = require "lion.extension"

local _M = {
    _VERSION = "1.0.0",
    context  = ngx.ctx
}

---
-- @param controller
-- @param config
--
function _M:new (controller,config)
    controller = controller or {}
    setmetatable(controller, self)

    self.__index = self
    if config and ext.isTable(config) then
        self = ext.block(self,config)
    end

    return controller
end

return _M


