--
-- Created by IntelliJ IDEA.
-- User: jianghaiqiang
-- Date: 2019/9/27
-- Time: 15:06
-- To change this template use File | Settings | File Templates.
--
local app     = require "lion.application"
local content = app.content();
if content then
    ngx.say(content)
end

