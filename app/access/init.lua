--
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 12:48 PM
-- To change this template use File | Settings | File Templates.
--

-- 文件io驱动
local file = require "lion.ext.file"
local json   = require "cjson"
local configFileName = "/Users/qiang/code/jhq0113/lion/config/lion.json"

-- 读取配置文件
local config = file.read(configFileName)

---放入nginx cache
local shared       = require "lion.ext.shared"
shared.mset(ngx.shared.config,json.decode(config))

