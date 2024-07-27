#!/bin/bash

default_logger(){
    local message=$1
    local level=$2
    local current_time=$(date +"%Y-%m-%d %H:%M:%S")
    local stack_trace=`trace_call`
    local json=$(cat <<EOF
{
  "time": "$current_time",
  "message": "$message",
  "level": "$level",
  "stack_trace": "$stack_trace",
}
EOF
)
    echo $json >> $LOG_FILE
}
export -f default_logger