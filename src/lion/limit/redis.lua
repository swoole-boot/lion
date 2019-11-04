-- redis限速
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 18:26
-- To change this template use File | Settings | File Templates.
--
local ext    = require "lion.extension"

---获取token的redis lua脚本
---
local tokenScript = [[
        --限速key
        local key         = ARGV[1]

        --限速阈值
        local limit       = ARGV[2]
        limit             = tonumber(limit)

        --要求前十个字节是unix时间戳
        local microTimeId = ARGV[3]
        local time        = tonumber(string.sub(microTimeId, 1, 10))

        --时间区间
        local zone        = tonumber(ARGV[4])

        local length = redis.call("LLEN", key)
        if length < limit then
            redis.call("LPUSH", key, microTimeId)
            redis.call("EXPIRE", key, zone + 1)
            return 1
        else
            local endId    = redis.call("LINDEX", key, limit - 1)
            local timespan = time - tonumber(string.sub(endId, 1, 10))
            if timespan >= zone then
                redis.call("LPUSH", key, microTimeId)
                redis.call("EXPIRE", key, zone + 1)
                redis.call("RPOP", key)
                return 1
            else
                return 0
            end
        end
]]

local _M = {
    _VERSION = "1.0.0",
    driver   = {},
    client   = nil
}

--- 实例化
---@param instance table|nil
---@param config   table
---
function _M:new(instance, config)
    instance = instance or {}
    setmetatable(instance,self)
    self.__index = self

    if config and ext.isTable(config) then
        ext.block(self,config)
    end
    return instance
end

---获取redis实例
---
function _M:redis()
    if self.client then
        return self.client
    end

    if ext.empty(self.driver.class) then
        return nil
    end

    self.client = require("lion.ext.redis"):new(nil, self.driver)

    return self.client
end

---获得限流token
---@param key   string   关联key
---@param limit number   限制数量,如果小于1,表示服务降级
---@param zone  number   单位时间,单位为s,默认为60s
---@return string
---
function _M:token(key, limit, zone)
    local hash, err = _M:redis():script("load", tokenScript)
    if hash == false then
        ngx.log(ngx.ERR,"load tokenScript error:",err)
        return false
    end

    --- 如果个数小于1,表示被降级
    if limit < 1 then
        return false
    end

    zone = zone or 60

    local uniqueId = ext.uniqueId("",20)
    local result,error = _M:redis():evalSha(hash, 0, key, limit, uniqueId, zone)
    if error then
        ngx.log(ngx.ERR,"get token error:",error)
    end

    if result == 0 then
        return false
    end

    return uniqueId
end

return _M
