-- route
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/29
-- Time: 10:37
-- To change this template use File | Settings | File Templates.
--

local context  = ngx.ctx

local _M = {
    _VERSION = "1.0.0"
}

function _M.route()
    local content = require("cjson").encode(context.request)
    ngx.say(content)
    ngx.exit(200)
end

return _M