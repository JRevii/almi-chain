#!/bin/sh
# Puesta a punto de antiX tras la instalación. Ejecutar como root.
set -e
usermod -aG sudo recreativa
apt update && apt full-upgrade -y
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime   # el instalador deja Europe/Amsterdam
echo "Europe/Madrid" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
echo "Listo. A partir de aquí: su - recreativa"
