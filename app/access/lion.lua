--
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 15:06
-- To change this template use File | Settings | File Templates.
--

local app    = require "lion.application"
local share = require "lion.ext.shared"
local json  = require "cjson"
local consul = share.get(ngx.shared.config,'consul')

ngx.say(json.encode(consul))
