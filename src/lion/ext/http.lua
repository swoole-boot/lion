-- Http扩展
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 11:40 AM
-- To change this template use File | Settings | File Templates.
--

local http      = require "resty.http"
local json      = require "cjson"
local ext       = require "lion.extension"
local tableExt  = require "lion.ext.table"

local _M = {
    _VERSION = '1.0.0'
}

--- 将ip转换为值
-- @param ip
--
function _M.ip2long(ip)
    local num = 0
    ip : gsub("%d+", function(s)
        num = num * 256 + tonumber(s)
    end)
    return num
end

--- 构建http参数
-- @param params
--
function _M.httpBuildQuery(params)
    if ext.empty(params) then
        return ""
    end

    if not ext.isTable(params) then
        return params
    end

    local query = {}
    for key,value in pairs(params) do
        if ext.isTable(value) then
            table.insert(query,key.."="..json.encode(value))
        else
            table.insert(query,key.."="..value)
        end
    end

    return table.concat(query,"&")
end

--- 发http请求
-- @param string method
-- @param string url
-- @param table  params
-- @param table  headers
-- @param table  options
--
function _M.request(method,url,params,headers,options)
    local httpc = http.new()
    options = options or {}
    headers = headers or {}
    options = tableExt.merge({
        method = string.upper(method),
        body = _M.httpBuildQuery(params),
        headers = tableExt.merge({
            ["Content-Type"] = "application/x-www-form-urlencoded",
        },headers),
        keepalive_timeout = 60,
        keepalive_pool = 10
    },options);

    local res, err = httpc:request_uri(url, options)

    if not res then
        return -1, err, {}
    end

    return res.status, res.body, res.headers
end

return _M


