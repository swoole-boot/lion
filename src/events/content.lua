--扩展
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 15:06
-- To change this template use File | Settings | File Templates.
--
local config = require "lion.ext.config"
local json  = require "cjson"
local ext   = require "lion.ext.table"
local http   = require "lion.ext.http"
local consul = require "lion.client.consul"

local _M ={
    _VERSION = "1.0.0"
}

--- content_by_lua*
--
function _M.run()
    local consulConfig = config.get('consul')
    local client = consul:new(nil,consulConfig)

    return json.encode(client)

    -- local enableApp = config.get('enableApp')
     --return tostring(enableApp)

    -- ngx.header['Content-Type']="text/html;charset=utf-8"
    -- local status,body,header = http.request("get","http://www.baidu.com")
    -- return body
end

return _M
