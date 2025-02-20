#!/bin/bash

start=$(date +%s%N)

cache="$HOME/.lfetch"
mkdir -p "$cache"

RED='\033[91m' GREEN='\033[92m' YELLOW='\033[93m' BLUE='\033[94m' 
MAGENTA='\033[95m' CYAN='\033[96m' WHITE='\033[97m' R='\033[0m'
BOLD='\033[1m'
C="${R}${WHITE}" H="${BOLD}${CYAN}" U="${YELLOW}" HN="${MAGENTA}"
if [[ ! -f "$cache/static" ]]; then
    h=$HOSTNAME u=${USER:-$USER}
    echo "h='$h'" > "$cache/static"
    echo "u='$u'" >> "$cache/static"
    
    o=${OSTYPE%%[-_]*}
    sh=${SHELL##*/}
    echo "o='$o'" >> "$cache/static"
    echo "sh='$sh'" >> "$cache/static"
    
    IFS=\" read _ d _ < /etc/os-release
    d=${d%% *}
    echo "d='$d'" >> "$cache/static"
fi
source "$cache/static"
k=$(uname -r)
de=${XDG_CURRENT_DESKTOP:-?}
read -r up _ </proc/uptime
up=$(printf "%dh%02dm" $(( ${up%.*}/3600 )) $(( (${up%.*}%3600)/60 )))

arch=(
"${CYAN}       /\       ${R}" "${CYAN}      /  \      ${R}" "${CYAN}     /\   \     ${R}" "${CYAN}    /  __  \      ${R}" "${CYAN}   /  (  )  \     ${R}" "${CYAN}  / __|  |__ \    ${R}" "${CYAN} /.*      */. \ ${R}"

)

ubuntu=(
"${YELLOW}              ${GREEN}.,:clooo:  ${YELLOW}.:looooo:.${R} " "${YELLOW}           ${GREEN};looooooooc  ${YELLOW}oooooooooo'${R} " "${YELLOW}        ${GREEN};looooool:,''.  ${YELLOW}:ooooooooooc${R}" "${YELLOW}       ${GREEN};looool;.         ${YELLOW}'oooooooooo,${R}" "${YELLOW}      ${GREEN};clool'             ${YELLOW}.cooooooc.  ${GREEN},," "${YELLOW}  ${GREEN}...                ${YELLOW}......  ${GREEN}:oo," "${YELLOW}  ${YELLOW};clol:,.                        ${GREEN}loooo'${R}" "${YELLOW} ${YELLOW}:ooooooooo,                        ${GREEN}'ooool${R}" "${YELLOW}${YELLOW}'ooooooooooo.                        ${GREEN}loooo.${R}" "${YELLOW}${YELLOW}'ooooooooool                         ${GREEN}coooo.${R}" "${YELLOW} ${YELLOW},loooooooc.                        ${GREEN}.looo.${R}" "${YELLOW}   ${YELLOW}.,;;;'.                          ${GREEN};ooooc${R}" "${YELLOW}       ${GREEN}...                         ${GREEN},ooool.${R}" "${YELLOW}    ${GREEN}.cooooc.              ${YELLOW}..',,'.  ${GREEN}.cooo.${R}"     "${YELLOW}      ${GREEN};ooooo:.           ${YELLOW};oooooooc.  ${GREEN}:l.${R}" "${YELLOW}       ${GREEN}.coooooc,..      ${YELLOW}coooooooooo.${R}" "${YELLOW}         ${GREEN}.:ooooooolc:. ${YELLOW}.ooooooooooo'${R}" "${YELLOW}           ${GREEN}':loooooo;  ${YELLOW},oooooooooc${R} " "${YELLOW}               ${GREEN}..';::c'  ${YELLOW}.;loooo:'${R} "
)

gentoo=(
"${MAGENTA}    -o${WHITE}dNMMMMMMMMNNmhy+${MAGENTA}-                                ${R}" "${MAGENTA}  -y${WHITE}NMMMMMMMMMMMNNNmmdhy${MAGENTA}+-                             ${R}" "${MAGENTA}  o${WHITE}mMMMMMMMMMMMMNmdmmmmddhhy${MAGENTA}                           ${R}" "${MAGENTA} om${WHITE}MMMMMMMMMMMN${MAGENTA}hhyyyo${WHITE}hmdddhhhd${MAGENTA}o                          " "${MAGENTA}.y${WHITE}dMMMMMMMMMMd${MAGENTA}hs++so/s${WHITE}mdddhhhhdm${MAGENTA}+                        " "${MAGENTA} oy${WHITE}hdmNMMMMMMMN${MAGENTA}dyooy${WHITE}dmddddhhhhyhN${MAGENTA}d.                      " "${MAGENTA} :o${WHITE}yhhdNNMMMMMMMNNNmmdddhhhhhyym${MAGENTA}Mh                     ${R}" "${MAGENTA}   .:${WHITE}+sydNMMMMMNNNmmmdddhhhhhhmM${MAGENTA}my                     ${R}" "${MAGENTA}      /m${WHITE}MMMMMMNNNmmmdddhhhhhmMNh${MAGENTA}s:                     ${R}" "${MAGENTA}    o${WHITE}NMMMMMMMNNNmmmddddhhdmMNhs${MAGENTA}+                                        ${R}" "${MAGENTA} s${WHITE}NMMMMMMMMNNNmmmdddddmNMmhs${MAGENTA}/.                       ${R}" "${MAGENTA}/N${WHITE}MMMMMMMMNNNNmmmdddmNMNdso${MAGENTA}:                           ${R}" "${MAGENTA}+M${WHITE}MMMMMMNNNNNmmmmdmNMNdso${MAGENTA}/-                            ${R}" "${MAGENTA}yM${WHITE}MNNNNNNNmmmmmNNMmhs+${MAGENTA}/-                               ${R}" "${MAGENTA}/h${WHITE}MMNNNNNNNNMNdhs++${MAGENTA}/-                                  ${R}" "${MAGENTA}/${WHITE}ohdmmddhys+++/${MAGENTA}:                                     ${R}" "${MAGENTA}-//////:--.                                                          ${R}"
)

linux=(
"${BLUE}         #####                                          ${R}" "${BLUE}        #######                                         ${R}" "${BLUE}        ##${GREEN}O${BLUE}#${GREEN}O${BLUE}##           ${R}" "${BLUE}        #${YELLOW}#####${BLUE}#                         ${R}" "${BLUE}      ##${GREEN}##${YELLOW}###${GREEN}##${BLUE}##       ${R}" "${BLUE}     #${GREEN}##########${BLUE}##                       ${R}" "${BLUE}    #${GREEN}############${BLUE}##                      ${R}" "${BLUE}    #${GREEN}############${BLUE}###                     ${R}" "${YELLOW}   ##${BLUE}#${GREEN}###########${BLUE}##${YELLOW}#   ${R}" "${YELLOW} ######${BLUE}#${GREEN}#######${BLUE}#${YELLOW}###### ${R}" "${YELLOW} #######${BLUE}#${GREEN}#####${BLUE}#${YELLOW}####### ${R}" "${YELLOW}   #####${BLUE}#######${YELLOW}#####                  ${R}"
)
case $d in
  Gentoo) l=("${gentoo[@]}") ;;
  Ubuntu) l=("${ubuntu[@]}") ;; 
  Arch)   l=("${arch[@]}") ;;
  *)      l=("${linux[@]}") ;;
esac


if [[ ! -f "$cache/logo" ]]; then
    w=0
    ansi=()
    for li in "${l[@]}"; do
        clean=${li//$'\033'\[[0-9;]*m/}
        trim=$(echo -e "$clean" | sed 's/[[:space:]]*$//')
        ansi+=("$clean")
        (( ${#trim} > w )) && w=${#trim}
    done
    declare -p ansi > "$cache/ansi"
    echo "w=$w" > "$cache/logo"
fi
source "$cache/logo"
source <(cat "$cache/ansi")

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
  li="${l[idx]}"
  cle="${ansi[idx]}"
  pad=$((w - ${#cle}))
  
  if (( idx < ${#i[@]} )); then
      echo -e "$li$(printf "%${pad}s") ${i[idx]}"
  else
      echo -e "$li"
  fi
done



echo -e "\n${R}Time: $(($(($(date +%s%N)-start))/1000000)) ms"
