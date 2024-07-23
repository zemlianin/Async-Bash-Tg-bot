process_messages() {
    local fifo="$BASE_FIFO_DIR/911073420"
    
    if read -r message < "$fifo"; then
      response="Response to: $message"
      echo "$response"
    fi
}