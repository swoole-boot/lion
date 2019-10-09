-- ProductController
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/29
-- Time: 10:37
-- To change this template use File | Settings | File Templates.
--
local ext        = require "lion.extension"

local _M = {
    _VERSION = "1.0.0",
    id       = "product",
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

---
---
function _M:detailAction()
    return ngx.ctx.request.uriArgs
end

return _M