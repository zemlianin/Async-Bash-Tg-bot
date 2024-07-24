init_reader() {

    mkdir -p "$BASE_FIFO_DIR"
    LAST_UPDATE_ID=0

    if [[ ! -p "$NOTIFICATIONS_FIFO" ]]; then
        mkfifo "$NOTIFICATIONS_FIFO"
fi
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

        dialog_file="$BASE_FIFO_DIR/$chat_id"
        
        if [[ ! -f "$dialog_file" ]]; then
            echo > "$dialog_file"
            catch 'default_handler "Error of dialog_file creating" "ERROR"'
        fi

        text=$(echo "$message" | jq -r '.message.text')

        default_handler "text to $dialog_file" "INFO"
        echo "$text;" >> "$dialog_file"

        default_handler "$chat_id to $NOTIFICATIONS_FIFO" "INFO"
        echo ":$chat_id" > "$NOTIFICATIONS_FIFO"
    done < <(echo "$messages" | jq -c '.[]')
}

get_tg_messages(){
    local last_update_id=$1
    local updates=$(curl -s "https://api.telegram.org/bot$BOT_TOKEN/getUpdates?offset=$last_update_id")
    default_handler "$updates" "Info"

    messages=$(echo "$updates" | jq -c '.result')

    echo "$messages"
}