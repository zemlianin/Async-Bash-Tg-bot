#!/bin/bash
source settings.sh
source extensions/using.sh
using extensions

test_job(){
   echo "job func pid:$$"
}

main() {
   build src
   add_job test_job 2 5
   job_runner_start
   process_killer_start
   sleep 10
}

main