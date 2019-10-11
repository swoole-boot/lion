-- Application
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 18:34
-- To change this template use File | Settings | File Templates.
--
local lion = require("lion.lion")

local _M = {
    _VERSION = '1.x',
}

--- ########################从上到下为ngx_lua生命周期##############################

--- init_by_lua*
--- @param srcPath string  项目物理路径
---
function _M.init(srcPath)
    lion.initConfig(srcPath)

    ---执行扩展
    require ("events.init").run()
end

--- init_worker_by_lua*
--
function _M.initWork()
    lion.sysncConsul2NgxShared()

    require ("events.initwork").run()
end

--- rewrite_by_lua*
--
function _M.rewrite()
    lion.service2Header()

    local enableApp = require("lion.ext.config").get("enableApp")
    if enableApp then
        require("lion.lion").initContext()
        lion.dispatcher()
    end

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
    require("events.content").run()
end

--- header_filter_by_lua*
--
function _M.headerFilter()
    lion.setServerName()

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

