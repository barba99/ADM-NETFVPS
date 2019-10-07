#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m======================================================\033[1;37m"
SCPdir="/etc/newadm" && [[ ! -d ${SCPdir} ]] && exit
SCPfrm="/etc/ger-frm" && [[ ! -d ${SCPfrm} ]] && exit
SCPinst="/etc/ger-inst" && [[ ! -d ${SCPinst} ]] && exit
fun_trans () {
#echo "$@"
#FUNCAO DENTRO DE FUNCAO KKKKKKKKK FDC
#apt-get install jq -y 2&>1 /dev/null
#apt-get install php -y 2&>1 /dev/null
func_tradu () {
local msg
message=($@)
key_api="trnsl.1.1.20190727T075223Z.750e23e6753a85b7.cdf2fd60fa8d836b334793524a40f87182da67f1"
lang="$1"
text=$(echo "${message[@]:1}"| php -r 'echo urlencode(fgets(STDIN));' // Or: php://stdin)
link=$(curl -s -d "key=$key_api&format=plain&lang=$lang&text=$text" https://translate.yandex.net/api/v1.5/tr.json/translate)
ms="$(echo $link|jq -r '.text[0]')"
echo "$ms"
}
local texto
local retorno
declare -A texto
SCPidioma="${SCPdir}/idioma"
[[ ! -e ${SCPidioma} ]] && touch ${SCPidioma}
local LINGUAGE=$(cat ${SCPidioma})
[[ -z $LINGUAGE ]] && LINGUAGE=es
[[ ! -e /etc/texto-adm ]] && touch /etc/texto-adm
source /etc/texto-adm
if [[ -z "$(echo ${texto[$@]})" ]]; then
#ENGINES=(aspell google deepl bing spell hunspell apertium yandex)
#NUM="$(($RANDOM%${#ENGINES[@]}))"
retorno="$(func_tradu ${LINGUAGE} "$@"|sed -e 's/[^a-z0-9 -]//ig' 2>/dev/null)"
echo "texto[$@]='$retorno'"  >> /etc/texto-adm
echo "$retorno"
else
echo "${texto[$@]}"
fi
}
update_pak () {
echo -ne " \033[1;31m[ ! ] apt-get update"
apt-get update -q > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
return
}
reiniciar_ser () {
echo -ne " \033[1;31m[ ! ] Services restart"
( 
[[ -e /etc/init.d/stunnel4 ]] && /etc/init.d/stunnel4 restart
[[ -e /etc/init.d/squid ]] && /etc/init.d/squid restart
[[ -e /etc/init.d/squid3 ]] && /etc/init.d/squid3 restart
[[ -e /etc/init.d/apache2 ]] && /etc/init.d/apache2 restart
[[ -e /etc/init.d/openvpn ]] && /etc/init.d/openvpn restart
[[ -e /etc/init.d/dropbear ]] && /etc/init.d/dropbear restart
[[ -e /etc/init.d/ssh ]] && /etc/init.d/ssh restart
fail2ban-client -x stop && fail2ban-client -x start
) > /dev/null 2>&1 && echo -e "\033[1;32m [OK]" || echo -e "\033[1;31m [FAIL]"
echo -e "$barra"
return
}
reiniciar_vps () {
echo -ne " \033[1;31m[ ! ] Sudo Reboot"
sleep 3s
echo -e "\033[1;32m [OK]"
(
sudo reboot
) > /dev/null 2>&1
echo -e "$barra"
return
}
host_name () {
unset name
while [[ ${name} = "" ]]; do
echo -ne "\033[1;37m $(fun_trans "Digite o nome do host"): " && read name
tput cuu1 && tput dl1
done
hostnamectl set-hostname $name 
if [ $(hostnamectl status | head -1  | awk '{print $3}') = "${name}" ]; then 
echo -e "\033[1;32m $(fun_trans "Nome de host alterado corretamente")!, $(fun_trans "reiniciar VPS")"
else
echo -e "\033[1;31m $(fun_trans "Nome de host não modificado")!"
fi
echo -e "$barra"
return
}
gestor_fun () {
echo -e " \033[1;32m $(fun_trans "Administrador VPS") [NEW-ADM]"
echo -e "$barra"
while true; do
echo -e "${cor[4]} [1] > \033[1;37m$(fun_trans "Atualizar pacotes")"
echo -e "${cor[4]} [2] > \033[1;37m$(fun_trans "Alterar o nome do VPS")"
echo -e "${cor[4]} [3] > \033[1;37m$(fun_trans "Reiniciar os Serviços")"
echo -e "${cor[4]} [4] > \033[1;37m$(fun_trans "Reiniciar VPS")"
echo -e "${cor[4]} [0] > \033[1;37m$(fun_trans "VOLTAR")\n${barra}"
while [[ ${opx} != @(0|[1-5]) ]]; do
echo -ne "${cor[0]}$(fun_trans "Digite a Opcao"): \033[1;37m" && read opx
tput cuu1 && tput dl1
done
case $opx in
	0)
	return;;
	1)
	update_pak
	break;;
	2)
	host_name
	break;;
	3)
	reiniciar_ser
	break;;
	4)
	reiniciar_vps
	break;;
esac
done
}
gestor_fun