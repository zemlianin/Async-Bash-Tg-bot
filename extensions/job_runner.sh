#!/bin/bash

JOBS_LIST=()

add_job(){
    local function="$1"
    local num_of_process=$2
    local timeout=$3
    local pid=$0

    combined_record="$function:$num_of_process:$timeout"
    JOBS_LIST+=("$combined_record")
}


job_runner_start(){
    for job in "${JOBS_LIST[@]}"
    do
        IFS=':'
        read -r func num_of_process timeout <<< "$job"
        
        for ((i=1; i<=num_of_process; i++))
        do
            job_start "$func" $timeout &
            catch 'default_logger "error of run job: $func" "ERROR"'
            
            local pid=$!

            add_new_pid_for_killing $pid
            catch 'default_logger "error of write pid" "ERROR"'
        done
    done
}

job_start(){
    func="$1"
    timeout=$2

    while true; do
        $func
        catch 'default_logger "error of start of $func" "ERROR"'
        sleep $timeout
    done
}
