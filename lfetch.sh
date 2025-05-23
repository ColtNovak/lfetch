#!/bin/bash

start=$(date +%s%N)

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/lfetch"
mkdir -p "$cache_dir"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
logo_dirs=(
    "$script_dir/logos"                 
    "/usr/share/lfetch/logos"           
    "/usr/local/share/lfetch/logos"     
)

logod=""
for dir in "${logo_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        logod="$dir"
        break
    fi
done

R=$'\033[0m'; BOLD=$'\033[1m' RED=$'\033[91m'; GR=$'\033[92m'; YE=$'\033[93m'; BLUE=$'\033[94m' 
M=$'\033[95m'; CYAN=$'\033[96m'; WH=$'\033[97m'

if [[ ! -f "$cache_dir/static" ]]; then
    {
        IFS=\" read -r _ d _ < /etc/os-release
        cpu_info=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/  */ /g')
        printf "h='%s'\nu='%s'\no='%s'\nsh='%s'\nd='%s'\ncpu='%s'\ncores=%d\n" \
            "$HOSTNAME" "${USER:-$USER}" "${OSTYPE%%[-_]*}" "${SHELL##*/}" \
            "${d%% *}" "$cpu_info" $(nproc)
    } > "$cache_dir/static"
fi
. "$cache_dir/static"

if [[ ! -f "$cache_dir/dyn" || $(( $(date +%s) - $(stat -c %Y "$cache_dir/dyn") )) -gt 60 ]]; then
    {
        read -r up _ </proc/uptime
        mem_info=$(grep -m1 -e MemTotal -e MemAvailable /proc/meminfo)
        disk_info=$(df -k / | awk 'NR==2')
        printf "k='%s'\nde='%s'\nup='%dh%02dm'\nmem='%dMB/%dMB'\ndisk='%dMB/%dMB'\nip='%s'\nload='%s'\n" \
            "$(uname -r)" "${XDG_CURRENT_DESKTOP:-?}" \
            $(( ${up%.*}/3600 )) $(( (${up%.*}%3600)/60 )) \
            $(( $(awk '/MemTotal/ {print $2}' <<< "$mem_info")/1024 )) \
            $(( $(awk '/MemAvailable/ {print $2}' <<< "$mem_info")/1024 )) \
            $(( $(awk '{print $3}' <<< "$disk_info")/1024 )) \
            $(( ($(awk '{print $3+$4}' <<< "$disk_info"))/1024 )) \
            "$(ip -4 -br addr | awk 'NR>1 && $3 {print $3; exit}')" \
            "$(cut -d' ' -f1-3 /proc/loadavg)"
    } > "$cache_dir/dyn"
fi
. "$cache_dir/dyn"

logof="Linux"
if [[ -n "$logod" ]]; then
    for distro in "${d,,}" "${d^^}" "${d~~}"; do
        if [[ -f "$logod/$distro" ]]; then
            logof="$distro"
            break
        fi
    done
fi

if [[ -n "$logod" && -f "$logod/$logof" ]]; then
    declare -ai cl
    declare -a ansi
    w=0
    
    while IFS= read -r line; do
        ansi+=("$line")
        clean_line=${line//\\033\[[0-9;]*m/}
        clean_line=${clean_line%%+([[:space:]])}
        (( (len=${#clean_line}) > w )) && w=$len
        cl+=("$len")
    done < "$logod/$logof"
    
    declare -p ansi cl > "$cache_dir/ansi"
    echo "w=$w" > "$cache_dir/logo"
fi

if [[ -f "$cache_dir/ansi" && -f "$cache_dir/logo" ]]; then
    . "$cache_dir/ansi"
    . "$cache_dir/logo"
else
    # Fallback if no logo
    ansi=()
    cl=()
    w=0
fi

info=(
    "${YE}$u@${M}$h"
    "${BOLD}${CYAN}OS     ~ ${WH}${o^}"
    "${BOLD}${CYAN}Kernel ~ ${WH}$k"
    "${BOLD}${CYAN}Uptime ~ ${WH}$up"
    "${BOLD}${CYAN}Shell  ~ ${WH}$sh"
    "${BOLD}${CYAN}DE     ~ ${WH}$de"
    "${BOLD}${CYAN}Distro ~ ${WH}$d"
    "${BOLD}${CYAN}Memory ~ ${WH}$mem"
    "${BOLD}${CYAN}Disk   ~ ${WH}$disk"
    "${BOLD}${CYAN}IP     ~ ${WH}${ip:-N/A}"
    "${BOLD}${CYAN}Load   ~ ${WH}$load"
)

for idx in "${!ansi[@]}"; do
    if (( idx < ${#info[@]} )); then
        printf "%b %b%*s\n" "${ansi[idx]}" "${info[idx]}" \
            $((w - cl[idx] - ${#info[idx]} + ${#BOLD} + ${#WH} + 10 )) ''
    else
        printf "%b%*s\n" "${ansi[idx]}" $((w - cl[idx])) ''
    fi
done

printf "\nTime: $(( ($(date +%s%N) - start)/1000000 )) ms${R}\n"
