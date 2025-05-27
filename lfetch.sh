#!/bin/bash

start=$(date +%s%N)

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
logo_dirs=(
    "$script_dir/logos" 
    "/usr/share/lfetch/logos"
    "/usr/local/share/lfetch/logos"
)

for dir in "${logo_dirs[@]}"; do
    [[ -d "$dir" ]] && logod="$dir" && break
done

R=$'\033[0m' BOLD=$'\033[1m'
RED=$'\033[91m' GR=$'\033[92m' YE=$'\033[93m' BLUE=$'\033[94m'
M=$'\033[95m' CYAN=$'\033[96m' WH=$'\033[97m'

get_info() {
    IFS=\" read -r _ d _ < /etc/os-release
    d="${d/Alpine Linux/Alpine}"
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

get_info

# Force Alpine logo detection
logo="Alpine"
[[ -f "$logod/$logo" ]] || logo="Linux"

declare -a ansi cl
declare w=0 line cle

# Read logo with proper ANSI conversion
while IFS= read -r line; do
    # Convert all escape code formats
    line=${line//\\x1b/\033}
    line=${line//\\033/\033}
    line=${line//\x1b/\033}
    ansi+=("$line")
    # Calculate visible length
    cle=${line//\033\[[0-9;]*m/}
    cle=${cle%%+([[:space:]])}
    (( (len=${#cle}) > w )) && w=$len
    cl+=("$len")
done < <([[ -f "$logod/$logo" ]] && cat "$logod/$logo" || echo "NO LOGO FOUND")

# Pad all logo lines to max width with ANSI reset
for i in "${!ansi[@]}"; do
    ansi[$i]="${ansi[$i]%%+([[:space:]])}"
    ansi[$i]=$(printf "%-${w}s%s" "${ansi[$i]}" "${R}")
done

i=(
    "${YE}${USER}@${HOSTNAME}${M}"
    "${BOLD}${CYAN}OS     ~ ${WH}${OSTYPE%%[-_]*^}"
    "${BOLD}${CYAN}Kernel ~ ${WH}$(uname -r)"
    "${BOLD}${CYAN}Uptime ~ ${WH}$up"
    "${BOLD}${CYAN}Shell  ~ ${WH}${SHELL##*/}"
    "${BOLD}${CYAN}DE     ~ ${WH}${XDG_CURRENT_DESKTOP:-?}"
    "${BOLD}${CYAN}Distro ~ ${WH}$d"
    "${BOLD}${CYAN}Memory ~ ${WH}${mem%.*}MB/${mem_free%.*}MB"
    "${BOLD}${CYAN}Disk   ~ ${WH}$disk"
    "${BOLD}${CYAN}IP     ~ ${WH}${ip}"
    "${BOLD}${CYAN}Load   ~ ${WH}$load"
)

for idx in "${!ansi[@]}"; do
    if (( idx < ${#i[@]} )); then
        logo_visible=${ansi[$idx]//\033\[[0-9;]*m/}
        logo_visible=${logo_visible%%+([[:space:]])}
        info_visible=$(echo -e "${i[$idx]}" | sed 's/\x1b\[[0-9;]*m//g')
        
        padding=$((w - ${#logo_visible} - ${#info_visible} + 15))
        
        printf "%b %b%*s\n" "${ansi[$idx]}" "${i[$idx]}" "$padding" ""
    else
        printf "%b\n" "${ansi[$idx]}"
    fi
done

printf "\nTime: $(( ($(date +%s%N) - start)/1000000 )) ms${R}\n"
