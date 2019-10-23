# lion网关

目录
====

* [服务基础架构设计](#服务基础架构设计)
* [openresty安装教程](#openresty安装教程)
* [lion项目目录](#lion项目目录)
* [nginx进程管理](#nginx进程管理)
* [压力测试](#压力测试)
* [traffic限流与降级](#traffic限流与降级)
* [coroutine](#coroutine)
* [nginx-lua生命周期](#nginx-lua生命周期)

服务基础架构设计
================

![架构图](https://github.com/swoole-boot/swoole-boot/blob/master/swoole-boot-micro-server.png?raw=true)

[回到目录](#目录)

openresty安装教程
================

## 安装依赖

您必须将这些库 perl 5.6.1+, libpcre, libssl安装在您的电脑之中。 对于 Linux来说, 您需要确认使用 ldconfig 命令，让其在您的系统环境路径中能找到它们。

* Debian 和 Ubuntu 用户

```bash
apt-get install libpcre3-dev \
    libssl-dev perl make build-essential curl
```

* Fedora 和 RedHat 用户

```bash
yum install pcre-devel openssl-devel gcc curl
```

## 安装openresty

[点击跳转](http://openresty.org/cn/linux-packages.html)

[回到目录](#目录)

lion项目目录
============

```
-- lion
  -- libs               第三方lua包目录
  -- clibs              第三方c包目录
  -- config             配置目录
     -- nginx.conf      nginx配置文件
     -- servers         虚拟主机目录
     -- lion.json       lion应用配置文件，会在init_by_lua_block事件添加nginx.shared.config中
  -- src                源码包目录
     -- lion            lion源码包目录
     -- app             mc目录,可以做mock，也可以做http(s)接口开发
     -- events          ngx_lua生命周期事件handler，可以自行扩展，在相应生命周期会执行相应的run方法
  -- data               临时数据目录
     -- logs            日志目录
  -- nginx.sh           nginx进程管理工具
```

nginx进程管理
============

```bash
#启动
/yourpath/lion/nginx.sh start
#停止
/yourpath/lion/nginx.sh stop
#平滑重启
/yourpath/lion/nginx.sh reload
#重启
/yourpath/lion/nginx.sh restart
```

[回到目录](#目录)

压力测试
=======

## 调用端配置

|工具|操作系统|CPU|内存|
|:--|:--|:--|:--|
|jmeter|Windows 10专业版|Intel(R) Core(TM) i7-8700 CPU @ 3.2GHz|16.0 GB|

## lion服务端配置

|openresty版本|操作系统|CPU|内存|
|:------------|:------|:--|:---|
|1.15.8.2|CentOS Linux release 7.2.1511 (Core)|Intel(R) Xeon(R) CPU E5-2630 v3 @ 2.40GHz 4核|8.0 GB|

## 参数

![线程配置](https://github.com/swoole-boot/lion/blob/master/img/jmeter.png?raw=true)

![地址](https://github.com/swoole-boot/lion/blob/master/img/jmeter-url.png?raw=true)

## 测试结果

* lion服务端cpu占用情况：

![lion服务端cpu占用情况](https://github.com/swoole-boot/lion/blob/master/img/htop.png?raw=true)

* 响应时间曲线：

![rt](https://github.com/swoole-boot/lion/blob/master/img/rt.png?raw=true)

* 结果汇总：

![汇总](https://github.com/swoole-boot/lion/blob/master/img/census.png?raw=true)

## 结果分析

* 测试过程中，lion服务器还有其他docker容器和服务，真实的吞吐量应该比测试结果还要高一些
* 通过响应时间曲线可以看到平均响应时间远不到1毫秒
* 测试过程，CPU占用51.55%
* 总样本数量为828592，100%成功，吞吐量约1.33万/秒

[回到目录](#目录)

traffic限流与降级
================

## lion.limit.traffic的使用,目前实现了基于redis的限速

### ngx

### redis,使用redis作为限速，推荐使用consul作为限速配置中心

* 限速算法

![traffic](https://github.com/swoole-boot/lion/blob/master/img/traffic.png?raw=true)

* 由于以上算法要保证并发竞争问题，所以以上算法是通过redis_lua执行，代码也可以通过php-redis调用，核心代码如下：
```lua
--限速key
local key         = ARGV[1]

--限速阈值
local limit       = ARGV[2]
limit             = tonumber(limit)

--要求前十个字节是unix时间戳
local microTimeId = ARGV[3]
local time        = tonumber(string.sub(microTimeId, 1, 10))

--时间区间
local zone        = tonumber(ARGV[4])

local length = redis.call("LLEN", key)
if length < limit then
    redis.call("LPUSH", key, microTimeId)
    redis.call("EXPIRE", key, zone + 1)
    return 1
else
    local endId    = redis.call("LINDEX", key, limit - 1)
    local timespan = time - tonumber(string.sub(endId, 1, 10))
    if timespan >= zone then
        redis.call("LPUSH", key, microTimeId)
        redis.call("EXPIRE", key, zone + 1)
        redis.call("RPOP", key)
        return 1
    else
        return 0
    end
end
```

* consul默认配置使用kv,默认key为/kv/lion-gateway/rate-limit，配置示例值：

```json
{
  "driver":{
  	"class":"lion.limit.redis",
    "host":"192.168.1.128",
    "port":"6379",
    "auth":"123456",
    "db":"1"
  },
  "rules":[
    {"path":"product/45.html","type":"ip","zone":"1","limit":"60","error_status":"200"},
  	{"path":"/","type":"all","zone":"6","limit":"10","error_result":"{\"code\":\"200\",\"data\":\"\",\"msg\":\"晚点再来\"}","error_status":"200"}
  ]
}
```

[回到目录](#目录)

coroutine 
=========

* 基于ngx.thread

## lion.ext.thread.multi的使用

```lua
local function func1(param)
    ngx.sleep(5)
    return param.time
end

local result = require("lion.ext.thread").multi({
    {
        func=func1,
        param={
            time = ngx.time()
        }
    },
    {
        --- 传匿名函数
        func=function()
            ngx.sleep(4)
            return "func2"
        end
    }
})

---result:
{
    { true, 1571732981 },
    { true, "func2" }
}
```

## 分析：

* func1和匿名函数是并发执行，执行总时间为MAX(func1,匿名函数)，以上代码总时间为5
* lion.ext.thread.multi返回结果和传入参数顺序一致，和执行时间无关

[回到目录](#目录)

nginx-lua生命周期
================

![image](https://github.com/swoole-boot/lion/blob/master/life.png?raw=true)

[回到目录](#目录)