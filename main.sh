#!/bin/bash
source settings.sh
source extensions/using.sh
using extensions
using src

startup() {
   init_killer
   process_killer_start

   init_job_runner
   job_runner_start
   catch '
      default_handler "error in startup" "ERROR" 
   '
}

main() {
   
   init_reader
   add_job fetch_messages 1 5

   init_balancer
   add_job balancer_process 1 3
#s   add_job process_message 1 2
   catch '
      default_handler "error in main" "ERROR" 
   '
}

main
startup
sleep 100