#!/bin/bash
#resty目录
RESTYPATH=/usr/local/openresty
#nginx
NGINX="$RESTYPATH/nginx/sbin/nginx"
#lion项目目录
LIONPATH=$(cd `dirname $0`; pwd)

CMDMAP=("start" "stop" "reload" "restart")

#获取命令
getCommand() {
  if [ -z $1 ]
  then
    return 0
  fi

  index=0
  for cmd in ${CMDMAP[@]}
  do
    if [ $cmd == $1 ]
    then
      return $index
    fi

    let index++
  done

  echo "param should be one of :【${CMDMAP[@]}】"

  exit 1
}

#校验配置文件
checkConfig() {
  #nginx配置文件
  NGINXCONF="$LIONPATH/config/nginx.conf"
  RESULT=$($NGINX -t -c $NGINXCONF 2>&1)
  SUCCESSTAG="successful"
  if [[ $RESULT =~ $SUCCESSTAG ]]
  then
    return 1
  fi
    $NGINX -t -c $NGINXCONF
    return 0
}

#检测nginx服务是否还在
nginxLive() {
  num=`ps -ef |grep "nginx" |grep -v "grep"|grep -v "nginx.sh"|wc -l`
  if [[ $num -lt 1 ]]
  then
    return 0
  fi
  return 1
}

start() {
  nginxLive
  if [[ $? == 1 ]]
  then
    echo -e "\033[31m nginx has been lived \033[0m"
    exit 1
  fi

  echo -e "\033[33m start the openresty service \033[0m"
  $NGINX -c $NGINXCONF
  echo -e "\033[32m start success \033[0m"
}

stop() {
  nginxLive
  if [[ $? == 0 ]]
  then
    echo -e "\033[31m nginx has been not lived \033[0m"
    exit 1
  fi

  echo -e "\033[33m stop the openresty service \033[0m"
  $NGINX -s stop
  echo -e "\033[32m stop success \033[0m"
}

reload() {
  nginxLive
  if [[ $? == 0 ]]
  then
    echo -e "\033[31m nginx has been not lived \033[0m"
    exit 1
  fi

  echo -e "\033[33m reload the openresty service \033[0m"
  $NGINX -s reload
  echo -e "\033[32m reload success \033[0m"
}

restart() {
  nginxLive
  if [[ $? == 1 ]]
  then
    stop
  fi

  start
}

#获取命令
getCommand $1
CMD=${CMDMAP[$?]}

#不是停止nginx需要校验配置文件
if [ $CMD != "stop" ]
then
  checkConfig
  if [[ $? == 0 ]]
  then
    exit 1
  fi
fi

#执行命令
$CMD
