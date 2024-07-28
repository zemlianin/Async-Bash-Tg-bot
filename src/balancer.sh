#!/bin/bash

WORKER_FIFO_LIST=()
declare -A CHAT_DICTIONARY

balancer_process() {
  local fifo="$NOTIFICATIONS_FIFO"
  
  while IFS= read -r notification; do
    if [[ $notification != *"!"* ]]; then
      chat_id="$notification"
      ((CHAT_DICTIONARY["$chat_id"]++))
      echo "Балансер заметил сообщение"
    else
      chat_id="${notification#!}"

      update_worker_status $chat_id
    fi
    update_workers
    balance
  done < "$NOTIFICATIONS_FIFO"
}

update_worker_status() {
    local target_id="$1"
    local updated_list=()
    
    for entry in "${WORKER_FIFO_LIST[@]}"; do
        IFS=":" read -r pid chat_id <<< "$entry"
        
        if [[ "$chat_id" == "$target_id" ]]; then
            updated_list+=("$pid:0")
        else
            updated_list+=("$entry")
        fi
    done

    WORKER_FIFO_LIST=("${updated_list[@]}")
}

update_workers() {
    for fifo in "$WORKERS_FIFO_DIR"/*; do
        if [[ -p "$fifo" ]]; then
            pid=$(basename "$fifo")
            if [[ ! " ${WORKER_FIFO_LIST[*]} " == *"$pid"* ]]; then
                WORKER_FIFO_LIST+=("$pid:0")
                echo "Добавлен новый воркер с PID: $pid"
            fi
        fi
    done
}

balance() {
  for i in "${!WORKER_FIFO_LIST[@]}"; do
      IFS=":" read -r worker_pid chat_id <<< "${WORKER_FIFO_LIST[i]}"

      if [[ "$chat_id" == "0" ]]; then
          for current_chat_id in "${!CHAT_DICTIONARY[@]}"; do
              if [[ "${CHAT_DICTIONARY[$current_chat_id]}" -gt 0 
              && ! "${WORKER_FIFO_LIST[*]}" =~ "$current_chat_id" ]]; then
                  echo "$worker_pid:$current_chat_id"
                  WORKER_FIFO_LIST[i]="$worker_pid:$current_chat_id"

                  ((CHAT_DICTIONARY[$current_chat_id]--))

                  if [[ "${CHAT_DICTIONARY[$current_chat_id]}" -le 0 ]]; then
                      unset CHAT_DICTIONARY[$current_chat_id]
                  fi

                  local fifo="$WORKERS_FIFO_DIR/$worker_pid"
                  echo "$current_chat_id" > "$fifo"
                  echo "Назначен chat_id $current_chat_id воркеру $worker_pid"
                  break
              fi
          done
      fi
  done
}