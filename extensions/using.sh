using() {
    local directory=$1

    for path in "$directory"/*
    do
        # Проверяем, является ли элемент файлом
        if [[ -f "$path" && "$path" == *.sh ]]; then
            source "$path"
        elif [[ -d "$path" ]]; then
            using "$path"
        fi
    done
}
export -f using

get_build_files(){
    local directory=$1
    local files=()

    # Считываем все файлы в массив
    for path in "$directory"/*
    do
        # Проверяем, является ли элемент файлом с суффиксом o{N}
        if [[ -f "$path" && "$path" =~ o[0-9]+\.sh$ ]]; then
            first_line=$(head -n 1 "$path")
            firs_line_only_num=$(echo "$first_line" | sed 's/# order //g')
            combined_value="$firs_line_only_num:$path"
            files+=("$combined_value")
        elif [[ -d "$path" ]]; then
            local sub_files=("`get_build_files "$path"`")
            files+=("${sub_files[@]}")
        fi
    done

    echo "${files[@]}"
}

build() {
    local directory=$1
    local files=(`get_build_files $directory`)

    # Функция для извлечения значения N из имени файла
    get_order() {
        local file=$1
        echo "$file" | grep -oP 'order_\K[0-9]+'
    }

    # Сортируем файлы по значению N
    IFS=$'\n' 
    sorted_files=(`echo "${files[*]}" | sort -t: -k1,1n`)

    # Выполняем запуск файлов в порядке не убывания N
    for file in "${sorted_files[@]}"
    do
        source `echo "$file" | cut -d':' -f2`
    done
    unset IFS
}
export -f build