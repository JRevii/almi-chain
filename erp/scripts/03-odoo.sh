#!/bin/bash
# =====================================================================
# 03-odoo.sh · PostgreSQL + Odoo 19 Community (repositorio oficial)
# Crea la base de datos "almichain" con los módulos del reto:
# Facturación, Ventas, CRM, Empleados, Inventario, Marketing por email,
# TPV y la localización española (plan contable PYMEs, IVA).
# Uso:  sudo bash 03-odoo.sh      (después de 01-base.sh y 02-raid.sh)
# =====================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo: sudo bash $0"; exit 1; }

ODOO_VERSION="19.0"
BD="almichain"
DOMINIO="odoo.almichain.lan"
MODULOS="account,sale_management,crm,hr,stock,mass_mailing,point_of_sale,l10n_es"
CONF="/etc/odoo/odoo.conf"
SECRETOS="/root/secretos"

genera_clave() { openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | cut -c1-24; }

echo "== 1. Comprobaciones"
mountpoint -q /var/lib/postgresql && mountpoint -q /var/lib/odoo || {
  echo "Los datos no están en el RAID. Ejecuta antes 02-raid.sh."; exit 1; }
install -d -m 700 "$SECRETOS"
export DEBIAN_FRONTEND=noninteractive

echo "== 2. PostgreSQL (solo escucha en local)"
apt-get -y install postgresql
chown postgres:postgres /var/lib/postgresql
systemctl enable --now postgresql

echo "== 3. Repositorio oficial de Odoo $ODOO_VERSION e instalación"
curl -fsSL https://nightly.odoo.com/odoo.key | gpg --dearmor --yes -o /usr/share/keyrings/odoo-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/odoo-archive-keyring.gpg] https://nightly.odoo.com/$ODOO_VERSION/nightly/deb/ ./" \
  > /etc/apt/sources.list.d/odoo.list
apt-get update
apt-get -y install odoo
systemctl stop odoo
chown -R odoo:odoo /var/lib/odoo

echo "== 4. wkhtmltopdf 0.12.6.1 (versión que pide Odoo para los PDF de las facturas)"
curl -fsSL -o /tmp/wkhtmltox.deb \
  https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb
apt-get -y install /tmp/wkhtmltox.deb
rm -f /tmp/wkhtmltox.deb

echo "== 5. Usuario de PostgreSQL 'odoo' sin superusuario (mínimos privilegios)"
if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='odoo'" | grep -q 1; then
  sudo -u postgres createuser odoo
fi
sudo -u postgres psql -qc "ALTER ROLE odoo NOSUPERUSER NOCREATEROLE CREATEDB;"

echo "== 6. Configuración segura de Odoo ($CONF)"
[ -s "$SECRETOS/odoo-master.txt" ] || genera_clave > "$SECRETOS/odoo-master.txt"
[ -s "$SECRETOS/odoo-admin.txt" ]  || genera_clave > "$SECRETOS/odoo-admin.txt"
chmod 600 "$SECRETOS"/*.txt
# La contraseña maestra se guarda cifrada (pbkdf2), no en claro
MASTER_HASH=$(python3 -c "from passlib.context import CryptContext; import sys; print(CryptContext(['pbkdf2_sha512']).hash(sys.argv[1]))" "$(cat "$SECRETOS/odoo-master.txt")")
[ -f "$CONF.orig" ] || cp "$CONF" "$CONF.orig"
{
cat <<EOF
[options]
; --- Base de datos: PostgreSQL local, por socket, una sola BD ---
db_host = False
db_port = False
db_user = odoo
db_password = False
db_name = $BD
dbfilter = ^$BD\$
; Sin pantalla de gestión de bases de datos (no se pueden borrar ni copiar desde la web)
list_db = False
; --- Red: Odoo solo escucha en local; desde fuera se entra por Nginx con HTTPS ---
http_interface = 127.0.0.1
http_port = 8069
gevent_port = 8072
proxy_mode = True
; --- Rendimiento para una VM de 2 CPU y 4 GB ---
workers = 2
max_cron_threads = 1
limit_memory_soft = 1073741824
limit_memory_hard = 1610612736
limit_time_cpu = 600
limit_time_real = 1200
; --- Datos y registros ---
data_dir = /var/lib/odoo
logfile = /var/log/odoo/odoo-server.log
log_level = info
EOF
printf 'admin_passwd = %s\n' "$MASTER_HASH"
} > "$CONF"
chown root:odoo "$CONF"
chmod 640 "$CONF"

echo "== 7. Que PostgreSQL y Odoo no arranquen si el RAID no está montado"
mkdir -p /etc/systemd/system/postgresql@.service.d /etc/systemd/system/odoo.service.d
cat > /etc/systemd/system/postgresql@.service.d/raid.conf <<'EOF'
[Unit]
RequiresMountsFor=/var/lib/postgresql
EOF
cat > /etc/systemd/system/odoo.service.d/almichain.conf <<'EOF'
[Unit]
RequiresMountsFor=/var/lib/odoo
After=postgresql.service
Wants=postgresql.service
EOF
systemctl daemon-reload
cat > /etc/logrotate.d/odoo <<'EOF'
/var/log/odoo/*.log {
    weekly
    rotate 8
    compress
    missingok
    notifempty
    copytruncate
}
EOF

echo "== 8. Crear la base de datos '$BD' (tarda unos minutos)"
if sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='$BD'" | grep -q 1; then
  echo "La base de datos $BD ya existe: no se toca."
else
  sudo -u odoo odoo -c "$CONF" -d "$BD" -i base --load-language=es_ES --stop-after-init --no-http
  # Empresa en España (para que cargue el plan contable español), admin con clave segura
  sudo -u odoo odoo shell -c "$CONF" -d "$BD" --no-http <<EOF
admin = env.ref('base.user_admin')
admin.write({'password': '$(cat "$SECRETOS/odoo-admin.txt")', 'lang': 'es_ES', 'tz': 'Europe/Madrid'})
env.ref('base.EUR').active = True
env.company.write({'name': 'Almi-Chain', 'country_id': env.ref('base.es').id,
                   'currency_id': env.ref('base.EUR').id})
p = env['ir.config_parameter'].sudo()
p.set_param('web.base.url', 'https://$DOMINIO')
p.set_param('web.base.url.freeze', 'True')
p.set_param('report.url', 'http://127.0.0.1:8069')
env.cr.commit()
EOF
  sudo -u odoo odoo -c "$CONF" -d "$BD" -i "$MODULOS" --stop-after-init --no-http
fi

echo "== 9. Arrancar Odoo"
systemctl enable --now odoo
for _ in $(seq 1 30); do
  curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8069/web/login | grep -q 200 && break
  sleep 2
done
echo "Respuesta de Odoo en local: $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8069/web/login)  (tiene que ser 200)"
echo
echo "Listo. Usuario web: admin · contraseña en $SECRETOS/odoo-admin.txt"
echo "Contraseña maestra en $SECRETOS/odoo-master.txt. Guarda las dos en KeePassXC."
echo "Siguiente paso: sudo bash 04-https.sh"
