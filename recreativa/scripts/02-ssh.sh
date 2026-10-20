#!/bin/sh
# SSH para administrar la VM desde el anfitrión (NAT 127.0.0.1:2222 -> 22).
# Arreglo: el postinst de openssh-client no consigue crear el grupo _ssh,
# así que se crea a mano antes de configurar los paquetes.
set -e
getent group _ssh >/dev/null || sudo groupadd -r _ssh
sudo apt install -y openssh-server || true
sudo dpkg --configure -a
sudo service ssh start
sudo service ssh status
