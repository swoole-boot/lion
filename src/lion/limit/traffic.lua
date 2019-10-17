-- traffic
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 18:26
-- To change this template use File | Settings | File Templates.
--
local config = require "lion.ext.config"
local ext    = require "lion.extension"

local _M = {
    _VERSION = '1.0.0'
}

function _M.driver()
    local limitConfig = config.rateLimitConfig()
    if ext.empty(limitConfig) then
        return nil
    end

    return require(ext.emptyDefault(limitConfig.driver.class,"lion.limit.ngx")):new(nil,{ driver = limitConfig.driver })
end

---
---
function _M.access()
    local driver = _M.driver()
    if driver == nil then
        return
    end

    driver:token(ngx.var.remote_addr, 2)
end

return _M