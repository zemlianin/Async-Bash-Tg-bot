init_balancer(){
  export WORKER_FIFO_LIST=()
}

balancer_process() {
  local fifo="$NOTIFICATIONS_FIFO"
  echo "$fifo"

  echo "Вне цикла"
  
  while IFS= read -r notification; do
    chat_id="${notification%:}"
      
    ((CHAT_DICTIONARY["$chat_id"]++))

    for id in "${!CHAT_DICTIONARY[@]}"; do
      echo "Chat ID $id has ${CHAT_DICTIONARY[$id]} messages."
    done

    update_workers
    balance
  done < "$NOTIFICATIONS_FIFO"
}

update_workers() {
    for fifo in "$WORKERS_FIFO_DIR"/*; do
        if [[ -p "$fifo" ]]; then
            pid=$(basename "$fifo")
            if [[ ! " ${WORKER_FIFO_LIST[@]} " =~ " ${pid} " ]]; then
                WORKER_FIFO_LIST+=("$pid")
                echo "Добавлен новый воркер с PID: $pid"
            fi
        fi
    done
}

balance() {
  
}