#!/bin/bash
set -euo
set -o pipefail 2>/dev/null || true

umask 077

[[ $EUID -ne 0 ]] && { echo "❌ Ejecuta como root"; exit 1; }

SCRIPT_REAL=$(readlink -f "$0")
chmod 700 "$SCRIPT_REAL"

RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; BLUE="\e[34m"; CYAN="\e[36m"; MAGENTA="\e[35m"; WHITE="\e[97m"; GRAY="\e[90m"; RESET="\e[0m"

# ZyStyle colors
Z1="\e[38;5;45m"; Z2="\e[38;5;207m"; Z3="\e[38;5;81m"; Z4="\e[38;5;213m"; ZRESET="\e[0m"

MAX_CONN=5
WHITELIST="/etc/adm_whitelist"
LOG="/var/log/adm-gusdev.log"

mkdir -p /etc; touch "$WHITELIST"

pause(){ echo; read -p "⏎ Presiona Enter para continuar..."; }

# Animación original
loader(){
for i in {1..20}; do
  printf "\r${Z3}Cargando [%-20s]${ZRESET}" "$(printf '█%.0s' $(seq 1 $i))"
  sleep 0.03
done
echo
}

status_bar(){
cpu=$(top -bn1 | awk '/Cpu/ {print int($2+$4)"%"}')
ram=$(free | awk '/Mem:/ {print int($3/$2*100)"%"}')
printf "${GRAY} CPU:%s  RAM:%s  ⏰ %s  HOST:%s ${RESET}\n" "$cpu" "$ram" "$(date +%H:%M:%S)" "$(hostname)"
}

gus_title(){
clear
echo -e "${Z1} █████╗ ██████╗ ███╗   ███╗    ███████╗██████╗ ███████╗███████╗"
echo -e "${Z2}██╔══██╗██╔══██╗████╗ ████║    ██╔════╝██╔══██╗██╔════╝██╔════╝"
echo -e "${Z3}███████║██║  ██║██╔████╔██║    █████╗  ██████╔╝█████╗  █████╗  "
echo -e "${Z4}██╔══██║██║  ██║██║╚██╔╝██║    ██╔══╝  ██╔══██╗██╔══╝  ██╔══╝  "
echo -e "${Z1}██║  ██║██████╔╝██║ ╚═╝ ██║    ██║     ██║  ██║███████╗███████╗"
echo -e "${Z2}╚═╝  ╚═╝╚═════╝ ╚═╝     ╚═╝    ╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝${ZRESET}"
echo -e "${GRAY}                    By GusDev | t.me/gusdev06${RESET}"
}

panel_header(){
clear
gus_title
status_bar
echo -e "${Z3}══════════════════════════════════════════════════════════════${ZRESET}"
}

card(){
echo -e "${Z3}╔══════════════════════════════════════════════════════════════╗"
printf  "║ ${WHITE}%-58s${Z3}║\n" "$1"
echo -e "╚══════════════════════════════════════════════════════════════╝${ZRESET}"
}

ver_conexiones(){
panel_header
card "🔌 CONEXIONES ACTIVAS"
printf "${WHITE}%-15s %-22s %-10s${RESET}\n" " Usuario" " IP" " Servicio"
echo " ------------------------------------------------------------"

while read -r line; do
  ip=$(echo "$line" | awk '{print $5}' | cut -d: -f1)
  pid=$(echo "$line" | grep -oP 'pid=\K[0-9]+' || true)
  [[ -z "$pid" ]] && continue
  user=$(ps -o user= -p "$pid" 2>/dev/null || echo "?")
  printf " %-15s %-22s %-10s\n" "$user" "$ip" "SSH"
done < <(ss -tnp 2>/dev/null | grep sshd || true)

while read -r user cmd; do
  ip=$(echo "$cmd" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' || echo "-")
  printf " %-15s %-22s %-10s\n" "$user" "$ip" "DROP"
done < <(ps -eo user,cmd | grep dropbear | grep -v grep || true)

pause
}

bloquear_exceso(){
panel_header
card "🚫 BLOQUEO POR EXCESO DE CONEXIONES"
ss -ntu 2>/dev/null | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | while read -r c ip; do
  grep -q "$ip" "$WHITELIST" && continue
  if [[ $c -gt $MAX_CONN ]]; then
    echo -e "${RED} Bloqueando $ip ($c conexiones)${RESET}"
    iptables -C INPUT -s "$ip" -j DROP 2>/dev/null || iptables -A INPUT -s "$ip" -j DROP
    echo "$(date) Bloqueada $ip por $c conexiones" >> "$LOG"
  fi
done
pause
}

borrar_usuario(){
panel_header
card "🗑️ BORRAR USUARIO"
mapfile -t USERS < <(awk -F: '$3>=1000 && $1!="nobody"{print $1}' /etc/passwd)
select u in "${USERS[@]}" "Cancelar"; do
  [[ "$u" == "Cancelar" ]] && break
  deluser "$u"
  echo -e "${GREEN}Usuario $u eliminado.${RESET}"
  sleep 1
  break
done
}

menu_usuarios(){
while true; do
panel_header
card "👤 CONTROL DE USUARIOS"
printf "${Z3}╔═══════════════╦═══════════════╗\n"
printf "║ 1) Crear      ║ 4) Conectados ║\n"
printf "║ 2) Borrar     ║ 5) Bloquear   ║\n"
printf "║ 3) Passwd     ║ 6) Desbloq    ║\n"
printf "╚═══════════════╩═══════════════╝${ZRESET}\n"
printf "        0) Volver\n"
read -p " Opción → " op
loader
case $op in
1) read -p " Usuario: " u; adduser "$u" ;;
2) borrar_usuario ;;
3) read -p " Usuario: " u; passwd "$u" ;;
4) ver_conexiones ;;
5) read -p " Usuario: " u; passwd -l "$u" ;;
6) read -p " Usuario: " u; passwd -u "$u" ;;
0) break ;;
esac
pause
done
}

menu_seguridad(){
while true; do
panel_header
card "🛡️ SEGURIDAD"
printf "${Z3}╔═══════════════╦═══════════════╗\n"
printf "║ 1) Fail2ban   ║ 4) Ver conx   ║\n"
printf "║ 2) Puerto SSH ║ 5) Bloqueo IP ║\n"
printf "║ 3) Firewall   ║ 0) Volver     ║\n"
printf "╚═══════════════╩═══════════════╝${ZRESET}\n"
read -p " Opción → " op
loader
case $op in
1) apt install fail2ban -y ;;
2) read -p " Puerto: " p; sed -i "s/#Port 22/Port $p/" /etc/ssh/sshd_config; systemctl restart ssh ;;
3) iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
   iptables -A INPUT -p tcp --dport 22 -j ACCEPT
   iptables -P INPUT DROP ;;
4) ver_conexiones ;;
5) bloquear_exceso ;;
0) break ;;
esac
pause
done
}

menu_servicios(){
while true; do
panel_header
card "📦 SERVICIOS"
printf "${Z3}╔═══════════════╦═══════════════╗\n"
printf "║ 1) Dropbear   ║ 4) Trojan-Go  ║\n"
printf "║ 2) SSL        ║ 5) Webmin     ║\n"
printf "║ 3) V2Ray      ║ 0) Volver     ║\n"
printf "╚═══════════════╩═══════════════╝${ZRESET}\n"
read -p " Opción → " op
loader
case $op in
1) apt install dropbear -y ;;
2) apt install stunnel4 -y ;;
3) bash <(curl -Ls https://github.com/v2fly/fhs-install-v2ray/raw/master/install-release.sh) ;;
4) bash <(curl -Ls https://raw.githubusercontent.com/p4gefau1t/trojan-go/master/install.sh) ;;
5)
   apt install -y curl gnupg ca-certificates lsb-release
   curl -fsSL https://download.webmin.com/jcameron-key.asc | gpg --dearmor | tee /usr/share/keyrings/webmin.gpg > /dev/null
   echo "deb [signed-by=/usr/share/keyrings/webmin.gpg] https://download.webmin.com/download/repository sarge contrib" \
   | tee /etc/apt/sources.list.d/webmin.list > /dev/null
   apt update && apt install -y webmin
   ;;
0) break ;;
esac
pause
done
}

while true; do
panel_header
card "🏠 PANEL PRINCIPAL"
printf "${Z3}╔═══════════════╦═══════════════╗\n"
printf "║ 1) Usuarios   ║ 4) Seguridad  ║\n"
printf "║ 2) Servicios  ║ 5) VPS Info   ║\n"
printf "║ 3) Conexiones ║ 0) Salir      ║\n"
printf "╚═══════════════╩═══════════════╝${ZRESET}\n"
read -p " Opción → " op
loader
case $op in
1) menu_usuarios ;;
2) menu_servicios ;;
3) ver_conexiones ;;
4) menu_seguridad ;;
5) panel_header; card "📊 ESTADO VPS"; hostnamectl; uptime; free -h; df -h /; pause ;;
0) exit ;;
esac
done

