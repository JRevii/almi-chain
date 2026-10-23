#!/bin/bash
# =====================================================================
# 05-copias.sh · Plan de copias de seguridad con restic
# Usa un tercer disco (por defecto sdd), APARTE del RAID: si el RAID
# se estropea o alguien borra datos, la copia sigue a salvo.
# Instala la copia diaria (02:30) y hace la primera copia.
# Uso:  sudo bash 05-copias.sh          (disco por defecto: sdd)
#       sudo bash 05-copias.sh sdX
# =====================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo: sudo bash $0"; exit 1; }

DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS="$DIR/../../backups/scripts"
DISCO="/dev/${1:-sdd}"
COPIAS="/srv/copias"
SECRETOS="/root/secretos"
export RESTIC_REPOSITORY="$COPIAS/restic"
export RESTIC_PASSWORD_FILE="$SECRETOS/restic.txt"

echo "== 1. Disco de copias ($DISCO)"
if mountpoint -q "$COPIAS"; then
  echo "$COPIAS ya está montado."
else
  [ -b "$DISCO" ] || { echo "No existe $DISCO. Mira los discos con: lsblk"; exit 1; }
  if [ "$(lsblk -no NAME "$DISCO" | wc -l)" -gt 1 ] || lsblk -no MOUNTPOINTS "$DISCO" | grep -q .; then
    echo "$DISCO no está vacío. Revisa con lsblk."; exit 1
  fi
  lsblk -o NAME,SIZE,TYPE,MOUNTPOINTS
  read -r -p "Se BORRARÁ todo en $DISCO. Escribe SI para seguir: " OK
  [ "$OK" = "SI" ] || { echo "Cancelado."; exit 1; }
  mkfs.ext4 -q -L copias "$DISCO"
  mkdir -p "$COPIAS"
  echo "UUID=$(blkid -s UUID -o value "$DISCO") $COPIAS ext4 defaults,noatime,nofail 0 2" >> /etc/fstab
  systemctl daemon-reload
  mount "$COPIAS"
fi
chmod 700 "$COPIAS"

echo "== 2. restic y repositorio cifrado"
DEBIAN_FRONTEND=noninteractive apt-get -y install restic
install -d -m 700 "$SECRETOS"
if [ ! -s "$RESTIC_PASSWORD_FILE" ]; then
  openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | cut -c1-32 > "$RESTIC_PASSWORD_FILE"
  chmod 600 "$RESTIC_PASSWORD_FILE"
fi
if [ ! -f "$RESTIC_REPOSITORY/config" ]; then
  restic init
fi

echo "== 3. Scripts y copia diaria automática"
install -m 750 "$SCRIPTS/copia.sh"             /usr/local/sbin/almichain-copia
install -m 750 "$SCRIPTS/restaurar_prueba.sh"  /usr/local/sbin/almichain-restaurar-prueba
install -m 644 "$SCRIPTS/almichain-copia.service" /etc/systemd/system/
install -m 644 "$SCRIPTS/almichain-copia.timer"   /etc/systemd/system/
systemctl daemon-reload
systemctl enable --now almichain-copia.timer

echo "== 4. Primera copia"
systemctl start almichain-copia.service
journalctl -u almichain-copia.service -n 15 --no-pager
restic snapshots

echo
echo "Listo. Próxima copia:"
systemctl list-timers almichain-copia.timer --no-pager
echo
echo "IMPORTANTE: guarda en KeePassXC la contraseña de $RESTIC_PASSWORD_FILE."
echo "Sin ella, las copias NO se pueden recuperar."
echo "Prueba de restauración:  sudo almichain-restaurar-prueba"
