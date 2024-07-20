#!/bin/bash
source settings.sh
source extensions/using.sh
using extensions

test_job(){
   echo "test job"
}

startup() {
   process_killer_start
   job_runner_start
}

main() {
   using src
   add_job test_job 2 5

   

   sleep 10
}

main