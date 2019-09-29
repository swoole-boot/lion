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
-- @param filename
--
function _M.read(filename)
    local file = io.open(filename,'r')
    if file then
        return file:read('a')
    end
    return ''
end

return _M

