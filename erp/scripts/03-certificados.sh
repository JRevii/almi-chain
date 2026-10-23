#!/bin/bash
# =====================================================================
# 03-certificados.sh · CA propia y certificado HTTPS del servidor
# El servidor es interno (no tiene dominio público), así que se crea una
# autoridad de certificación, "Almi-Chain CA", y con ella el certificado
# de odoo.almichain.lan. Los equipos de la LAN (TPV, gerente) instalan
# almichain-ca.crt como entidad de confianza y ven el candado sin avisos.
# Uso:  sudo bash 03-certificados.sh
# =====================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo: sudo bash $0"; exit 1; }

ADMIN="${SUDO_USER:-adminsrv}"
DOMINIO="odoo.almichain.lan"
IP_SERVIDOR="10.13.10.10"
CA_DIR="/root/ca"                  # clave privada de la CA: solo root
SSL_DIR="/etc/ssl/almichain"       # lo monta el contenedor de Nginx (solo lectura)

install -d -m 700 "$CA_DIR"
install -d -m 755 "$SSL_DIR"

echo "== 1. Autoridad de certificación propia (10 años)"
if [ ! -f "$CA_DIR/almichain-ca.key" ]; then
  openssl genrsa -out "$CA_DIR/almichain-ca.key" 4096
  chmod 600 "$CA_DIR/almichain-ca.key"
  openssl req -x509 -new -key "$CA_DIR/almichain-ca.key" -sha256 -days 3650 \
    -subj "/C=ES/O=Almi-Chain/CN=Almi-Chain CA" -out "$SSL_DIR/almichain-ca.crt"
else
  echo "La CA ya existe: se reutiliza."
fi

echo "== 2. Certificado del servidor (825 días, el máximo que aceptan los navegadores)"
cat > "$CA_DIR/odoo.ext" <<EOF
basicConstraints = CA:FALSE
keyUsage = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = DNS:$DOMINIO, DNS:srv-odoo, DNS:localhost, IP:$IP_SERVIDOR, IP:127.0.0.1
EOF
openssl genrsa -out "$SSL_DIR/odoo.key" 2048
chmod 600 "$SSL_DIR/odoo.key"
openssl req -new -key "$SSL_DIR/odoo.key" -subj "/C=ES/O=Almi-Chain/CN=$DOMINIO" -out "$CA_DIR/odoo.csr"
openssl x509 -req -in "$CA_DIR/odoo.csr" -CA "$SSL_DIR/almichain-ca.crt" -CAkey "$CA_DIR/almichain-ca.key" \
  -CAcreateserial -days 825 -sha256 -extfile "$CA_DIR/odoo.ext" -out "$SSL_DIR/odoo.crt"
openssl verify -CAfile "$SSL_DIR/almichain-ca.crt" "$SSL_DIR/odoo.crt"

echo "== 3. Confianza en la CA"
# El propio servidor confía en la CA (curl de las pruebas y script de facturas)
cp "$SSL_DIR/almichain-ca.crt" /usr/local/share/ca-certificates/almichain-ca.crt
update-ca-certificates >/dev/null
# Copia para llevarla a los equipos de la LAN
install -m 644 -o "$ADMIN" "$SSL_DIR/almichain-ca.crt" "/home/$ADMIN/almichain-ca.crt"

echo
openssl x509 -in "$SSL_DIR/odoo.crt" -noout -subject -enddate -ext subjectAltName
echo
echo "Listo. Para los demás equipos, copia la CA desde tu portátil:"
echo "  scp -P 2223 $ADMIN@127.0.0.1:almichain-ca.crt ."
echo "Siguiente paso: sudo bash 04-odoo-docker.sh"
