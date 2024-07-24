#!/bin/bash
# main
export SRC_DIRECTORY='./src'

# Job Runner

# Message Reader
export BOT_TOKEN="BOT_TOKEN" 
export BASE_FIFO_DIR="tmp/tg_fifos"
export LAST_UPDATE_FILE="tmp/last_update_id.txt"
export NOTIFICATIONS_FIFO="$BASE_FIFO_DIR/messages"

# Balancer And Workers
declare -A CHAT_DICTIONARY
export WORKERS_FIFO_DIR="tmp/workers_fifos"