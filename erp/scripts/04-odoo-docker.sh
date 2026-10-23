#!/bin/bash
# =====================================================================
# 04-odoo-docker.sh · Docker + Odoo 19 Community + PostgreSQL 16 + Nginx
# Instala Docker, copia el stack a /opt/almichain, genera los secretos,
# crea la base de datos "almichain" con los módulos del reto y lo arranca.
# Uso:  sudo bash 04-odoo-docker.sh     (después de 01, 02 y 03)
# =====================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo: sudo bash $0"; exit 1; }

REPO="$(cd "$(dirname "$0")/.." && pwd)"     # carpeta erp/ del repositorio
STACK="/opt/almichain"
SECRETOS="/root/secretos"
BD="almichain"
MODULOS="account,sale_management,crm,hr,stock,mass_mailing,point_of_sale,l10n_es,base_automation"
IMG_ODOO="odoo:19.0"
IMG_PG="postgres:16"

genera_clave() { openssl rand -base64 48 | tr -dc 'A-Za-z0-9' | cut -c1-28; }
dc() { docker compose --project-directory "$STACK" "$@"; }

echo "== 1. Comprobaciones"
mountpoint -q /srv/datos || { echo "El RAID no está montado en /srv/datos. Ejecuta antes 02-raid.sh."; exit 1; }
[ -s /etc/ssl/almichain/odoo.crt ] || { echo "Falta el certificado. Ejecuta antes 03-certificados.sh."; exit 1; }

echo "== 2. Docker (paquetes de Ubuntu, con actualizaciones de seguridad automáticas)"
export DEBIAN_FRONTEND=noninteractive
apt-get -y install docker.io docker-compose-v2
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<'EOF'
{
  "log-driver": "local",
  "log-opts": { "max-size": "20m", "max-file": "5" },
  "live-restore": true
}
EOF
systemctl enable docker
systemctl restart docker
# El administrador NO se añade al grupo docker (equivaldría a ser root sin contraseña): se usa sudo.

echo "== 3. Copiar el stack a $STACK"
install -d -m 750 "$STACK"
cp -r "$REPO/docker/." "$STACK/"
chmod 755 "$STACK/initdb" && chmod 644 "$STACK/initdb/"*.sh
dc pull

echo "== 4. Secretos (generados al azar, solo en este servidor)"
install -d -m 700 "$SECRETOS"
for s in pg_super pg_odoo pg_local odoo-master odoo-admin; do
  [ -s "$SECRETOS/$s.txt" ] || genera_clave > "$SECRETOS/$s.txt"
done
chmod 600 "$SECRETOS"/*.txt
# Cada contenedor solo puede leer el secreto que necesita
PG_UID=$(docker run --rm --entrypoint id "$IMG_PG" -u postgres)
ODOO_UID=$(docker run --rm --entrypoint id "$IMG_ODOO" -u)
ODOO_GID=$(docker run --rm --entrypoint id "$IMG_ODOO" -g)
chown "$PG_UID" "$SECRETOS"/pg_*.txt
chmod 400 "$SECRETOS"/pg_*.txt

echo "== 5. odoo.conf con la contraseña de la BD y la contraseña maestra cifrada"
MASTER_HASH=$(docker run --rm -i --entrypoint python3 "$IMG_ODOO" -c \
  "import sys; from passlib.context import CryptContext; print(CryptContext(['pbkdf2_sha512']).hash(sys.stdin.read().strip()))" \
  < "$SECRETOS/odoo-master.txt")
MASTER_HASH="$MASTER_HASH" python3 - "$STACK/odoo.conf.plantilla" "$SECRETOS/pg_odoo.txt" "$STACK/odoo.conf" <<'EOF'
import os, sys
plantilla, fichero_pw, destino = sys.argv[1:4]
texto = open(plantilla).read()
texto = texto.replace('__PG_ODOO__', open(fichero_pw).read().strip())
texto = texto.replace('__MASTER_HASH__', os.environ['MASTER_HASH'])
open(destino, 'w').write(texto)
EOF
chown "root:$ODOO_GID" "$STACK/odoo.conf"
chmod 640 "$STACK/odoo.conf"
chown -R "$ODOO_UID:$ODOO_GID" /srv/datos/odoo

echo "== 6. Arrancar PostgreSQL"
dc up -d db
for _ in $(seq 1 30); do
  [ "$(docker inspect -f '{{.State.Health.Status}}' almichain-db-1)" = "healthy" ] && break
  sleep 2
done
docker inspect -f 'PostgreSQL: {{.State.Health.Status}}' almichain-db-1

echo "== 7. Crear la base de datos '$BD' (tarda 5-10 minutos)"
if dc exec -T -u postgres db psql -Atc "SELECT 1 FROM pg_database WHERE datname='$BD'" | grep -q 1; then
  echo "La base de datos $BD ya existe: no se toca."
else
  dc run --rm odoo odoo -d "$BD" -i base --load-language=es_ES --stop-after-init --no-http
  # La contraseña de admin se mete por la entrada estándar, no en la línea de comandos
  python3 - "$STACK/odoo-setup.py" "$SECRETOS/odoo-admin.txt" <<'EOF' | dc run --rm -T odoo odoo shell -d almichain --no-http
import sys
print(open(sys.argv[1]).read().replace('__ADMIN__', open(sys.argv[2]).read().strip()))
EOF
  dc run --rm odoo odoo -d "$BD" -i "$MODULOS" --stop-after-init --no-http
fi

echo "== 8. Arrancar todo"
dc up -d
for _ in $(seq 1 60); do
  curl -s -o /dev/null -w '%{http_code}' https://odoo.almichain.lan/web/login | grep -q 200 && break
  sleep 3
done
dc ps
echo
curl -s -o /dev/null -w "HTTP  -> %{http_code} (tiene que ser 301)\n" http://odoo.almichain.lan/
curl -s -o /dev/null -w "HTTPS -> %{http_code} (tiene que ser 200)\n" https://odoo.almichain.lan/web/login
echo
echo "Listo. Odoo: https://odoo.almichain.lan · usuario admin"
echo "Contraseñas en $SECRETOS (sudo cat ...): odoo-admin.txt, odoo-master.txt. Pásalas a KeePassXC."
echo "Siguiente paso: sudo bash 05-copias.sh"
