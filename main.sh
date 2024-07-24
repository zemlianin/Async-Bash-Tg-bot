#!/bin/bash
source settings.sh
source extensions/using.sh
using extensions
using src

startup() {
   process_killer_start
   
   job_runner_start
   catch '
      default_handler "error in startup" "ERROR" 
   '
}

main() {
   
   init_reader
   add_job fetch_messages 1 5

   add_job balancer_process 1 3

   add_job process_message 2 1
   catch '
      default_handler "error in main" "ERROR" 
   '
}

main
startup
sleep 100