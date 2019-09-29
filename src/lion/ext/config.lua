-- 配置
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/29
-- Time: 11:27
-- To change this template use File | Settings | File Templates.
--
local shared = require "lion.ext.shared"


local _M = {
    _VERSION = "1.0.0"
}

--- 获取配置
-- @param key
--
function _M.get(key)
    return shared.get(ngx.shared.config, key)
end

return _M

