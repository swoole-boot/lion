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
        local key         = ARGV[1]
        local limit       = ARGV[2]
        local microTimeId = ARGV[3]
        local zone        = ARGV[4]

        zone        = zone or 60
        limit       = tonumber(limit)
        local time  = tonumber(string.sub(microTimeId, 1, 10))

        local length = redis.call("LLEN", key)
        if length < limit then
            length = redis.call("LPUSH", key, microTimeId)
            return 1
        else
            local endId         = redis.call("LINDEX", key, limit - 1)
            local timespan = time - tonumber(string.sub(endId, 1, 10))
            if timespan >= tonumber(zone) then
                redis.call("LPUSH", key, microTimeId)
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

function _M:token(key, limit, zone)
    local hash, err = _M:redis():script("load", tokenScript)
    if hash == false then
        ngx.log(ngx.ERR,"load tokenScript error:",err)
        return false
    end
    limit = limit or 10
    zone  = zone  or 10
    local result = _M:redis():evalSha(hash, 0, key, limit, ext.uniqueId("",20), zone)
    return result == 1
end

return _M
