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

for dir in "${logo_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        logod="$dir"
        break
    fi
done

[[ -z "$logod" ]] && logod="/dev/null"

R=$'\033[0m' BOLD=$'\033[1m'
RED=$'\033[91m' GR=$'\033[92m' YE=$'\033[93m' BLUE=$'\033[94m'
M=$'\033[95m' CYAN=$'\033[96m' WH=$'\033[97m'

if [[ ! -f "$cache_dir/static" ]]; then
    {
        IFS=\" read _ d _ < /etc/os-release
        grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/  */ /g' | read cpu
        printf "h='%s'\nu='%s'\no='%s'\nsh='%s'\nd='%s'\ncpu='%s'\ncores=%d\n" \
            "$HOSTNAME" "${USER:-$USER}" "${OSTYPE%%[-_]*}" "${SHELL##*/}" \
            "${d%% *}" "$cpu" $(nproc)
    } > "$cache_dir/static"
fi
. "$cache_dir/static"

if [[ ! -f "$cache_dir/dyn" || $(( $(date +%s) - $(stat -c %Y "$cache_dir/dyn") )) -gt 60 ]]; then
    {
        read -r up _ </proc/uptime
        read -r _ mem _ mem_free _ <<< $(grep -m1 -e MemTotal -e MemAvailable /proc/meminfo)
        read -r _ _ used disk_avail _ <<< $(df -k / | awk 'NR==2')
        printf "k='%s'\nde='%s'\nup='%dh%02dm'\nmem='%dMB/%dMB'\ndisk='%dMB/%dMB'\nip='%s'\nload='%s'\n" \
            "$(uname -r)" "${XDG_CURRENT_DESKTOP:-?}" \
            $(( ${up%.*}/3600 )) $(( (${up%.*}%3600)/60 )) \
            $((mem/1024)) $((mem_free/1024)) \
            $((used/1024)) $(( (used + disk_avail)/1024 )) \
            "$(ip -4 -br addr | awk 'NR>1 && $3 {print $3; exit}')" \
            "$(cut -d' ' -f1-3 /proc/loadavg)"
    } > "$cache_dir/dyn"
fi
. "$cache_dir/dyn"

logof="Linux"
for distro in "${d,,}" "${d^^}" "${d~~}"; do
    if [[ -f "$logod/$distro" ]]; then
        logof="$distro"
        break
    fi
done

if [[ ! -f "$cache_dir/logo" || ! -f "$cache_dir/ansi" ]]; then
    declare -ai cl
    declare -a ansi
    local w=0 line cle
    
    while IFS= read -r line; do
        ansi+=("$line")
        cle=${line//\\033\[[0-9;]*m/}
        cle=${cle%%+([[:space:]])}
        (( (len=${#cle}) > w )) && w=$len
        cl+=($len)
    done < "$logod/$logof"
    
    declare -p ansi cl > "$cache_dir/ansi"
    echo "w=$w" > "$cache_dir/logo"
fi
. "$cache_dir/ansi"; . "$cache_dir/logo"

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
