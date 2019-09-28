--
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 18:34
-- To change this template use File | Settings | File Templates.
--
local _M = {
    _VERSION = '1.x',
}

-- ########################从上到下为ngx_lua生命周期##############################

--- 初始化
-- @param string configFileName 配置文件物理路径
--
function _M.init(configFileName)
    -- 文件io驱动
    local file = require "lion.ext.file"
    local json   = require "cjson"
    -- 读取配置文件
    local config = file.read(configFileName)
    ---放入nginx cache
    local shared       = require "lion.ext.shared"
    shared.mset(ngx.shared.config,json.decode(config))
end

--- 工作进程初始化
--
function _M.initWork()

end

function _M.rewrite()

end

function _M.access()

end

function _M.content()
    local share = require "lion.ext.shared"
    local json  = require "cjson"
    local ext   = require "lion.ext.table"
    local http   = require "lion.ext.http"

    local consul = share.get(ngx.shared.config,'consul')
    return json.encode(consul)

    -- ngx.header['Content-Type']="text/html;charset=utf-8"
    -- local status,body,header = http.request("get","http://www.baidu.com")
    -- return body
end

function _M.balancer()

end

function _M.headerFilter()

end

function _M.bodyFilter()

end

function _M.log()

end

return _M

