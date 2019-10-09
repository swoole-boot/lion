-- route
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/29
-- Time: 10:37
-- To change this template use File | Settings | File Templates.
--
local ext = require("lion.extension")
local context  = ngx.ctx

local _M = {
    _VERSION = "1.0.0"
}

function _M.route()
    local controller,action = string.match(context.request.uri,"/(%w+)/(%w+)")
    if ext.empty(controller) then
        controller = string.match(context.request.uri,"/(%w+)")

        if ext.empty(controller) then
            return require("lion.ext.config").get("defaultRoute")
        end

        return controller.."/".."index"
    end

    return controller.."/"..action
end

return _M