worker_start(){
    local pid=$BASHPID
    local fifo="$WORKERS_FIFO_DIR/$pid"
    
    mkdir -p "$WORKERS_FIFO_DIR"
    mkdir -p "$CHAR_STATES_DIR"

    if [[ ! -p "$fifo" ]]; then
        trap worker_cleanup SIGINT SIGTERM SIGHUP EXIT
        mkfifo "$fifo"
        echo "FIFO $fifo создано."
    fi
}

worker_cleanup() {
    local pid=$BASHPID
    local fifo="$WORKERS_FIFO_DIR/$pid"
    rm -f "$fifo"
    exit
}

process_message() {
    worker_start

    local pid=$BASHPID
    local fifo="$WORKERS_FIFO_DIR/$pid"

    if read -r chat_id < "$fifo"; then
      process_message_base $chat_id
      echo "!$chat_id" > "$NOTIFICATIONS_FIFO"
    fi
}

process_message_base() {
    local chat_id=$1
    local state_file="$CHAR_STATES_DIR/${chat_id}.json"
    local fifo_file="$BASE_FIFO_DIR/$chat_id"
    local state=()

    if [[ -f "$state_file" ]]; then
        readarray -t state < <(jq -r '.[]' "$state_file")
    else
        state=("ALREADY_STARTED" 1)
        echo "$(jq -n --argjson arr "$(printf '%s\n' "${state[@]}" | jq -R . | jq -s .)" '$arr')" > "$state_file"
        send_message "$chat_id" "Привет! Это твое первое сообщение"
    fi

    if [[ "${state[0]}" == "ALREADY_STARTED"* ]]; then
        local message_count=${state[1]}
        ((message_count++))
        state[1]=$message_count

        if [[ -f "$fifo_file" ]]; then
                text=$(awk 'NR==1{print $0; next}{print $0 > FILENAME}' "$fifo_file" | awk -F';' '{print $1}')
                sed -i '1d' "$fifo_file"
        fi

        echo "$(jq -n --argjson arr "$(printf '%s\n' "${state[@]}" | jq -R . | jq -s .)" '$arr')" > "$state_file"

        send_message "$chat_id" "\"$text\" - это твое сообщение номер ${message_count}"
    fi
}


send_message() {
    local chat_id=$1
    local message=$2
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$chat_id" -d text="$message"
}