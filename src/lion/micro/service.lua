-- 微服务对象
-- Created by IntelliJ IDEA.
-- User: qiang
-- Date: 2019/9/28
-- Time: 11:40 AM
-- To change this template use File | Settings | File Templates.
--

return {
    dc          = "" ,               -- 数据中心
    node        = "",                -- 节点
    name        = "",                -- 服务名称
    address     = "" ,               -- lan地址
    wan         = "" ,               -- wan地址，空字符串表示不支持
    port        = 888 ,              -- 服务端口
    path        = "" ,               -- 服务路径
    protocal    = "" ,               -- 协议名称
    handler     = "" ,               -- 协议处理类
    funcs       = {} ,               -- 协议方法列表
}
