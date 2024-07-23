#!/bin/bash
source settings.sh
source extensions/using.sh
using extensions
using src

startup() {
   process_killer_start
   job_runner_start
}

main() {
   reader_init
   add_job fetch_messages 1 5
   add_job process_messages 1 2
}

main
startup
sleep 100