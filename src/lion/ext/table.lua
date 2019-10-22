-- table扩展
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 6:20 PM
-- To change this template use File | Settings | File Templates.
--

local _M ={
    _VERSION = "1.0.0"
}

--- table合并
--- @param ...
--
function _M.merge(...)
    local tabs = {...}
    if not tabs then
        return {}
    end

    local origin = tabs[1]

    for i = 2,#tabs do
        if tabs[i] then
            for key,value in pairs(tabs[i]) do
                if type(key) == "string" then
                    origin[ key ] = value
                else
                    table.insert(origin,value)
                end
            end
        end
    end

    return origin
end

--- table洗牌
--- @param arrayList table
--
function _M.shuffle(arrayList)
    local length = #arrayList

    if length == 1 then
        return arrayList
    end

    for i=1, length do
        local j = math.random(i,length)
        arrayList[i], arrayList[j] = arrayList[j], arrayList[i]
    end
    return arrayList
end

return _M

