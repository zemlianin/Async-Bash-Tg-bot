#!/bin/bash

trace_call() {
    local frame=0
    
    while caller $frame; do
        local info=`caller $frame`
        stack_trace="$stack_trace -> $info"
        ((frame++))
    done

    echo "$stack_trace"
}
export -f trace_call

catch() {
    local exit_code=$?
    local catch_function=$1

    if [ $exit_code -ne 0 ]; then
        eval $catch_function
    fi
}
export -f catch