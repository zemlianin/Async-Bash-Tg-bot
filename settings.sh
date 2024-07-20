#!/bin/bash
# main
export SRC_DIRECTORY='./src'

# Message reader
TOKEN="YOUR_TELEGRAM_BOT_TOKEN"  # Замените на ваш токен
LOCK_FILE="/tmp/lockfile.lock"
BASE_FIFO_DIR="/tmp/tg_fifos"
LAST_UPDATE_FILE="/tmp/last_update_id.txt"