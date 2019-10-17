-- redis扩展
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 11:40 AM
-- To change this template use File | Settings | File Templates.
--
local redis  = require "resty.redis"
local ext    = require "lion.extension"

local _M ={
    _VERSION = '1.0.0',
    host     =  "",
    port     =  6379,
    auth     = "",
    db       = 0,
    timeout  = 1, --- 单位s
    client   = nil
}

function _M:new(client,config)
    client = client or {}
    setmetatable(client,self)
    self.__index = self

    if config and ext.isTable(config) then
        ext.block(self,config)
    end

    return client
end

---获取redis client
---
function _M:redis()
    if self.client then
        return self.client
    end

    self.client = redis:new()
    self.client:set_timeout(self.timeout * 1000)
    local ok, err = self.client:connect(self.host,self.port)
    if not ok then
        self.client = nil
        ngx.log(ngx.ERR,"failed to connect: ", err)
        return nil
    end

    if not ext.empty(self.auth) then
        ok, err = self.client:auth(self.auth)
        if not ok then
            self.client = nil
            ngx.log(ngx.ERR, 'redis[',self.host,':', self.port,'] auth[',self.auth,'] error:',err)
            return nil
        end
    end

    ok, err = self.client:select(self.db)
    if not ok then
        self.client = nil
        ngx.log(ngx.ERR,'redis[',self.host,':', self.port,'] select db[',self.db,'] error:',err)
        return nil
    end

    return self.client
end

--{{{ 1. list
---@param key string
---@return  number    the list length
---
function _M:llen(key)
    return self:redis():llen(key)
end

---
---@param key string
---@param key string
---@return number    the list length
---
function _M:lpush(key, value)
    return self:redis():lpush(key, value)
end

---
---@param key string
---@return string
---
function _M:rpop(key)
    return self:redis():rpop(key)
end

---
---@param key   string
---@param index number
---@return string
---
function _M:lindex(key, index)
    return self:redis():lindex(key, index)
end
--}}}

function _M:script(cmd, ...)
    return self:redis():script(cmd, ...)
end

function _M:eval(script)
    return self:redis():eval(script)
end

function _M:evalSha(hash, ...)
    return self:redis():evalSha(hash, ...)
end

return _M