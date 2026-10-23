#!/bin/bash
# =====================================================================
# restaurar_prueba.sh · Prueba de restauración de la última copia
# Restaura la copia más reciente en una base de datos APARTE
# (almichain_restaurada), sin tocar la de producción, y compara los datos.
# Se instala como /usr/local/sbin/almichain-restaurar-prueba
# Uso:  sudo almichain-restaurar-prueba            (borra la BD de prueba al final)
#       sudo almichain-restaurar-prueba --conservar (la deja para revisarla)
# =====================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo"; exit 1; }

export RESTIC_REPOSITORY="${RESTIC_REPOSITORY:-/srv/copias/restic}"
export RESTIC_PASSWORD_FILE="${RESTIC_PASSWORD_FILE:-/root/secretos/restic.txt}"
BD="almichain"
BD_PRUEBA="almichain_restaurada"
DESTINO="/var/tmp/restauracion-$(date +%Y%m%d-%H%M)"
INFORME="/var/log/almichain-restauracion.log"

consulta() { sudo -u postgres psql -d "$1" -Atc "$2"; }

{
echo "=================================================================="
echo "Prueba de restauración · $(date '+%F %T')"
echo "-- Última copia disponible:"
restic snapshots --latest 1 --host srv-odoo

echo "-- 1. Restaurar la copia en $DESTINO (carpeta solo para root)"
install -d -m 700 "$DESTINO"
restic restore latest --host srv-odoo --target "$DESTINO"
VOLCADO="$DESTINO/var/backups/almichain/$BD.dump"
[ -s "$VOLCADO" ] || { echo "ERROR: la copia no contiene $BD.dump"; exit 1; }

echo "-- 2. Cargar el volcado en una BD aparte ($BD_PRUEBA)"
sudo -u postgres dropdb --if-exists "$BD_PRUEBA"
sudo -u postgres createdb -O odoo "$BD_PRUEBA"
# root abre el fichero y se lo pasa a pg_restore por la entrada estándar
sudo -u postgres pg_restore --no-owner --role=odoo -d "$BD_PRUEBA" < "$VOLCADO"

echo "-- 3. Comparar producción con lo restaurado"
FALLOS=0
compara() {   # $1 = descripción, $2 = consulta SQL
  local a b
  a=$(consulta "$BD" "$2"); b=$(consulta "$BD_PRUEBA" "$2")
  if [ "$a" = "$b" ]; then r="OK"; else r="DISTINTO"; FALLOS=$((FALLOS+1)); fi
  printf '   %-34s producción=%-8s restaurada=%-8s %s\n' "$1" "$a" "$b" "$r"
}
compara "Facturas publicadas"   "SELECT count(*) FROM account_move WHERE move_type='out_invoice' AND state='posted'"
compara "Importe total facturado" "SELECT coalesce(sum(amount_total),0) FROM account_move WHERE move_type='out_invoice' AND state='posted'"
compara "Contactos"             "SELECT count(*) FROM res_partner"
compara "Productos"             "SELECT count(*) FROM product_template"
compara "Usuarios"              "SELECT count(*) FROM res_users"
echo "   (Si se ha facturado algo después de la última copia, es normal que producción tenga más.)"

echo "-- 4. Adjuntos (filestore)"
N_PROD=$(find /var/lib/odoo/filestore/$BD -type f 2>/dev/null | wc -l)
N_COPIA=$(find "$DESTINO/var/lib/odoo/filestore/$BD" -type f 2>/dev/null | wc -l)
echo "   Ficheros: producción=$N_PROD restaurados=$N_COPIA"

if [ "${1:-}" != "--conservar" ]; then
  sudo -u postgres dropdb "$BD_PRUEBA"
  rm -rf "$DESTINO"
  echo "-- BD de prueba y ficheros temporales borrados"
fi

if [ "$FALLOS" -eq 0 ]; then
  echo "RESULTADO: RESTAURACIÓN CORRECTA"
else
  echo "RESULTADO: $FALLOS diferencia(s). Revisa si son datos nuevos desde la última copia."
fi
} 2>&1 | tee -a "$INFORME"
