#!/bin/bash
# =====================================================================
# copia.sh · Copia de seguridad diaria del servidor Odoo (restic)
# Se instala como /usr/local/sbin/almichain-copia y lo lanza el timer
# almichain-copia.timer todos los días a las 02:30.
#
# Qué se copia:
#   - Volcado de TODAS las bases de datos (pg_dump, formato custom)
#     y de los roles de PostgreSQL (pg_dumpall --globals-only)
#   - Adjuntos de Odoo (filestore)
#   - Configuración: Odoo, Nginx, certificados, CA, RAID, cortafuegos
# Dónde: repositorio restic CIFRADO en un disco aparte del RAID (/srv/copias)
# Retención: 7 diarias, 4 semanales y 6 mensuales
# =====================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root"; exit 1; }

export RESTIC_REPOSITORY="${RESTIC_REPOSITORY:-/srv/copias/restic}"
export RESTIC_PASSWORD_FILE="${RESTIC_PASSWORD_FILE:-/root/secretos/restic.txt}"
VOLCADOS="/var/backups/almichain"

echo "== $(date '+%F %T') · Inicio de la copia"
mountpoint -q /srv/copias || { echo "ERROR: /srv/copias no está montado"; exit 1; }

# 1. Volcados de PostgreSQL (consistentes aunque Odoo esté funcionando)
# Los volcados los escribe root (redirección) en una carpeta solo para root
install -d -m 700 "$VOLCADOS"
rm -f "$VOLCADOS"/*
# shellcheck disable=SC2024
sudo -u postgres pg_dumpall --globals-only > "$VOLCADOS/roles.sql"
for bd in $(sudo -u postgres psql -Atc "SELECT datname FROM pg_database WHERE NOT datistemplate AND datname <> 'postgres'"); do
  echo "Volcando la base de datos $bd"
  # shellcheck disable=SC2024
  sudo -u postgres pg_dump -Fc "$bd" > "$VOLCADOS/$bd.dump"
done

# 2. Copia con restic (cifrada y deduplicada)
restic backup --tag diaria --host srv-odoo \
  "$VOLCADOS" \
  /var/lib/odoo/filestore \
  /etc/odoo /etc/nginx /etc/ssl/almichain /root/ca \
  /etc/mdadm/mdadm.conf /etc/fstab /etc/ufw /etc/ssh/sshd_config.d

# 3. Retención y limpieza
restic forget --host srv-odoo --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune

# 4. Comprobar que el repositorio está sano (lee un 5 % de los datos cada día)
restic check --read-data-subset=5%

rm -f "$VOLCADOS"/*
echo "== $(date '+%F %T') · Copia terminada correctamente"
