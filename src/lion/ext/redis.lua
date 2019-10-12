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
        local auth = {self.client:auth(self.auth)}
        ngx.log(ngx.INFO,require("cjson").encode(auth))
    end
end

return _M