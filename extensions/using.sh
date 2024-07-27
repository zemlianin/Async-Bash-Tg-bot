#!/bin/bash

using() {
    local directory=$1

    for path in "$directory"/*
    do
        if [[ -f "$path" && "$path" == *.sh ]]; then
            source "$path"
        elif [[ -d "$path" ]]; then
            using "$path"
        fi
    done
}
export -f using