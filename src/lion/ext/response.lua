-- response扩展
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 11:40 AM
-- To change this template use File | Settings | File Templates.
--

--- ngx.HTTP_CONTINUE (100) (first added in the v0.9.20 release)
--- ngx.HTTP_SWITCHING_PROTOCOLS (101) (first added in the v0.9.20 release)
--- ngx.HTTP_OK (200)
--- ngx.HTTP_CREATED (201)
--- ngx.HTTP_ACCEPTED (202) (first added in the v0.9.20 release)
--- ngx.HTTP_NO_CONTENT (204) (first added in the v0.9.20 release)
--- ngx.HTTP_PARTIAL_CONTENT (206) (first added in the v0.9.20 release)
--- ngx.HTTP_SPECIAL_RESPONSE (300)
--- ngx.HTTP_MOVED_PERMANENTLY (301)
--- ngx.HTTP_MOVED_TEMPORARILY (302)
--- ngx.HTTP_SEE_OTHER (303)
--- ngx.HTTP_NOT_MODIFIED (304)
--- ngx.HTTP_TEMPORARY_REDIRECT (307) (first added in the v0.9.20 release)
--- ngx.HTTP_PERMANENT_REDIRECT (308)
--- ngx.HTTP_BAD_REQUEST (400)
--- ngx.HTTP_UNAUTHORIZED (401)
--- ngx.HTTP_PAYMENT_REQUIRED (402) (first added in the v0.9.20 release)
--- ngx.HTTP_FORBIDDEN (403)
--- ngx.HTTP_NOT_FOUND (404)
--- ngx.HTTP_NOT_ALLOWED (405)
--- ngx.HTTP_NOT_ACCEPTABLE (406) (first added in the v0.9.20 release)
--- ngx.HTTP_REQUEST_TIMEOUT (408) (first added in the v0.9.20 release)
--- ngx.HTTP_CONFLICT (409) (first added in the v0.9.20 release)
--- ngx.HTTP_GONE (410)
--- ngx.HTTP_UPGRADE_REQUIRED (426) (first added in the v0.9.20 release)
--- ngx.HTTP_TOO_MANY_REQUESTS (429) (first added in the v0.9.20 release)
--- ngx.HTTP_CLOSE (444) (first added in the v0.9.20 release)
--- ngx.HTTP_ILLEGAL (451) (first added in the v0.9.20 release)
--- ngx.HTTP_INTERNAL_SERVER_ERROR (500)
--- ngx.HTTP_METHOD_NOT_IMPLEMENTED (501)
--- ngx.HTTP_BAD_GATEWAY (502) (first added in the v0.9.20 release)
--- ngx.HTTP_SERVICE_UNAVAILABLE (503)
--- ngx.HTTP_GATEWAY_TIMEOUT (504) (first added in the v0.3.1rc38 release)
--- ngx.HTTP_VERSION_NOT_SUPPORTED (505) (first added in the v0.9.20 release)
--- ngx.HTTP_INSUFFICIENT_STORAGE (507) (first added in the v0.9.20 release)

local ext = require "lion.extension"

local _M = {
    _VERSION = '1.0.0'
}

---
---
function _M.send()
    if not ext.empty(ngx.ctx.response.headers) then
        for key,value in pairs(ngx.ctx.response.headers) do
            ngx.header[ key ] = value
        end
    end

    ---如果回源,状态码是ngx.HTTP_OK
    if ngx.ctx.response.returnSource and ngx.ctx.response.status == ngx.HTTP_OK then
        return
    end

    ngx.status = tonumber(ngx.ctx.response.status)

    if ngx.ctx.response.body ~= nil and ngx.ctx.response.body ~= "" then
        ngx.say(ngx.ctx.response.body)
    end

    --- 通知客户端关闭
    ngx.eof()
    ngx.exit(ngx.ctx.response.status)
end

---response
---@param body    string
---@param status  number
---@param headers table
---
function _M.response(body, status, headers)
    status = status or ngx.HTTP_OK
    status = tonumber(status)
    if ext.isTable(headers) then
        for key,value in pairs(headers) do
            ngx.header[ key ] = value
        end
    end

    ngx.status = status
    ngx.say(body)
    ngx.eof()
    ngx.exit(status)
end

return _M