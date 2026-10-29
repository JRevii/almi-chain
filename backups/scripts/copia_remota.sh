#!/bin/bash
# =====================================================================
# copia_remota.sh · Copia REMOTA de restic en AWS S3 (regla 3-2-1)
# Se instala como /usr/local/sbin/almichain-copia-remota.
# Copia las instantáneas del repositorio local (/srv/copias/restic) a un
# repositorio restic en S3, cifrado con su propia clave.
#
# Uso:  sudo almichain-copia-remota               copia local → S3 y comprueba
#       sudo almichain-copia-remota --iniciar     crea el repositorio en S3 (1.ª vez)
#       sudo almichain-copia-remota --restaurar   prueba de restauración DESDE S3
#
# Secretos (solo root, nunca en Git):
#   /root/secretos/aws-s3.env        credenciales de AWS + RESTIC_REPOSITORY de S3
#   /root/secretos/restic-remoto.txt clave del repositorio remoto (se crea con --iniciar)
#
# AWS Academy: las credenciales caducan al cerrar el Learner Lab. Con el lab
# apagado, la copia falla y lo deja escrito en el registro.
# =====================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo"; exit 1; }

SECRETOS="/root/secretos"
ENV_AWS="$SECRETOS/aws-s3.env"
CLAVE_REMOTA="$SECRETOS/restic-remoto.txt"
LOCAL_REPO="/srv/copias/restic"
LOCAL_CLAVE="$SECRETOS/restic.txt"

[ -r "$ENV_AWS" ] || { echo "ERROR: falta $ENV_AWS (ver backups/README.md)"; exit 1; }
set -a; . "$ENV_AWS"; set +a          # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN, RESTIC_REPOSITORY
: "${RESTIC_REPOSITORY:?Falta RESTIC_REPOSITORY en $ENV_AWS}"
export RESTIC_PASSWORD_FILE="$CLAVE_REMOTA"

echo "== $(date '+%F %T') · Copia remota ${1:-}"

case "${1:-}" in
--iniciar)
  if [ ! -s "$CLAVE_REMOTA" ]; then
    umask 077
    openssl rand -base64 32 > "$CLAVE_REMOTA"
    echo "Clave nueva en $CLAVE_REMOTA. GUÁRDALA EN KEEPASSXC: sin ella la copia remota no se puede recuperar."
  fi
  # Mismos parámetros de troceado que el repositorio local: copiar es más rápido y ocupa menos
  restic init --from-repo "$LOCAL_REPO" --from-password-file "$LOCAL_CLAVE" --copy-chunker-params
  ;;
--restaurar)
  # Reutiliza la prueba de restauración normal, pero leyendo de S3
  RESTIC_REPOSITORY="$RESTIC_REPOSITORY" RESTIC_PASSWORD_FILE="$CLAVE_REMOTA" \
    /usr/local/sbin/almichain-restaurar-prueba
  ;;
"")
  if ! restic cat config >/dev/null 2>&1; then
    echo "ERROR: no se puede abrir el repositorio de S3."
    echo "       ¿Learner Lab apagado o credenciales caducadas? Renueva $ENV_AWS."
    exit 1
  fi
  restic copy --from-repo "$LOCAL_REPO" --from-password-file "$LOCAL_CLAVE" --host srv-odoo
  restic forget --host srv-odoo --keep-daily 7 --keep-weekly 4 --keep-monthly 6 --prune
  restic check --read-data-subset=5%
  restic snapshots --host srv-odoo --latest 3
  echo "== $(date '+%F %T') · Copia remota terminada correctamente"
  ;;
*)
  echo "Uso: almichain-copia-remota [--iniciar | --restaurar]"; exit 1 ;;
esac
