-- HookController
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/29
-- Time: 10:37
-- To change this template use File | Settings | File Templates.
--
local ext        = require "lion.extension"

local _M = {
    _VERSION = "1.0.0",
    id       = "hook",
    actionId = ""
}

function _M:new(controller,config)
    controller = controller or {}
    setmetatable(controller, self )
    self.__index = self

    if config and ext.isTable(config) then
        ext.block(self,config)
    end

    return controller
end

--- 自定义action执行前,可以不定义
---@param result     any
---
function _M:actionBefore()
    ngx.ctx.response.headers.route = self.id,"/",self.actionId
    return true
end

function _M:indexAction()
    return "Hello Hook"
end

--- 自定义action执行后,可以不定义
---@param result     any
---
function _M:actionAfter(result)
    return {result}
end

return _M