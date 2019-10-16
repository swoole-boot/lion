-- 控制器
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/29
-- Time: 10:39
-- To change this template use File | Settings | File Templates.
--
local response  = require "lion.ext.response"
local ext       = require "lion.extension"

local _M = {
    _VERSION = "1.0.0",
}

---执行action
---
function _M.run(controller)
    local actionName = controller.actionId.."Action"
    local action = controller[ actionName ]
    --- action不存在
    if type(action) ~= "function" then
        ngx.ctx.response.status = ngx.HTTP_NOT_FOUND
        response.send()
        return
    end

    --- action run before
    local canRun =  _M.actionBefore(controller)
    if not canRun then
        response.send()
        return
    end

    --- controller添加了自己的before action处理
    if type(controller["actionBefore"]) == "function" then
        canRun = controller:actionBefore()

        if not canRun then
            response.send()
            return
        end
    end

    --- run action
    local content = action()

    --- controller添加了自己的after action处理
    if type(controller["actionAfter"]) == "function" then
        content = controller:actionAfter(content)
    end

    --- 全局after action
    _M.actionAfter(content,controller)

    --- response
    response.send()
end

---全局action执行前
---@param controller table
---@return boolean
---
function _M.actionBefore(controller)
    return true
end

---全局action执行后
---@param result     any
---@param controller table
---
function _M.actionAfter(result,controller)
    if ext.isTable(result) then
        ngx.ctx.response.body = require("cjson").encode(result)
    else
        ngx.ctx.response.body = tostring(result)
    end
end

return _M


