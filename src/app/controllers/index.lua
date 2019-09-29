-- IndexController
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/29
-- Time: 10:37
-- To change this template use File | Settings | File Templates.
--
local Controller = require "lion.content.controller"

local _M = {
    _VERSION = "1.0.0"
}

function _M:new(controller,config)
    controller = controller or Controller:new(controller)
    setmetatable(controller, self)
    self.__index = self

    if config and ext.isTable(config) then
        self = ext.block(self,config)
    end

    return controller
end

--- indexAction
--
function _M:indexAction()
    return "index:indexAction"
end

return _M
