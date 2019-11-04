-- traffic
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 18:26
-- To change this template use File | Settings | File Templates.
--
local config = require "lion.ext.config"
local ext    = require "lion.extension"

---默认超速响应body配置
---
local defaultLimitMsg = "{\"code\":\"403\",\"data\":\"{}\",\"msg\":\"请求过于频繁\"}"

local _M = {
    _VERSION = '1.0.0'
}

---获取匹配到的限速rule
---@param rules table
---@return table|nil
---
function _M.getRule(rules)
    for _,rule in pairs(rules) do
        if rule["path"] then
            rule.matches = { string.match(ngx.var.uri, rule["path"]) }
            if next(rule.matches) ~= nil then
                return rule
            end
        end
    end

    return nil
end

---通用限速和降级
---
function _M.access()
    --- 获取限速配置
    local limitConfig = config.rateLimitConfig()
    if ext.empty(limitConfig) then
        return 1
    end

    --- 如果没有配置规则，通过
    if ext.empty(limitConfig.rules) then
        return 1
    end

    --- 没有匹配到限速规则
    local rule = _M.getRule(limitConfig.rules)
    if not rule then
        return 1
    end

    local response = require "lion.ext.response"
    local limit = tonumber(rule.limit)

    --- 服务降级
    if limit < 1 then
        response.response((rule.error_result or defaultLimitMsg), ext.emptyDefault(rule.error_status, ngx.HTTP_FORBIDDEN))
        return
    end

    --- 实例化限速驱动
    local driver = require(ext.emptyDefault(limitConfig.driver.class,"lion.limit.ngx")):new(nil, { driver = limitConfig.driver })
    if driver == nil then
        return 1
    end

    local key = rule.path
    if rule.type == "ip" then
        key = key..":"..ngx.var.remote_addr
    end

    --- 拿令牌
    local token = driver:token(key, limit, tonumber(rule.zone))
    if token then
        return 1
    end

    --- 没拿到令牌
    local body = rule.error_result or defaultLimitMsg
    response.response(body, ext.emptyDefault(rule.error_status, ngx.HTTP_FORBIDDEN))
end

return _M