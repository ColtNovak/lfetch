#!/bin/bash

start=${EPOCHREALTIME//.}

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)
logo_dirs=("$script_dir/logos" "/usr/share/lfetch/logos" "/usr/local/share/lfetch/logos")

for dir in "${logo_dirs[@]}"; do [[ -d "$dir" ]] && logod="$dir" && break; done

R=$'\033[0m' B=$'\033[1m' Y=$'\033[93m' M=$'\033[95m' C=$'\033[96m' W=$'\033[97m'

get_info() {
    IFS=\" read -r _ d _ </etc/os-release
    read -r up _ </proc/uptime
    printf -v up "%dh%02dm" $((${up%.*}/3600)) $((${up%.*}%3600/60))
    mem=($(grep -m1 MemTotal /proc/meminfo | awk '{print $2/1024}') $(grep -m1 MemAvailable /proc/meminfo | awk '{print $2/1024}'))
    disk=($(df -k / | awk 'NR==2 {print $3/1024, ($3+$4)/1024}'))
    ip=$(hostname -i)
    load=$(cut -d' ' -f1-3 /proc/loadavg)
}

get_info

logo="Alpine"
[[ -f "$logod/$logo" ]] || logo="Linux"

declare -a ansi cl w=0
while IFS= read -r line; do
    line=${line//\\x1b/} line=${line//\\033/} line=${line//\x1b/}
    ansi+=("$line")
    len=${#line}; len=$(echo -e "${line//\[[0-9;]*m/}" | wc -m)
    ((len>w)) && w=$len
    cl+=($len)
done < <([[ -f "$logod/$logo" ]] && cat "$logod/$logo" || echo "NO LOGO")

for i in "${!ansi[@]}"; do ansi[i]="${ansi[i]% *}${R}"; done

i=(
"${Y}${USER}@${HOSTNAME}${M}"
"${B}${C}OS     ~ ${W}${OSTYPE%%[-_]*^}"
"${B}${C}Kernel ~ ${W}$(uname -r)"
"${B}${C}Uptime ~ ${W}$up"
"${B}${C}Shell  ~ ${W}${SHELL##*/}"
"${B}${C}DE     ~ ${W}${XDG_CURRENT_DESKTOP:-?}"
"${B}${C}Distro ~ ${W}${d/Alpine Linux/Alpine}"
"${B}${C}Memory ~ ${W}${mem[0]%.*}MB/${mem[1]%.*}MB"
"${B}${C}Disk   ~ ${W}${disk[0]%.*}MB/${disk[1]%.*}MB"
"${B}${C}IP     ~ ${W}${ip:-N/A}"
"${B}${C}Load   ~ ${W}$load"
)

for idx in "${!ansi[@]}"; do
    if ((idx < ${#i[@]})); then
        ilen=$(echo -e "${i[idx]}" | sed 's/\x1b\[[0-9;]*m//g' | wc -m)
        printf "%b %b%$((w - cl[idx] - ilen + 15))s\n" "${ansi[idx]}" "${i[idx]}" ""
    else
        echo -e "${ansi[idx]}"
    fi
done

printf "\nTime: $(($((${EPOCHREALTIME//.} - start))/1000)) ms${R}\n"
