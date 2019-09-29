# lion
lion

# 网关

# 1.服务基础架构设计

![架构图](https://github.com/swoole-boot/swoole-boot/blob/master/swoole-boot-micro-server.png?raw=true)

# 2.openresty安装教程

## 2.1 安装依赖

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

## 2.2 安装openresty

[点击跳转](http://openresty.org/cn/linux-packages.html)

## 3.lion项目目录

```
-- lion
  -- libs               第三方lua包目录
  -- clibs              第三方c包目录
  -- config             配置目录
     -- nginx.conf      nginx配置文件
     -- servers         虚拟主机目录
     -- lion.json       lion应用配置文件，会在init_by_lua_file脚本添加nginx.shared.config中
  -- src                源码包目录
     -- lion            lion源码包目录
     -- app             mc目录,可以做mock，也可以做http(s)接口开发
     -- events          ngx_lua生命周期事件handler，可以自行扩展，在相应生命周期会执行相应的run方法
  -- data               临时数据目录
     -- logs            日志目录
  -- nginx.sh           nginx进程管理工具
```

## 4.nginx进程管理

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

## 5.nginx-lua生命周期

![image](https://github.com/swoole-boot/lion/blob/master/life.png?raw=true)