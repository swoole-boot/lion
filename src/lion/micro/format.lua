-- 微服务扩展
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 11:40 AM
-- To change this template use File | Settings | File Templates.
--
local ext = require("lion.extension")

local _M ={
    _VERSION = "1.0.0"
}

---将consul服务格式化
---@param nodeList table 从consul中查询出来的nodeList
---
function _M.consul(nodeList)
    if ext.empty(nodeList) then
        return nodeList
    end

    local serviceList = {}
    local service = require("lion.micro.service")

    for index,value in pairs(nodeList) do
        local item = {}
        item.dc        = value.Datacenter
        item.node      = value.Node
        item.name      = value.ServiceName
        item.port      = value.ServicePort

        if not ext.empty(value.TaggedAddresses) then
            item.wan       = value.TaggedAddresses.wan
        else
            item.wan = service.wan
        end

        item.address   = ext.emptyDefault(value.ServiceAddress, value.Address)
        item.protocol  = ext.emptyDefault(value.ServiceMeta.protocol, service.protocol)
        item.path      = ext.emptyDefault(value.ServiceMeta.path, service.path)

        value.ServiceMeta.path = nil
        value.ServiceMeta.protocol = nil
        value.ServiceMeta.handler  = nil

        -- 如果协议存在
        if not ext.empty(item.protocol) then
            item.funcs = value.ServiceMeta
        else
            item.funcs = service.funcs
        end

        table.insert(serviceList, item)
    end
    return serviceList
end

return _M