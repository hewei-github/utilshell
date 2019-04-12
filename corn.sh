#!/usr/bin/bash

work_dir=$(cd `dirname $0`;pwd)/work # 当前文件路径
script=${work_dir}/artisan

# 初始化检查
function init(){
    if [[ ! -f ${script} ]] ; then
        echo 1
    else
       echo  0
    fi
}

# 自定义毫秒定时任务
function cornAt() {
     php ${script}  run:daemon --start=corn@corn &
     php ${script}  run:daemon --start=fes_join_person@join_app &
}


# 控制
function main(){
    option=$1
    check=`init`
    if [[ "${check}" == "1" ]] ; then
            echo "script no exists"
            return 1
    fi
    if [[ ${option} -eq "" ]] ;then
            option=start
    fi
    case ${option} in
       start)
         cornAt
       ;;
       *)
         echo "you command option ${option} no support"
       ;;
    esac
}

main ${*}