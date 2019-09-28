--
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 11:40 AM
-- To change this template use File | Settings | File Templates.
--
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

return _M


