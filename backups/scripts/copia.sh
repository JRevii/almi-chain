#!/bin/bash
# =====================================================================
# copia.sh · Copia de seguridad diaria del servidor Odoo (restic)
# Se instala como /usr/local/sbin/almichain-copia y lo lanza cron
# (/etc/cron.d/almichain-copia) todos los días a las 02:30.
#
# Qué se copia:
#   - Volcado de las DOS bases de datos (almichain = Odoo, almichain_local = BD
#     del local) con pg_dump, y los usuarios de PostgreSQL
#   - Adjuntos de Odoo (filestore)
#   - Configuración: stack de Docker, certificados, CA, RAID, cortafuegos, SSH
# Dónde: repositorio restic CIFRADO en el disco C (/srv/copias), aparte del RAID
# Retención: 7 diarias, 4 semanales y 6 mensuales
# =====================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta como root"; exit 1; }

export RESTIC_REPOSITORY="${RESTIC_REPOSITORY:-/srv/copias/restic}"
export RESTIC_PASSWORD_FILE="${RESTIC_PASSWORD_FILE:-/root/secretos/restic.txt}"
VOLCADOS="/var/backups/almichain"
dc() { docker compose --project-directory /opt/almichain "$@"; }

echo "== $(date '+%F %T') · Inicio de la copia"
mountpoint -q /srv/copias || { echo "ERROR: /srv/copias no está montado"; exit 1; }

# 1. Volcados de PostgreSQL (consistentes aunque Odoo esté funcionando)
install -d -m 700 "$VOLCADOS"
rm -f "$VOLCADOS"/*
dc exec -T -u postgres db pg_dumpall --globals-only --no-role-passwords > "$VOLCADOS/usuarios.sql"
for bd in almichain almichain_local; do
  echo "Volcando la base de datos $bd"
  dc exec -T -u postgres db pg_dump -Fc "$bd" > "$VOLCADOS/$bd.dump"
done

# 2. Copia con restic (cifrada, incremental y deduplicada)
restic backup --tag diaria --host srv-odoo \
  "$VOLCADOS" \
  /srv/datos/odoo/filestore \
  /opt/almichain /etc/ssl/almichain /root/ca \
  /etc/mdadm/mdadm.conf /etc/fstab /etc/ufw /etc/ssh/sshd_config.d

# 3. Retención y limpieza
restic forget --host srv-odoo --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune

# 4. Comprobar que el repositorio está sano (lee un 5 % de los datos cada día)
restic check --read-data-subset=5%

rm -f "$VOLCADOS"/*
echo "== $(date '+%F %T') · Copia terminada correctamente"
