worker_start(){
    local pid=$$
    local fifo="$WORKERS_FIFO_DIR/$pid"

    if [[ ! -p "$fifo" ]]; then
        trap worker_cleanup SIGINT SIGTERM SIGHUP EXIT
        mkfifo "$fifo"
        echo "FIFO $fifo создано."
    fi
}

worker_cleanup() {
    local pid=$$
    local fifo="$WORKERS_FIFO_DIR/$pid"
    rm -f "$fifo"
    exit
}

process_message() {
    worker_start
    
    local fifo="$WORKERS_FIFO_DIR/$pid"

    if read -r chat_id < "$fifo"; then
      response="Worker $pid took: $chat_id"
      echo "$response"
    fi
    sleep 10
}