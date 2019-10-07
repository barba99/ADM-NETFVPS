#!/bin/bash
declare -A cor=( [0]="\033[1;37m" [1]="\033[1;34m" [2]="\033[1;31m" [3]="\033[1;33m" [4]="\033[1;32m" )
barra="\033[0m\e[34m▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\033[1;37m"
mportas () {
unset portas
portas_var=$(lsof -V -i tcp -P -n | grep -v "ESTABLISHED" |grep -v "COMMAND" | grep "LISTEN")
while read port; do
var1=$(echo $port | awk '{print $1}') && var2=$(echo $port | awk '{print $9}' | awk -F ":" '{print $2}')
[[ "$(echo -e $portas|grep "$var1 $var2")" ]] || portas+="$var1 $var2\n"
done <<< "$portas_var"
i=1
echo -e "$portas"
}
fun_ip () {
if [[ -e /etc/MEUIPADM ]]; then
IP="$(cat /etc/MEUIPADM)"
else
MEU_IP=$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
MEU_IP2=$(wget -qO- ipv4.icanhazip.com)
[[ "$MEU_IP" != "$MEU_IP2" ]] && IP="$MEU_IP2" || IP="$MEU_IP"
echo "$MEU_IP2" > /etc/MEUIPADM
fi
}
fun_eth () {
eth=$(ifconfig | grep -v inet6 | grep -v lo | grep -v 127.0.0.1 | grep "encap:Ethernet" | awk '{print $1}')
    [[ $eth != "" ]] && {
    echo -e "$barra"
    echo -e "${cor[3]} Aplicar Sistema Para Mejorar Pacotes Ssh?"
    echo -e "${cor[3]} Opcion Para Usuarios Avanzados"
    echo -e "$barra"
    read -p " [S/N]: " -e -i n sshsn
           [[ "$sshsn" = @(s|S|y|Y) ]] && {
           echo -e "${cor[1]} Correcion de problemas de paquete SSH..."
           echo -e "Cual Taza RX"
           echo -ne "[ 1 - 999999999 ]: "; read rx
           [[ "$rx" = "" ]] && rx="999999999"
           echo -e "Cual  Taza TX"
           echo -ne "[ 1 - 999999999 ]: "; read tx
           [[ "$tx" = "" ]] && tx="999999999"
           apt-get install ethtool -y > /dev/null 2>&1
           ethtool -G $eth rx $rx tx $tx > /dev/null 2>&1
           }
     echo -e "$barra"
     }
}

fun_bar () {
comando[0]="$1"
comando[1]="$2"
 (
[[ -e $HOME/fim ]] && rm $HOME/fim
${comando[0]} -y > /dev/null 2>&1
${comando[1]} -y > /dev/null 2>&1
touch $HOME/fim
 ) > /dev/null 2>&1 &
echo -ne "\033[1;33m ["
while true; do
   for((i=0; i<18; i++)); do
   echo -ne "\033[1;31m##"
   sleep 0.1s
   done
   [[ -e $HOME/fim ]] && rm $HOME/fim && break
   echo -e "\033[1;33m]"
   sleep 1s
   tput cuu1
   tput dl1
   echo -ne "\033[1;33m ["
done
echo -e "\033[1;33m]\033[1;31m -\033[1;32m 100%\033[1;37m"
}
fun_dropbear () {
 [[ -e /etc/default/dropbear ]] && {
 echo -e "\033[1;32m ELIMINANDO DROPBEAR\n$barra"
 service dropbear stop & >/dev/null 2>&1
 fun_bar "apt-get remove dropbear -y"
 echo -e "$barra\n\033[1;32m Dropbear ELIMINADO\n$barra"
 [[ -e /etc/default/dropbear ]] && rm /etc/default/dropbear
 return 0
 }
echo -e "\033[1;32m DROPBEAR \033[1;31m[\033[1;33mADM_NETFREVPS\033[1;31m]\n$barra"
echo -e "\033[1;31m Escriba los Puertos en Orden Consecutivo:\033[1;32m 53 O 443\033[1;37m"
echo -e "$barra"
echo -ne "\033[1;31m Escriba Los Puertos: \033[1;37m" && read DPORT
tput cuu1 && tput dl1
TTOTAL=($DPORT)
    for((i=0; i<${#TTOTAL[@]}; i++)); do
        [[ $(mportas|grep "${TTOTAL[$i]}") = "" ]] && {
        echo -e "\033[1;33m Puerto Escogido:\033[1;32m ${TTOTAL[$i]} OK"
        PORT="$PORT ${TTOTAL[$i]}"
        } || {
        echo -e "\033[1;33m Puerto Escogido:\033[1;31m ${TTOTAL[$i]} FALLO"
        }
   done
  [[  -z $PORT ]] && {
  echo -e "\033[1;31m Ningun  Puerto Valido\033[0m"
  return 1
  }
sysvar=$(cat -n /etc/issue |grep 1 |cut -d' ' -f6,7,8 |sed 's/1//' |sed 's/      //' | grep -o Ubuntu)
[[ ! $(cat /etc/shells|grep "/bin/false") ]] && echo -e "/bin/false" >> /etc/shells
[[ "$sysvar" != "" ]] && {
echo -e "Port 22
Protocol 2
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
#UseLogin no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes" > /etc/ssh/sshd_config
echo -e "${cor[2]} Instalando dropbear"
echo -e "$barra"
fun_bar "apt-get install dropbear -y"
echo -e "$barra"
touch /etc/bannerssh
echo -e "${cor[2]} Configurando dropbear"
cat <<EOF > /etc/default/dropbear
NO_START=0
DROPBEAR_EXTRA_ARGS="VAR"
DROPBEAR_BANNER="/etc/bannerssh"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
for dpts in $(echo $PORT); do
sed -i "s/VAR/-p $dpts VAR/g" /etc/default/dropbear
done
sed -i "s/VAR//g" /etc/default/dropbear
} || {
echo -e "Port 22
Protocol 2
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication yes
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
#UseLogin no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes" > /etc/ssh/sshd_config
echo -e "${cor[2]} Instalando dropbear"
echo -e "$barra"
fun_bar "apt-get install dropbear -y"
touch /etc/bannerssh
echo -e "$barra"
echo -e "${cor[2]} Configurando dropbear"
cat <<EOF > /etc/default/dropbear
NO_START=0
DROPBEAR_EXTRA_ARGS="VAR"
DROPBEAR_BANNER="/etc/bannerssh"
DROPBEAR_RECEIVE_WINDOW=65536
EOF
for dpts in $(echo $PORT); do
sed -i "s/VAR/-p $dpts VAR/g" /etc/default/dropbear
done
sed -i "s/VAR//g" /etc/default/dropbear
}
fun_eth
service ssh restart > /dev/null 2>&1
service dropbear restart > /dev/null 2>&1
echo -e "${cor[3]} SU DROPBEAR QUEDO INSTALADO CON EXITO\n$barra"
#UFW
for ufww in $(mportas|awk '{print $2}'); do
ufw allow $ufww > /dev/null 2>&1
done
}
fun_dropbear
