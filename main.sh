#!/bin/bash
source settings.sh
source extensions/using.sh
using extensions
using src

startup() {
   process_killer_start
   
   job_runner_start
   catch '
      default_logger "error in startup" "ERROR" 
   '
}

main() {
   
   init_reader
   add_job fetch_messages 1 1

   add_job balancer_process 1 0.1

   add_job process_message 4 1
   catch '
      default_logger "error in main" "ERROR" 
   '
}

main
startup

echo "Bot was started. Click Enter for stoping of bot"
read