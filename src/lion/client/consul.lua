--
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 7:11 PM
-- To change this template use File | Settings | File Templates.
--

-- #######################调用案例##################################

--[[
    local consulConfig = config.get('consul')
    local client = consul:new(nil,consulConfig)
    local result = {}
    local time = ngx.time()
    result.create                                       = client:kvCreateDir("lion")
    result.set                                          = client:kvSet("lion/version","1.0.0")
    result.set                                          = client:kvSet("lion/version/t"..time,time)
    result.getValue, result.getValueStatus              = client:kvGetValue("lion/version/t1569747432")
    result.get, result.getStatus                        = client:kvGet("lion/version/t1569747432")
    result.getAll, result.getAllStatus                  = client:kvGetAll("lion")
    result.delete                                       = client:kvDelete("lion/version")
    result.deleteDir                                    = client:kvDeleteDir("lion")
    result.serviceList, result.serviceListStatus        = client:serviceList()
    result.datacenterList, result.datacenterStatus      = client:dcList()
    result.nodeList, result.nodeListStatus              = client:nodeList()
    result.nodeListByName, result.nodeListByNameStatus  = client:getNodeListByName("consul")
    -- 定义服务
    local service =  {
        ID= "40e4a748-2192-161a-0510-9bf59fe950b5",
        Node= "foobar",
        Address= "192.168.10.10",
        TaggedAddresses = {
            lan= "192.168.10.10",
            wan= "10.0.10.10"
        },
        NodeMeta= {
            somekey= "somevalue"
        },
        Service= {
            ID= "redis1",
            Service= "redis",
            Tags= {
                "primary",
                "v1"
            },
            Address= "127.0.0.1",
            TaggedAddresses= {
                lan= {
                    address= "127.0.0.1",
                    port= 8000
                },
                wan= {
                    address= "198.18.0.1",
                    port= 80
                }
            },
            Meta= {
                redis_version= "4.0"
            },
            Port= 8000
        },
        Check   = {
            Node = "foobar",
            CheckID = "service=redis1",
            Name   = "Redis health check",
            Notes= "Script based health check",
            Status= "passing",
            ServiceID= "redis1",
            Definition= {
                TCP= "localhost=8888",
                Interval= "5s",
                Timeout= "1s",
                DeregisterCriticalServiceAfter= "30s"
            }
        },
        SkipNodeUpdate = false
    };

    result.register   = client:register(service)
    result.deregister = client:deregister("foobar")

    json.encode(result)
]]

local http      = require "lion.ext.http"
local Client    = require "lion.client.client"
local ext       = require "lion.extension"
local tableExt  = require "lion.ext.table"
local json      = require "cjson"

local _M = {
    _VERSION = "1.0.0",
    node       = "http://127.0.0.1:8500",
    datacenter = "dc1",
    token      = ""
}

---
-- @param client
-- @param config
--
function _M:new (client,config)
    client = client or Client:new(client)
    setmetatable(client, self)
    self.__index = self
    if config and ext.isTable(config) then
         self = ext.block(self,config)
    end

    return client
end

--- 发送请求
-- @param method
-- @param path
-- @param params
-- @param header
--
function _M:request(method, path, params, header)
    header = header or {}
    if not ext.empty(self.token) then
        header["X-Consul-Token"] = self.token
    end

    local url = self.node..path
    return http.request(method,url,params,header)
end

--region #############################1.catalog操作###########################
--- 数据中心列表
--
function _M:dcList()
    local status, body, headers = self:request("GET","/v1/catalog/datacenters")
    if status ~= 200 then
        return nil, false
    end
    return json.decode(body), true
end

--- 注册服务
--- @param params table
--- @example
--[[ 
    {
        ID= "40e4a748-2192-161a-0510-9bf59fe950b5",
        Node= "foobar",
        Address= "192.168.10.10",
        TaggedAddresses = {
            lan= "192.168.10.10",
            wan= "10.0.10.10"
        },
        NodeMeta= {
          somekey= "somevalue"
        },
        Service= {
            ID= "redis1",
            Service= "redis",
            Tags= {
                "primary",
                "v1"
            },
            Address= "127.0.0.1",
            TaggedAddresses= {
                lan= {
                    address= "127.0.0.1",
                    port= 8000
                },
                wan= {
                    address= "198.18.0.1",
                    port= 80
                }
            },
            Meta= {
                redis_version= "4.0"
            },
            Port= 8000
        },
        Check   = {
            Node = "foobar",
            CheckID = "service=redis1",
            Name   = "Redis health check",
            Notes= "Script based health check",
            Status= "passing",
            ServiceID= "redis1",
            Definition= {
                TCP= "localhost=8888",
                Interval= "5s",
                Timeout= "1s",
                DeregisterCriticalServiceAfter= "30s"
            }
        },
        SkipNodeUpdate = false
    }
]]
--
function _M:register(params)
    params = params or {}
    params = tableExt.merge({
        Datacenter = self.datacenter
    },params)

    local status, body, headers = self:request("PUT", "/v1/catalog/register", json.encode(params))
    return body == "true"
end

--- 服务注销
--- @param node     string
--- @param params   table
--
function _M:deregister(node, params)
    params = params or {}
    params.Node = node
    params = tableExt.merge({
        Datacenter = self.datacenter
    },params)

    local status, body, headers = self:request("PUT","/v1/catalog/deregister",json.encode(params))
    return body == "true"
end

--- node列表
--- @param params table
--
function _M:nodeList(params)
    params = params or {}
    params = tableExt.merge({
        dc = self.datacenter
    },params)

    local status, body, headers = self:request("GET","/v1/catalog/nodes",params)
    if status ~= 200 then
        return nil, false
    end
    return json.decode(body), true
end

--- service列表
--- @param params table
--
function _M:serviceList(params)
    params = params or {}
    params = tableExt.merge({
        dc = self.datacenter
    },params)

    local status, body, headers = self:request("GET","/v1/catalog/services",params)
    if status ~= 200 then
        return nil, false
    end
    return json.decode(body), true
end

--- 根据服务名称获取节点列表
--- @param name   string
--- @param params table
--
function _M:getNodeListByName(name,params)
    params = params or {}
    params = tableExt.merge({
        dc = self.datacenter
    },params)

    local status, body, headers = self:request("GET","/v1/catalog/service/"..name,params)
    if status ~= 200 then
        return nil, false
    end
    return json.decode(body), true
end

--endregion


--region #############################2.kv操作##################################
---
--- @param key      string
--- @param value    any
--- @param params   table
--
function _M:kvSet(key, value, params)
    params = params or {}
    params = tableExt.merge({
        dc = self.datacenter
    },params)

    local status, body, headers = self:request("PUT", http.httpBuildQuery(params,"/v1/kv/"..key), value)
    return body == "true"
end

--- 创建目录
--- @param dir  string
--
function _M:kvCreateDir(dir)
    if string.sub(dir,-1) ~= "/" then
        dir = dir.."/"
    end

    return self:kvSet(dir)
end

---
--- @param key     string
--- @param params  table
--- @param decrypt boolean 是否自动解密
--
function _M:kvGet(key, params, decrypt)
    params = params or {}
    params = tableExt.merge({
        dc = self.datacenter
    },params)

    local status, body, headers = self:request("GET", "/v1/kv/"..key, params)
    if status ~= 200 then
        return nil, false
    end

    local values = json.decode(body)
    if decrypt == nil then
        decrypt = true
    end

    if decrypt then
        for k,value in pairs(values) do
            if ext.empty(value["Value"]) then
                values[ k ]["Value"] = "null"
            else
                values[ k ]["Value"] = ngx.decode_base64(value["Value"])
            end
        end
    end

    return values, true
end

---
--- @param key string
--
function _M:kvGetValue(key)
    local values, status = self:kvGet(key)
    -- 请求失败
    if status == false then
        return nil, false
    end

    if ext.empty(values) then
        return values, true
    end

    return values[1]["Value"], true
end

--- 获取整个目录下所有值
--- @param dir string
--
function _M:kvGetAll(dir)
    local values, status = self:kvGet(dir,{
        recurse = 1
    })

    -- 请求失败
    if status == false then
        return nil, false
    end

    if ext.empty(values) then
        return values, true
    end

    local kvList = {}
    for key,value in pairs(values) do
        kvList[ value["Key"] ] = value["Value"]
    end

    return kvList, true
end

--- 删除key
--- @param key        string
--- @param params     table
--
function _M:kvDelete(key, params)
    params = params or {}
    params = tableExt.merge({
        dc = self.datacenter
    },params)

    local status, body, headers = self:request("DELETE", http.httpBuildQuery(params,"/v1/kv/"..key))
    return body == "true"
end

--- 删除目录
--- @param dir string
--
function _M:kvDeleteDir(dir)
    return self:kvDelete(dir,{
        recurse = 1
    })
end
--endregion

return _M

