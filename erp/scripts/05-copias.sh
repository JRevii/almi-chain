#!/bin/bash
# =====================================================================
# 05-copias.sh · Plan de copias de seguridad con restic + cron
# Usa el disco C (por defecto sdd), APARTE del RAID: si el RAID se
# estropea o alguien borra datos, la copia sigue a salvo.
# Programa la copia diaria (02:30, y al arrancar por si estaba apagado) con cron y hace la primera.
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
LOG="/var/log/almichain-copia.log"
export RESTIC_REPOSITORY="$COPIAS/restic"
export RESTIC_PASSWORD_FILE="$SECRETOS/restic.txt"

echo "== 1. Disco C de copias ($DISCO)"
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
DEBIAN_FRONTEND=noninteractive apt-get -y install restic cron
install -d -m 700 "$SECRETOS"
if [ ! -s "$RESTIC_PASSWORD_FILE" ]; then
  openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | cut -c1-32 > "$RESTIC_PASSWORD_FILE"
  chmod 600 "$RESTIC_PASSWORD_FILE"
fi
[ -f "$RESTIC_REPOSITORY/config" ] || restic init

echo "== 3. Scripts y copia diaria con cron (02:30 y al arrancar)"
install -m 750 "$SCRIPTS/copia.sh"            /usr/local/sbin/almichain-copia
install -m 750 "$SCRIPTS/restaurar_prueba.sh" /usr/local/sbin/almichain-restaurar-prueba
cat > /etc/cron.d/almichain-copia <<EOF
# Almi-Chain: copia de seguridad diaria (restic) a las 02:30
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
30 2 * * * root /usr/local/sbin/almichain-copia >> $LOG 2>&1
# Si el servidor estaba apagado a las 02:30, copia 5 min después de arrancar (da tiempo a Docker y PostgreSQL)
@reboot root sleep 300 && /usr/local/sbin/almichain-copia >> $LOG 2>&1
EOF
chmod 644 /etc/cron.d/almichain-copia
cat > /etc/logrotate.d/almichain <<EOF
$LOG /var/log/almichain-restauracion.log {
    monthly
    rotate 12
    compress
    missingok
    notifempty
}
EOF
systemctl enable --now cron

echo "== 4. Primera copia"
/usr/local/sbin/almichain-copia 2>&1 | tee -a "$LOG"
restic snapshots

echo
echo "Listo. La copia se hará sola todos los días a las 02:30 (registro: $LOG)."
echo "IMPORTANTE: guarda en KeePassXC la contraseña de $RESTIC_PASSWORD_FILE."
echo "Sin ella, las copias NO se pueden recuperar."
echo "Prueba de restauración:  sudo almichain-restaurar-prueba"
