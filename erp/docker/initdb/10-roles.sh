#!/bin/bash
# Se ejecuta UNA vez, al crear la base de datos vacía (contenedor db).
# Crea los usuarios de PostgreSQL con mínimos privilegios:
#   odoo      -> puede crear su BD, no es superusuario
#   local_app -> dueño solo de la BD del local (almichain_local)
set -euo pipefail
ODOO_PW="$(cat /run/secrets/pg_odoo)"
LOCAL_PW="$(cat /run/secrets/pg_local)"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres \
     -v odoo_pw="$ODOO_PW" -v local_pw="$LOCAL_PW" <<'EOSQL'
CREATE ROLE odoo LOGIN CREATEDB NOSUPERUSER NOCREATEROLE PASSWORD :'odoo_pw';
CREATE ROLE local_app LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE PASSWORD :'local_pw';
CREATE DATABASE almichain_local OWNER local_app;
REVOKE ALL ON DATABASE almichain_local FROM PUBLIC;
EOSQL
