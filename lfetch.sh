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
    # Static
    IFS=\" read -r _ d _ < /etc/os-release
    d="${d/Alpine Linux/Alpine}"
    cpu=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/  */ /g')
    cores=$(nproc)
    
    # Dynamic
    read -r up _ < /proc/uptime
    mem=$(grep -m1 MemTotal /proc/meminfo | awk '{print $2/1024}')
    mem_free=$(grep -m1 MemAvailable /proc/meminfo | awk '{print $2/1024}')
    disk=$(df -k / | awk 'NR==2 {print $3/1024"MB/"($3+$4)/1024"MB"}')
ip=$(
  ip -o -4 addr show eth0 2>/dev/null | 
  awk '{print $4}' | 
  head -n1 | 
  cut -d' ' -f1
) || ip="N/A"    load=$(cut -d' ' -f1-3 /proc/loadavg)
    
    # Formatting
    printf -v up "%dh%02dm" $(( ${up%.*}/3600 )) $(( (${up%.*}%3600)/60 ))
}

get_info

logo="Alpine"
[[ -f "$logod/$logo" ]] || logo="Linux"

declare -a ansi cl
w=0
while IFS= read -r line; do
    ansi+=("$line")
    cle=${line//\\033\[[0-9;]*m/}
    cle=${cle%%+([[:space:]])}
    (( (len=${#cle}) > w )) && w=$len
    cl+=("$len")
done < <([[ -f "$logod/$logo" ]] && cat "$logod/$logo" || echo "NO LOGO FOUND")

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
        printf "%b %b%*s\n" "${ansi[idx]}" "${i[idx]}" \
            $((w - cl[idx] - ${#i[idx]} + 20 )) ''
    else
        printf "%b%*s\n" "${ansi[idx]}" $((w - cl[idx])) ''
    fi
done

printf "\nTime: $(( ($(date +%s%N) - start)/1000000 )) ms${R}\n"
