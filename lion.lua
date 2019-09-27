--
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 15:06
-- To change this template use File | Settings | File Templates.
--
local app = require "lion.application"
local json= require "cjson"

local output = json.encode({"Welcome to "..app.name.." !"})

ngx.say(output)