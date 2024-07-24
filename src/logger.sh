default_handler(){
    local message=$1
    local level=$2
    local stack_trace=`trace_call`
    local json=$(cat <<EOF
{
  "message": "$message",
  "level": "$level",
  "stack_trace": "$stack_trace",
}
EOF
)
    echo $json >> log.log
}
export -f default_handler

