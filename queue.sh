#!/usr/bin/bash

# 定义全局默认参数
argc=0  # 命令行参数个数
args="" # 命令参数
PHP_EXE=$(which php) # php bin
__DIR__=$(cd `dirname $0`;pwd) # 当前文件路径
artisan=${__DIR__}/artisan

__ENV_FILE__=${__DIR__}/.env # 配置文件路径
__ENV_PHP__=${__DIR__}/php_env.ini # php env
__ENV_QUEUE__=${__DIR__}/queue.ini # queue env

# 默认项目目录
project_dir=$(dirname $(pwd))

# 读取文件
# read file with line
function readFile(){
     file=$1
     if [[ -f ${file} ]] ; then
        cat ${file} | while read LINE
        do
               echo ${LINE}
        done
        unset  file
        return 0
     fi
     return 1
}

# 读取配置
# read project config
function config(){
    tmp=""
    php=""
    # 读取配置 项目目录
    if [[ -f ${__ENV_FILE__} ]] ; then
        tmp=`readFile ${__ENV_FILE__}`
    fi
    # 读取配置 项目php
    if [[ -f ${__ENV_PHP__} ]] ; then
           php=`readFile ${__ENV_PHP__}`
    fi
    # project
    if [[  -n "${tmp}"   ]] ; then
            project_dir=${tmp}
    fi
    # php
    if [[ -n "${php}"  ]] ; then
            PHP_EXE=${php}
    fi
    unset tmp php
}

# 重启
# restart queue 
function restart(){
      # linux
      # ${PHP_EXE} ${artisan} queue:restart

      # cygwin win
      stop
      start
      echo "restart ok ..."
}

# 初始化信息
# init script config and var
function init(){
    config
    argc=${#}
    args=${*}
    artisan=${project_dir}/artisan
}

# 提示
# help menu
function helpMenu() {
    echo "Desc queue script"
    echo "options : "
    echo " restart, start,stop,status "
    echo "eg : queue.sh stop"
    echo "eg : queue.sh start"
    echo "eg : queue.sh restart"
    echo "eg : queue.sh status"
}

# 手动回收变量
# 可以不调用
function gc() {
    unset argc argc PHP_EXE artisan params option __DIR__ __ENV_FILE__ __ENV_PHP__ __ENV_QUEUE__
}

# 是否为数字
# is number var
function isNumber() {
   # 加法测试
   expr $1 "+" 10 &> /dev/null
   ret=$?
   if [[ ${ret} -eq 0 ]] ; then
         echo 1
   else
        echo 0
   fi
}

# 启动队列
# start queue
function start(){
   if [[ ! -f ${__ENV_QUEUE__} ]] ;then
        echo " queue config not exist"
        return 1
   fi
   # 启动队列进程数
   count=$1
   # 判断 启动数量
   if [[ -z "${count}"   ]] ; then
        count=1
   fi
   # 判断是否为数字
   if [[ "`isNumber ${count}`" -eq "0" ]] ; then
      count=1
   fi
   # start queue
   cat ${__ENV_QUEUE__} | while read queue
   do
       if [[ -n "${queue}" ]] ; then
          echo ${PHP_EXE} ${artisan} queue:work ${queue}
          for (( i=0; i < ${count}; ++i )); do
              ${PHP_EXE} ${artisan} queue:work ${queue}  >> /dev/null 2>&1 &
          done
       fi
   done
   # 清理
   unset queue count
   return 0
}

# 停止 队列
# stop queue
function stop() {
     # linux
     #ps -ef | grep "${artisan} queue:work" | grep -v grep | awk '{print $2}' | xargs kill
     # cygwin win
     pid=`ps -ef | grep "${PHP_EXE}" | grep -v grep | awk '{print $2}'`

     if [[ -n ${pid}  ]] ;then
         echo ${pid} | xargs kill
         echo "进程已全部停止..."
     else
            echo "无队列"
     fi
     sleep 2
}

# 队列状态
# status for queue
function status() {
     # linux
     #ps -ef | grep "${artisan} queue:work" | grep -v grep
     # cygwin win
     ps -ef | grep "${PHP_EXE}" | grep -v grep
}

# 主要逻辑
# logic controller
function main(){
    init ${*}
    # 参数个数
    if [[  ${argc} -le 0 ]] ; then
        helpMenu
        gc
        return
    fi
    # 判断项目脚本是否存在
    if [[ ! -f  ${artisan} ]] ; then
         echo "project artisan script not find !"
         gc
         return 1
    fi
     # 判断php是否存在
    if [[ ! -f  ${PHP_EXE} ]] ; then
         echo "php  bin not find !"
         gc
         return 1
    fi
    # 命令选项
    option=$1
    # 移除多余 [参数向后移动一位，第一参数被移除]
    shift
    # 选项参数
    params=${*}
    # 逻辑控制
    case ${option} in
      start)
         start ${params}
      ;;
      restart)
         restart ${params}
      ;;
      stop)
         stop ${params}
       ;;
      status)
         status ${params}
      ;;
      *|help)
         if [[  "${option}" != "help" ]] ; then
             echo "you input command option  [ ${option} ] no support "
         fi
         helpMenu ${params}
      ;;
    esac
    gc
}

# start script logic
main $*
