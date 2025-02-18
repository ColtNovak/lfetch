#!/bin/bash

start=$(date +%s%N)

RED='\033[91m' GREEN='\033[92m' YELLOW='\033[93m' BLUE='\033[94m' MAGENTA='\033[95m' CYAN='\033[96m' WHITE='\033[97m' R='\033[0m'

BOLD='\033[1m'
C="${R}${WHITE}"
H="${BOLD}${CYAN}"
U="${YELLOW}"
HN="${MAGENTA}"

arch=(
"${CYAN}       /\       ${R}"
"${CYAN}      /  \      ${R}"
"${CYAN}     /\   \     ${R}"
"${CYAN}    /  __  \    ${R}"
"${CYAN}   /  (  )  \   ${R}"
"${CYAN}  / __|  |__ \  ${R}"
"${CYAN} /.*      */. \ ${R}"
"${CYAN}                ${R}"
"${CYAN}                ${R}"
"${CYAN}                ${R}"
"${CYAN}                ${R}"
)

ubuntu=(
"${YELLOW}              ${GREEN}.,:clooo:  ${YELLOW}.:looooo:.${R} "
"${YELLOW}           ${GREEN};looooooooc  ${YELLOW}oooooooooo'${R} "
"${YELLOW}        ${GREEN};looooool:,''.  ${YELLOW}:ooooooooooc${R}"
"${YELLOW}       ${GREEN};looool;.         ${YELLOW}'oooooooooo,${R}"
"${YELLOW}      ${GREEN};clool'             ${YELLOW}.cooooooc.  ${GREEN},,"
"${YELLOW}  ${GREEN}...                ${YELLOW}......  ${GREEN}:oo,"
"${YELLOW}  ${YELLOW};clol:,.                        ${GREEN}loooo'${R}"
"${YELLOW} ${YELLOW}:ooooooooo,                        ${GREEN}'ooool${R}"
"${YELLOW}${YELLOW}'ooooooooooo.                        ${GREEN}loooo.${R}"
"${YELLOW}${YELLOW}'ooooooooool                         ${GREEN}coooo.${R}"
"${YELLOW} ${YELLOW},loooooooc.                        ${GREEN}.looo.${R}"
"${YELLOW}   ${YELLOW}.,;;;'.                          ${GREEN};ooooc${R}"
"${YELLOW}       ${GREEN}...                         ${GREEN},ooool.${R}"
"${YELLOW}    ${GREEN}.cooooc.              ${YELLOW}..',,'.  ${GREEN}.cooo.${R}"    
"${YELLOW}      ${GREEN};ooooo:.           ${YELLOW};oooooooc.  ${GREEN}:l.${R}"
"${YELLOW}       ${GREEN}.coooooc,..      ${YELLOW}coooooooooo.${R}"
"${YELLOW}         ${GREEN}.:ooooooolc:. ${YELLOW}.ooooooooooo'${R}"
"${YELLOW}           ${GREEN}':loooooo;  ${YELLOW},oooooooooc${R} "
"${YELLOW}               ${GREEN}..';::c'  ${YELLOW}.;loooo:'${R} "
)

gentoo=(
"${MAGENTA}  -/oyddmdhs+:.                                                              ${R}"
"${MAGENTA}  -o${WHITE}dNMMMMMMMMNNmhy+${MAGENTA}-                                      ${R}"
"${MAGENTA}  -y${WHITE}NMMMMMMMMMMMNNNmmdhy${MAGENTA}+-                                 ${R}"
"${MAGENTA}  \`o${WHITE}mMMMMMMMMMMMMNmdmmmmddhhy${MAGENTA}                             ${R}"
"${MAGENTA}   om${WHITE}MMMMMMMMMMMN${MAGENTA}hhyyyo${WHITE}hmdddhhhd${MAGENTA}o        ${R}"
"${MAGENTA}   .y${WHITE}dMMMMMMMMMMd${MAGENTA}hs++so${WHITE}hmdddhhhhdm${MAGENTA}+      ${R}"
"${MAGENTA}    oy${WHITE}hdmNMMMMMMMN${MAGENTA}dyooy${WHITE}dmddddhhhhyhN${MAGENTA}d.   ${R}"
"${MAGENTA}     :o${WHITE}yhhdNNMMMMMMMNNNmmdddhhhhhyym${MAGENTA}Mh                     ${R}"
"${MAGENTA}       .:${WHITE}+sydNMMMMMNNNmmmdddhhhhhhmM${MAGENTA}my                     ${R}"
"${MAGENTA}          /m${WHITE}MMMMMMNNNmmmdddhhhhhmMNh${MAGENTA}s:                     ${R}"
"${MAGENTA}       \`o${WHITE}NMMMMMMMNNNmmmddddhhdmMNhs${MAGENTA}+\`   ${R}         ${R}"
"${MAGENTA}      \`s${WHITE}NMMMMMMMMNNNmmmdddddmNMmhs${MAGENTA}/.    ${R}          ${R}"
"${MAGENTA}     /N${WHITE}MMMMMMMMNNNNmmmdddmNMNdso${MAGENTA}:\`     ${R}           ${R}"
"${MAGENTA}    +M${WHITE}MMMMMMNNNNNmmmmdmNMNdso${MAGENTA}/-       ${R}             ${R}"
"${MAGENTA}   yM${WHITE}MNNNNNNNmmmmmNNMmhs+${MAGENTA}/\`         ${R}              ${R}"
"${MAGENTA}  /h${WHITE}MMNNNNNNNNMNdhs++${MAGENTA}/\`           ${R}                ${R}"
"${MAGENTA} \`/${WHITE}ohdmmddhys+++/${MAGENTA}.\`             ${R}                 ${R}"
"${MAGENTA}   \`-//////:--.               ${R}                                      ${R}"
)

linux=(
"${BLUE}         #####                              ${R}"
"${BLUE}        #######                             ${R}"
"${BLUE}        ##${GREEN}O${BLUE}#${GREEN}O${BLUE}##  ${R}"
"${BLUE}        #${YELLOW}#####${BLUE}#     ${R}"
"${BLUE}      ##${GREEN}##${YELLOW}###${GREEN}##${BLUE}##  ${R}"
"${BLUE}     #${GREEN}##########${BLUE}##  ${R}"
"${BLUE}    #${GREEN}############${BLUE}##  ${R}"
"${BLUE}    #${GREEN}############${BLUE}### ${R}"
"${YELLOW}   ##${BLUE}#${GREEN}###########${BLUE}##${YELLOW}#   ${R}"
"${YELLOW} ######${BLUE}#${GREEN}#######${BLUE}#${YELLOW}###### ${R}"
"${YELLOW} #######${BLUE}#${GREEN}#####${BLUE}#${YELLOW}####### ${R}"
"${YELLOW}   #####${BLUE}#######${YELLOW}#####  ${R}"

)

RED='\033[91m' GREEN='\033[92m' YELLOW='\033[93m' BLUE='\033[94m'
MAGENTA='\033[95m' CYAN='\033[96m' WHITE='\033[97m' R='\033[0m'
BOLD='\033[1m' C="${R}${WHITE}" H="${BOLD}${CYAN}" U="${YELLOW}" HN="${MAGENTA}"

h=$HOSTNAME u=${USER:-$USER} o=${OSTYPE%%[-_]*} k=$(uname -r)
sh=${SHELL##*/} de=${XDG_CURRENT_DESKTOP:-?}

IFS=\" read _ d _ < /etc/os-release
d=${d%% *}

read -r up _ </proc/uptime
up=$(awk -v u="${up%.*}" 'BEGIN {printf "%dh%02dm", u/3600, u/60%60}')

case $d in
  Gentoo) l=("${gentoo[@]}") ;;
  Ubuntu) l=("${ubuntu[@]}") ;;
  Arch)   l=("${arch[@]}") ;;
  *)      l=("${linux[@]}") ;;
esac

w=0 ansi=()
for line in "${l[@]}"; do
    clean=${line//$'\033'\[[0-9;]*m/}
    ansi+=("$clean")
    ((${#clean} > w)) && w=${#clean}
done

i=(
"${U}$u${R}@${HN}$h${R}"
"${H}OS     ~ ${C}${o^}${R}"
"${H}Kernel ~ ${C}$k${R}"
"${H}Uptime ~ ${C}$up${R}"
"${H}Shell  ~ ${C}$sh${R}"
"${H}DE     ~ ${C}$de${R}"
"${H}Distro ~ ${C}${d}${R}"
)

for idx in "${!l[@]}"; do
  line="${l[idx]}"
  cl=$(echo -e "$line" | sed 's/\x1B\[[0-9;]*[a-zA-Z]//g')
  pad=$((w - ${#cl}))
  [[ $idx -lt ${#i[@]} ]] && echo -e "$line$(printf "%${pad}s") ${i[idx]}" || echo -e "$line"
done

echo -e "\n${R}Time: $(($(($(date +%s%N)-start))/1000000)) ms"
