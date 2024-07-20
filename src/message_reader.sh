reader_init() {
    mkdir -p "$BASE_FIFO_DIR"

    if [ ! -f "$LAST_UPDATE_FILE" ]; then
        echo "0" > "$LAST_UPDATE_FILE"
    fi
}

fetch_messages() {
    exec 200>"$LOCK_FILE"
    flock -n 200 || { echo "Failed to acquire lock"; continue; }

    local last_update_id=$(cat "$LAST_UPDATE_FILE")
    local messages=($(get_tg_messages $last_update_id))
    
    for message in $messages; do
      update_id=$(echo $message | jq '.update_id')
      echo "$update_id" > "$LAST_UPDATE_FILE"
      text=$(echo $message | jq -r '.text')
      echo "$text" > "$fifo"
    done

    # Освобождаем блокировку
    flock -u 200
    sleep 1
}

get_tg_messages(){
    local last_update_id=$1
    local updates=$(curl -s "https://api.telegram.org/bot$token/getUpdates?offset=$((last_update_id + 1))&timeout=10")
    local messages=$(echo $updates | jq -c '.result[] | select(.message.chat.id == '$chat_id') | .message')
    echo "${messages[@]}"
}