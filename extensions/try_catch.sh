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

try() {
    local cmds="$1"

    while IFS= read -r cmd; do
        eval "$cmd>/dev/null"
        local exit_code=$?

        if [ $exit_code -ne 0 ]; then

            echo "ERROR $exit_code in $cmd"

            return $exit_code
        fi
    done <<< "$cmds"
    
    return 0
}
export -f try

catch() {
    local exit_code=$?
    local catch_function=$1

    if [ $exit_code -ne 0 ]; then
        eval $catch_function
    fi
}
export -f catch
