-- route
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/29
-- Time: 10:37
-- To change this template use File | Settings | File Templates.
--
local ext      = require("lion.extension")
local config   = require("lion.ext.config")
local context  = ngx.ctx

local _M = {
    _VERSION = "1.0.0"
}

---格式化rules
---@param rules table
---
function _M.formatRules(rules)
    local ruleList = {}
    for rule,route in pairs(rules) do
        local item = {
            pattern = rule,
            params  = {},
            route   = route
        }

        for param in string.gmatch(rule, "(%w*):") do
            table.insert(item.params,param)
            item.pattern = string.gsub(item.pattern,param..":","")
        end

        table.insert(ruleList,item)
    end
    return ruleList
end

---获取格式化好的路由配置列表
---
function _M.getFormatRules()
    --- 从配置中取格式化的rules
    local rules = config.get("formatRules")
    if ext.isTable(rules) then
        return rules
    end

    --- 从配置中取rules
    rules = config.get("rules")

    --- 格式化rules
    if not ext.empty(rules) then
        rules = _M.formatRules(rules)
    end

    --- 将格式化的rules放入config并返回
    config.set("formatRules",rules)
    return rules
end

---根据路由配置匹配
---
function _M.matchRules()
    local rules = _M.getFormatRules()

    if ext.isTable(rules) then
        for _,rule in pairs(rules) do
            local matches = { string.match(context.request.uri,rule.pattern) }
            --- 匹配到路由
            if not ext.empty(matches) then
                for index,value in pairs(matches) do
                    local param = rule.params[ index ]
                    if param then
                        --- 将匹配到的参数值放入urlArgs中
                        ngx.ctx.request.uriArgs[ param ] = value
                    end
                end
                return rule.route
            end
        end
    end

    return false
end

---路由
---
function _M.route()
    ---优先路由匹配
    local route = _M.matchRules()
    if route then
        return route
    end

    --- 通用匹配
    local controller,action = string.match(context.request.uri,"/(%w+)/(%w+)")
    if ext.empty(controller) then
        controller = string.match(context.request.uri,"/(%w+)")

        if ext.empty(controller) then
            return config.get("defaultRoute")
        end

        return controller.."/".."index"
    end

    return controller.."/"..action
end

return _M