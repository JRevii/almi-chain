#!/bin/bash
# =====================================================================
# 02-raid.sh · Disco redundante (RAID 1) para los datos
# Crea /dev/md0 en espejo con dos discos y lo monta en /srv/datos.
# La base de datos (PostgreSQL) y los adjuntos de Odoo se guardan ahí.
# Uso:  sudo bash 02-raid.sh            (discos por defecto: sdb y sdc)
#       sudo bash 02-raid.sh sdX sdY    (si en tu VM tienen otro nombre)
# =====================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo: sudo bash $0"; exit 1; }

D1="/dev/${1:-sdb}"
D2="/dev/${2:-sdc}"
MD="/dev/md0"
DATOS="/srv/datos"

echo "== 1. Comprobaciones"
if [ -e "$MD" ]; then echo "$MD ya existe. Nada que hacer."; cat /proc/mdstat; exit 0; fi
for d in "$D1" "$D2"; do
  [ -b "$d" ] || { echo "No existe $d. Mira los discos con: lsblk"; exit 1; }
  if lsblk -no MOUNTPOINTS "$d" | grep -q .; then echo "$d está montado: no es un disco vacío."; exit 1; fi
  if [ "$(lsblk -no NAME "$d" | wc -l)" -gt 1 ]; then echo "$d tiene particiones: no es un disco vacío."; exit 1; fi
done
lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
echo
read -r -p "Se BORRARÁ todo en $D1 y $D2. Escribe SI para seguir: " OK
[ "$OK" = "SI" ] || { echo "Cancelado."; exit 1; }

echo "== 2. Crear el RAID 1"
DEBIAN_FRONTEND=noninteractive apt-get -y install mdadm
mdadm --create "$MD" --level=1 --raid-devices=2 --metadata=1.2 --run "$D1" "$D2"
mkfs.ext4 -q -L datos "$MD"

echo "== 3. Que el RAID se monte solo al arrancar"
mdadm --detail --scan | grep -F "$MD" >> /etc/mdadm/mdadm.conf
update-initramfs -u
UUID=$(blkid -s UUID -o value "$MD")
mkdir -p "$DATOS"
echo "UUID=$UUID $DATOS ext4 defaults,noatime,nofail 0 2" >> /etc/fstab
systemctl daemon-reload
mount "$DATOS"

echo "== 4. Llevar los datos de PostgreSQL y de Odoo al RAID (montajes bind)"
for dir in postgresql odoo; do
  mkdir -p "$DATOS/$dir" "/var/lib/$dir"
  echo "$DATOS/$dir /var/lib/$dir none bind,nofail,x-systemd.requires-mounts-for=$DATOS 0 0" >> /etc/fstab
done
systemctl daemon-reload
mount /var/lib/postgresql
mount /var/lib/odoo

echo
echo "Listo. Estado del RAID (tiene que acabar en [UU]; la primera sincronización tarda unos minutos):"
cat /proc/mdstat
findmnt "$DATOS"; findmnt /var/lib/postgresql; findmnt /var/lib/odoo
