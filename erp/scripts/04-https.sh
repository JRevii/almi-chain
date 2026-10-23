#!/bin/bash
# =====================================================================
# 04-https.sh · Nginx con HTTPS delante de Odoo
# El servidor es interno (no tiene dominio público), así que se crea una
# autoridad de certificación propia, "Almi-Chain CA", y con ella el
# certificado de odoo.almichain.lan. Los equipos de la LAN (TPV, gerente)
# instalan almichain-ca.crt como entidad de confianza y ven el candado.
# Uso:  sudo bash 04-https.sh
# =====================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo: sudo bash $0"; exit 1; }

DIR="$(cd "$(dirname "$0")" && pwd)"
ADMIN="${SUDO_USER:-adminsrv}"
DOMINIO="odoo.almichain.lan"
IP_SERVIDOR="10.13.10.10"
CA_DIR="/root/ca"                  # clave privada de la CA: solo root
SSL_DIR="/etc/ssl/almichain"

echo "== 1. Nginx"
DEBIAN_FRONTEND=noninteractive apt-get -y install nginx openssl

echo "== 2. Autoridad de certificación propia (10 años)"
install -d -m 700 "$CA_DIR"
install -d -m 755 "$SSL_DIR"
if [ ! -f "$CA_DIR/almichain-ca.key" ]; then
  openssl genrsa -out "$CA_DIR/almichain-ca.key" 4096
  chmod 600 "$CA_DIR/almichain-ca.key"
  openssl req -x509 -new -key "$CA_DIR/almichain-ca.key" -sha256 -days 3650 \
    -subj "/C=ES/O=Almi-Chain/CN=Almi-Chain CA" -out "$SSL_DIR/almichain-ca.crt"
fi

echo "== 3. Certificado del servidor (825 días, el máximo que aceptan los navegadores)"
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
# El propio servidor también confía en la CA (lo usa el script de facturas)
cp "$SSL_DIR/almichain-ca.crt" /usr/local/share/ca-certificates/almichain-ca.crt
update-ca-certificates >/dev/null
# Copia para llevarla a los equipos de la LAN
install -m 644 -o "$ADMIN" "$SSL_DIR/almichain-ca.crt" "/home/$ADMIN/almichain-ca.crt"

echo "== 4. Sitio de Nginx"
install -m 644 "$DIR/../config/nginx-odoo.conf" /etc/nginx/sites-available/odoo
ln -sf /etc/nginx/sites-available/odoo /etc/nginx/sites-enabled/odoo
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl enable nginx
systemctl reload nginx

echo
echo "Comprobación:"
curl -s -o /dev/null -w "HTTP  -> %{http_code} (tiene que ser 301)\n" "http://$DOMINIO/"
curl -s -o /dev/null -w "HTTPS -> %{http_code} (tiene que ser 200 o 303)\n" "https://$DOMINIO/web/login"
echo
echo "Listo. Copia el certificado de la CA a tu equipo:"
echo "  scp -P 2223 $ADMIN@127.0.0.1:almichain-ca.crt ."
echo "Siguiente paso: sudo bash 05-copias.sh"
