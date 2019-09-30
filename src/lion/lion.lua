-- Lion
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 18:34
-- To change this template use File | Settings | File Templates.
--
local config = require("lion.ext.config")
local shared = require "lion.ext.shared"
local dict   = ngx.shared.cache
local ext    = require("lion.extension")
local json   = require "cjson"

local _M = {
    _VERSION = "1.0.0"
}

----初始化配置
---@param configFileName string 配置文件物理路径
---
function _M.initConfig(configFileName)
    ---文件io驱动
    local file   = require "lion.ext.file"
    ---读取配置文件
    local configData = file.read(configFileName)
    ---放入nginx cache
    shared.mset(ngx.shared.config,json.decode(configData))
end

---同步consul中数据导ngx.shared.cache
---
function _M.sysncConsul2NgxShared()
    local consulConfig = config.get('consul')
    --没有配置consul服务
    if ext.empty(consulConfig) then
        return
    end

    -- 延时不能小于1s
    local delay = tonumber(consulConfig.delay);
    if delay < 1 then
        delay = 1
    end

    local function _syncService2NgxShared(premature)
        local lock = require("resty.lock")
        local driver = lock:new("cache",{
            timeout  = 0,          --如果1秒还没有获得锁，属于超时
            exptime  = delay
        })

        --加锁
        local isLock,_ = driver:lock("sync_service_2_ngx_shared")
        --获得锁
        if isLock ~= nil then
            _M.syncServiceFromConsul2NgxShared()
        end

        return
    end

    --创建异步触发器，马上执行
    local ok, err = ngx.timer.at(0, _syncService2NgxShared)
    if not ok then
        ngx.log(ngx.ERR, "failed to create timer.at: ", err)
    end

    --创建定时器
    ok, err = ngx.timer.every(delay, _syncService2NgxShared)
    if not ok then
        ngx.log(ngx.ERR, "failed to create timer: ", err)
    end
end

---同步服务到ngx.shared.cache
---
function _M.syncServiceFromConsul2NgxShared()
    local format = require "lion.micro.format"
    local consul = require "lion.client.consul"
    local consulConfig = config.get('consul')

    local client = consul:new(nil,consulConfig)
    --拿服务列表
    local services, serviceStatus = client:serviceList()
    --没拿到直接返回
    if ext.empty(services) then
        return
    end

    local serviceList = {}

    for serviceName,value in pairs(services) do
        local nodeList, status = client:getNodeListByName(serviceName)
        -- 获取失败或者不是一个table，直接放弃更新，防止更新错误
        if status == false or not ext.isTable(nodeList) then
            return
        end
        serviceList[ serviceName ] = format.consul(nodeList)
    end

    --更新到ngx.shared.cache
    shared.set(dict,consulConfig.serviceListKey,serviceList)
    -- ngx.log(ngx.INFO,"sysnc consul service to ngx.shared.cache")
end

---从配置中拿服务配置数据并放到http header中
---
function _M.service2Header()
    local consulConfig = config.get('consul')
    if ext.empty(consulConfig) or ext.empty(consulConfig.serviceListKey) then
        return
    end

    local serviceList = dict:get(consulConfig.serviceListKey)
    -- 如果获取到服务配置，将服务配置放到header中，否则放入"{}"防止恶意注入
    ngx.req.set_header(consulConfig.serviceListKey, ext.emptyDefault(serviceList,"{}"))
end

---设置服务器名称
---@param name string 服务器名称
---
function _M.setServerName(name)
    name = name or shared.get(ngx.shared.config,"name")
    ngx.header["Server"] = ext.emptyDefault(name,"lion-gateway")
end

return _M