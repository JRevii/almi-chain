#!/bin/sh
# Mínimos privilegios. Ejecutar como root, en dos pasos:
#   sh 05-seguridad.sh 1   -> crea adminrec con sudo
#   (comprobar que adminrec puede usar sudo)
#   sh 05-seguridad.sh 2   -> quita sudo a recreativa, contraseña de root y SSH sin root
set -e
case "$1" in
1)
  adduser --gecos "" adminrec          # pide contraseña: guárdala en KeePassXC
  usermod -aG sudo adminrec
  echo
  echo "Comprueba en tty2 (Ctrl+Alt+F2): entra como adminrec y ejecuta  sudo -v"
  echo "Si no da error, vuelve a root y ejecuta:  sh 05-seguridad.sh 2"
  ;;
2)
  id -nG adminrec | grep -qw sudo || { echo "adminrec no está en el grupo sudo. Paro."; exit 1; }
  deluser recreativa sudo
  echo "-- Lo que puede hacer recreativa con sudo ahora:"
  sudo -l -U recreativa || true
  echo "-- Nueva contraseña de root (guárdala en KeePassXC):"
  passwd root
  # SSH: sin login de root y solo para adminrec
  grep -q '^Include /etc/ssh/sshd_config.d' /etc/ssh/sshd_config || \
    sed -i '1i Include /etc/ssh/sshd_config.d/*.conf' /etc/ssh/sshd_config
  mkdir -p /etc/ssh/sshd_config.d
  printf 'PermitRootLogin no\nAllowUsers adminrec\n' > /etc/ssh/sshd_config.d/10-recreativa.conf
  /usr/sbin/sshd -t
  service ssh restart
  echo "-- Configuración de SSH aplicada:"
  /usr/sbin/sshd -T | grep -i -e permitrootlogin -e allowusers
  echo "Listo. Desde el portátil: ssh -p 2222 adminrec@127.0.0.1"
  ;;
*)
  echo "Uso: sh 05-seguridad.sh 1|2"; exit 1 ;;
esac
