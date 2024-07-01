#!/bin/bash
source settings.sh
source extensions/using.sh
using extensions

test_job(){
   echo "test job"
}

main() {
   build src
   add_job test_job 2 5

   process_killer_start
   job_runner_start

   sleep 10
}

main