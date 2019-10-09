-- 文件扩展
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 12:53 PM
-- To change this template use File | Settings | File Templates.
--
local _M ={
    _VERSION = '1.0.0'
}

--- 读取整个文件
--- @param filename string
---
function _M.read(filename)
    local file = io.open(filename,'r')
    if file then
        return file:read('a')
    end
    return ''
end

--- 判断文件是否存在
---@param filename string
---
function _M.fileExists(filename)
    local file = io.open(filename, "rb")
    if file then
        file:close()
    end
    return file ~= nil
end

return _M

