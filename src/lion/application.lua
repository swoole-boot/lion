-- Application
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 18:34
-- To change this template use File | Settings | File Templates.
--
local _M = {
    _VERSION = '1.x',
}

--- ########################从上到下为ngx_lua生命周期##############################

--- init_by_lua*
-- @param string configFileName 配置文件物理路径
--
function _M.init(configFileName)
    ---文件io驱动
    local file   = require "lion.ext.file"
    local json   = require "cjson"
    local shared = require "lion.ext.shared"
    local init   = require "events.init"

    ---读取配置文件
    local config = file.read(configFileName)
    ---放入nginx cache
    shared.mset(ngx.shared.config,json.decode(config))

    ---执行扩展
    init.run()
end

--- init_worker_by_lua*
--
function _M.initWork()
    require ("events.initwork").run()
end

--- rewrite_by_lua*
--
function _M.rewrite()
    require ("events.rewrite").run()
end

--- access_by_lua*
--
function _M.access()
    require ("events.access").run()
end

--- balancer_by_lua*
--
function _M.balancer()
    require ("events.balancer").run()
end

--- content_by_lua*
--
function _M.content()
    local content       = require "events.content"
    return content.run()
end

--- header_filter_by_lua*
--
function _M.headerFilter()
    local shared = require "lion.ext.shared"
    ngx.header["Server"] = shared.get(ngx.shared.config,"name")

    require ("events.headerfilter").run()
end

--- body_filter_by_lua*
--
function _M.bodyFilter()
    require ("events.bodyfilter").run()
end

--- log_by_lua*
--
function _M.log()
    require ("events.log").run()
end

return _M

