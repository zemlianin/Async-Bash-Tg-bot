reader_init() {
    mkdir -p "$BASE_FIFO_DIR"
    LAST_UPDATE_ID=0
}

fetch_messages() {
    default_handler "start fetching $LAST_UPDATE_ID" "INFO"

    local messages=$(get_tg_messages $LAST_UPDATE_ID)

    while IFS= read -r message; do
        update_id=$(echo "$message" | jq '.update_id')
        chat_id=$(echo "$message" | jq '.message.chat.id')

        if (( LAST_UPDATE_ID >= update_id )); then
            continue 
        fi

        LAST_UPDATE_ID="$update_id"

        fifo="$BASE_FIFO_DIR/$chat_id"
        
        if [[ ! -p "$fifo" ]]; then
            mkfifo "$fifo"
            catch 'default_handler "Error of mkfifo" "ERROR"'
        fi

        text=$(echo "$message" | jq -r '.message.text')
        default_handler "text to $fifo" "INFO"
        echo "$text" > "$fifo"
    done < <(echo "$messages" | jq -c '.[]')
}

get_tg_messages(){
    local last_update_id=$1
    local updates=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getUpdates?offset=$last_update_id")

    messages=$(echo "$updates" | jq -c '.result')

    default_handler "$messages" "Info"
    echo "$messages"
}