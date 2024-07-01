# order 10

CHILD_PIDS=()

add_new_pid_for_killing(){
    local pid=$1
    CHILD_PIDS+=("$pid")
}
export -f add_new_pid_for_killing

cleanup(){
    for pid in "${CHILD_PIDS[@]}"
    do
        kill $pid
    done
}

process_killer_start(){
    trap cleanup EXIT
}