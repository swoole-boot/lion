-- ngx.thread扩展
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/10/22
-- Time: 6:20 PM
-- To change this template use File | Settings | File Templates.
--

--- @example
--[[
local function func1(param)
    return param.time
end

local result = require("lion.ext.thread").multi({
    {
        func=func1,
        param={
            time = ngx.time()
        }
    },
    {
        --- 传匿名函数
        func=function()
            return "func2"
        end
    }
})

---result:
{
    {true,1571732981},
    {true,"func2"}
}
]]


local _M ={
    _VERSION = "1.0.0"
}

---批量异步执行
---@param funcList  table   function列表,如：
---@return table
---
function _M.multi(funcList)
    local threadPool = {}
    for _,func in pairs(funcList) do
        table.insert(threadPool, ngx.thread.spawn(func.func, func.param) )
    end

    local result = {}
    for index,_ in pairs(threadPool) do
        result[ index ] = { ngx.thread.wait(threadPool[ index ] ) }
    end

    return result
end

--- 异步执行
---@param func function
---@param ...
---@return thread
---
function _M.go(func,...)
    return ngx.thread.spawn(func,...)
end

return _M
