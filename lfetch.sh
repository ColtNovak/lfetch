#!/bin/bash

start=$(date +%s%N)

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
system_logod="$script_dir/logos"  
R=$'\033[0m' BOLD=$'\033[1m'
RED=$'\033[91m' GR=$'\033[92m' YE=$'\033[93m' BLUE=$'\033[94m'
M=$'\033[95m' CYAN=$'\033[96m' WH=$'\033[97m'

CACHE_DIR="$HOME/.cache/lfetch"
mkdir -p "$CACHE_DIR"
CACHE_FILE="$CACHE_DIR/system.cache"
CACHE_LIFESPAN=$((7 * 24 * 60 * 60)) 

get_info() {
    IFS=\" read -r _ d _ < /etc/os-release
    cpu=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/  */ /g')
    cores=$(nproc)
    
    read -r up _ < /proc/uptime
    mem=$(grep -m1 MemTotal /proc/meminfo | awk '{print $2/1024}')
    mem_free=$(grep -m1 MemAvailable /proc/meminfo | awk '{print $2/1024}')
    disk=$(df -k / | awk 'NR==2 {print $3/1024"MB/"($3+$4)/1024"MB"}')
    ip=$(hostname -i) 
    load=$(cut -d' ' -f1-3 /proc/loadavg)
    
    printf -v up "%dh%02dm" $(( ${up%.*}/3600 )) $(( (${up%.*}%3600)/60 ))
}

source /etc/os-release
logo="${ID^}" 

logo_file=""

if [[ -f "$system_logod/$logo" ]]; then
    logo_file="$system_logod/$logo"
else
    logo_file="$system_logod/Linux"
fi

logo_path_hash=$(echo "$logo_file" | md5sum | cut -d' ' -f1)
LOGO_CACHE="$CACHE_DIR/${logo}_${logo_path_hash}.cache"

declare -a ansi
declare -a info_lines
declare w=0
if [[ -f "$CACHE_FILE" && $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -lt 3600 ]]; then
    mapfile -t info_lines < "$CACHE_FILE"
else
    get_info
    
    info_lines=(
        "${YE}${USER}@${HOSTNAME}${M}"
        "${BOLD}${CYAN}OS     ~ ${WH}${OSTYPE%%[-_]*}"
        "${BOLD}${CYAN}Kernel ~ ${WH}$(uname -r)"
        "${BOLD}${CYAN}Uptime ~ ${WH}$up"
        "${BOLD}${CYAN}Shell  ~ ${WH}${SHELL##*/}"
        "${BOLD}${CYAN}DE     ~ ${WH}${XDG_CURRENT_DESKTOP:-?}"
        "${BOLD}${CYAN}Distro ~ ${WH}$PRETTY_NAME"
        "${BOLD}${CYAN}Memory ~ ${WH}${mem%.*}MB/${mem_free%.*}MB"
        "${BOLD}${CYAN}Disk   ~ ${WH}$disk"
        "${BOLD}${CYAN}IP     ~ ${WH}${ip}"
        "${BOLD}${CYAN}Load   ~ ${WH}$load"
    )
    
    printf "%s\n" "${info_lines[@]}" > "$CACHE_FILE"
fi

if [[ -f "$LOGO_CACHE" && $(( $(date +%s) - $(stat -c %Y "$LOGO_CACHE") )) -lt $CACHE_LIFESPAN ]]; then
    mapfile -t ansi < "$LOGO_CACHE"
    for line in "${ansi[@]}"; do
        clean_line=${line//\033\[[0-9;]*m/}
        clean_line=${clean_line%%+([[:space:]])}
        (( (len=${#clean_line}) > w )) && w=$len
    done
else
    if [[ -f "$logo_file" ]]; then
        while IFS= read -r line; do
            line=${line//\\x1b/\033}
            line=${line//\\033/\033}
            line=${line//\x1b/\033}
            ansi+=("$line")
            clean_line=${line//\033\[[0-9;]*m/}
            clean_line=${clean_line%%+([[:space:]])}
            (( (len=${#clean_line}) > w )) && w=$len
        done < "$logo_file"
    else
        ansi+=("NO LOGO FOUND")
        w=12
    fi
    printf "%s\n" "${ansi[@]}" > "$LOGO_CACHE"
fi

max_lines=$(( ${#ansi[@]} > ${#info_lines[@]} ? ${#ansi[@]} : ${#info_lines[@]} ))

for (( idx=0; idx < max_lines; idx++ )); do
    if (( idx < ${#ansi[@]} )); then
        printf "%b" "${ansi[idx]}"
        clean_logo=${ansi[idx]//\033\[[0-9;]*m/}
        clean_logo=${clean_logo%%+([[:space:]])}
        printf "%*s" $(( w - ${#clean_logo} )) ""
    else
        printf "%*s" $w ""
    fi
    if (( idx < ${#info_lines[@]} )); then
        printf "        %b" "${info_lines[idx]}"
    fi
    printf "%s\n" "$R"
done

mkdir -p "$user_logod" 2>/dev/null

printf "\nTime: $(( ($(date +%s%N) - start)/1000000 )) ms${R}\n"
