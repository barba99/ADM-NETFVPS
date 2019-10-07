#!/bin/bash
Block="/etc/nanobc" && [[ ! -d ${Block} ]] && exit
Block > /dev/null 2>&1

SCPdir="/etc/newadm"
SCPusr="${SCPdir}/ger-user"
SCPfrm="/etc/ger-frm"
SCPfrm3="/etc/adm-lite"
SCPinst="/etc/ger-inst"
SCPidioma="${SCPdir}/idioma"


msg () {
local colors="/etc/new-adm-color"
if [[ ! -e $colors ]]; then
COLOR[0]='\033[1;37m' #BRAN='\033[1;37m'
COLOR[1]='\e[31m' #VERMELHO='\e[31m'
COLOR[2]='\e[32m' #VERDE='\e[32m'
COLOR[3]='\e[33m' #AMARELO='\e[33m'
COLOR[4]='\e[34m' #AZUL='\e[34m'
COLOR[5]='\e[35m' #MAGENTA='\e[35m'
COLOR[6]='\033[1;36m' #MAG='\033[1;36m'
COLOR[7]='\033[1;34m' #AZULR='\033[1;34m'
COLOR[8]='\e[0;31m' #rojoc='\e[0;31m'
else
local COL=0
for number in $(cat $colors); do
case $number in
1)COLOR[$COL]='\033[1;37m';;
2)COLOR[$COL]='\e[31m';;
3)COLOR[$COL]='\e[32m';;
4)COLOR[$COL]='\e[33m';;
5)COLOR[$COL]='\e[34m';;
6)COLOR[$COL]='\e[35m';;
7)COLOR[$COL]='\033[1;36m';;
8)COLOR[$COL]='\033[1;34m';;
9)COLOR[$COL]='\033[0;31m';;
esac
let COL++
done
fi
NEGRITO='\e[1m'
SEMCOR='\e[0m'
 case $1 in
  -ne)cor="${COLOR[1]}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}";;
  -ama)cor="${COLOR[3]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -verm)cor="${COLOR[3]}${NEGRITO}[!] ${COLOR[1]}" && echo -e "${cor}${2}${SEMCOR}";;
  -verm2)cor="${COLOR[1]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -azu)cor="${COLOR[6]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -verd)cor="${COLOR[2]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -bra)cor="${COLOR[0]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  "-bar2"|"-bar")cor="\e[1;30mâž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–âž–\e[0m" && echo -e "${SEMCOR}${cor}${SEMCOR}";;
  -azuc)cor="${COLOR[7]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -rojoc)cor="${COLOR[8]}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
esac
}
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\e[1;30m➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖\e[0m"
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
fun_ip () {
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && echo "$MEU_IP2" || echo "$MEU_IP"
}
IP="$(fun_ip)"
menu_func "Colocar Archivo Online" "Remover Archivo Online" "Ver Links de Archivos Online"
echo -ne "$(msg -verd "[0]") $(msg -verm2 ">") " && msg -bra "$(fun_trans "SALIR DEL SCRIPT")"
echo -e "$barra"
while [[ ${arquivoonlineadm} != @([0-3]) ]]; do
read -p "[1-3]: " arquivoonlineadm
tput cuu1 && tput dl1
done
case ${arquivoonlineadm} in
3)
[[ -z $(ls /var/www/html) ]] && echo -e "$barra"  || {
    for my_arqs in `ls /var/www/html`; do
    [[ "$my_arqs" = "index.html" ]] && continue
    [[ "$my_arqs" = "index.php" ]] && continue
    [[ -d "$my_arqs" ]] && continue
    echo -e "\033[1;31m[$my_arqs] \033[1;36mhttp://$IP:81/$my_arqs\033[0m"
    done
    echo -e "$barra"
    }
;;
2)
i=1
[[ -z $(ls /var/www/html) ]] && echo -e "$barra"  || {
    for my_arqs in `ls /var/www/html`; do
    [[ "$my_arqs" = "index.html" ]] && continue
    [[ "$my_arqs" = "index.php" ]] && continue
    [[ -d "$my_arqs" ]] && continue
    select_arc[$i]="$my_arqs"
    echo -e "${cor[2]}[$i] > ${cor[3]}$my_arqs - \033[1;36mhttp://$IP:81/$my_arqs\033[0m"
    let i++
    done
    echo -e "$barra"
    echo -e "${cor[5]}$(fun_trans "Seleccione el archivo que desea borrar")"
    echo -e "$barra"
    while [[ -z ${select_arc[$slct]} ]]; do
    read -p " [1-$i]: " slct
    tput cuu1 && tput dl1
    done
    arquivo_move="${select_arc[$slct]}"
    [[ -d /var/www/html ]] && [[ -e /var/www/html/$arquivo_move ]] && rm -rf /var/www/html/$arquivo_move > /dev/null 2>&1
    [[ -e /var/www/$arquivo_move ]] && rm -rf /var/www/$arquivo_move > /dev/null 2>&1
    echo -e "${cor[5]}$(fun_trans "exito!")"
    echo -e "$barra"
    }
;;    
1)
i="1"
[[ -z $(ls $HOME) ]] && echo -e "$barra"  || {
    for my_arqs in `ls $HOME`; do
    [[ -d "$my_arqs" ]] && continue
    select_arc[$i]="$my_arqs"
    echo -e "${cor[2]} [$i] > ${cor[3]}$my_arqs"
    let i++
    done
    i=$(($i - 1))
    echo -e "${cor[5]}$(fun_trans "seleccione el archivo")"
    echo -e "$barra"
    while [[ -z ${select_arc[$slct]} ]]; do
    read -p " [1-$i]: " slct
    tput cuu1 && tput dl1
    done
    arquivo_move="${select_arc[$slct]}"
    [ ! -d /var ] && mkdir /var
    [ ! -d /var/www ] && mkdir /var/www
    [ ! -d /var/www/html ] && mkdir /var/www/html
    [ ! -e /var/www/html/index.html ] && touch /var/www/html/index.html
    [ ! -e /var/www/index.html ] && touch /var/www/index.html
    chmod -R 755 /var/www
    cp $HOME/$arquivo_move /var/www/$arquivo_move
    cp $HOME/$arquivo_move /var/www/html/$arquivo_move
    echo -e "\033[1;36m http://$IP:81/$arquivo_move\033[0m"
    echo -e "$barra"
    echo -e "${cor[5]}$(fun_trans "exito!")"
    echo -e "$barra"
    }
;;
esac
