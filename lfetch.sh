#!/bin/bash

start=$(date +%s%N)

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/lfetch"
rm -rf "$cache_dir" 2>/dev/null
mkdir -p "$cache_dir"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
logo_dirs=(
    "$script_dir/logos" 
    "/usr/share/lfetch/logos"
    "/usr/local/share/lfetch/logos"
)

for dir in "${logo_dirs[@]}"; do
    [[ -d "$dir" ]] && logod="$dir" && break
done
[[ -z "$logod" ]] && logod="/dev/null"

R=$'\033[0m' BOLD=$'\033[1m'
RED=$'\033[91m' GR=$'\033[92m' YE=$'\033[93m' BLUE=$'\033[94m'
M=$'\033[95m' CYAN=$'\033[96m' WH=$'\033[97m'

# Static config
{
    IFS=\" read -r _ d _ < /etc/os-release
    d="${d/Alpine Linux/Alpine}"
    grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/  */ /g' | read -r cpu
    printf "h='%s'\nu='%s'\no='%s'\nsh='%s'\nd='%s'\ncpu='%s'\ncores=%d\n" \
        "$HOSTNAME" "${USER:-$USER}" "${OSTYPE%%[-_]*}" "${SHELL##*/}" \
        "$d" "$cpu" $(nproc)
} > "$cache_dir/static"
. "$cache_dir/static"

# Dynamic info
{
    read -r up _ < /proc/uptime
    read -r _ mem _ <<< $(grep -m1 MemTotal /proc/meminfo)
    read -r _ mem_free _ <<< $(grep -m1 MemAvailable /proc/meminfo)
    read -r _ _ used disk_avail _ <<< $(df -k / | awk 'NR==2')
    ip=$(ip -o -4 addr show eth0 2>/dev/null | awk '{print $4}' || echo "N/A")
    
    printf "k='%s'\nde='%s'\nup='%dh%02dm'\nmem='%dMB/%dMB'\ndisk='%dMB/%dMB'\nip='%s'\nload='%s'\n" \
        "$(uname -r)" "${XDG_CURRENT_DESKTOP:-?}" \
        $(( ${up%.*}/3600 )) $(( (${up%.*}%3600)/60 )) \
        $((mem/1024)) $((mem_free/1024)) \
        $((used/1024)) $(( (used + disk_avail)/1024 )) \
        "$ip" \
        "$(cut -d' ' -f1-3 /proc/loadavg)"
} > "$cache_dir/dyn"
. "$cache_dir/dyn"

# Logo handling
logof="$d"
[[ ! -f "$logod/$logof" ]] && logof="Linux"

declare -a ansi cl
w=0
while IFS= read -r line; do
    ansi+=("$line")
    cle=${line//\\033\[[0-9;]*m/}
    cle=${cle%%+([[:space:]])}
    (( (len=${#cle}) > w )) && w=$len
    cl+=("$len")
done < <([[ -f "$logod/$logof" ]] && cat "$logod/$logof" || echo "NO LOGO FOUND")

i=(
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
    if (( idx < ${#i[@]} )); then
        printf "%b %b%*s\n" "${ansi[idx]}" "${i[idx]}" \
            $((w - cl[idx] - ${#i[idx]} + ${#BOLD} + ${#WH} + 10 )) ''
    else
        printf "%b%*s\n" "${ansi[idx]}" $((w - cl[idx])) ''
    fi
done

printf "\nTime: $(( ($(date +%s%N) - start)/1000000 )) ms${R}\n"
