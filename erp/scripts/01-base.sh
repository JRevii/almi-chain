#!/bin/bash
# =====================================================================
# 01-base.sh · Puesta a punto y seguridad básica del servidor
# Ubuntu Server 24.04 LTS · VM Servidor-Odoo · IP en red.conf
# Uso (como el administrador creado al instalar):  sudo bash 01-base.sh
# =====================================================================
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Ejecuta con sudo: sudo bash $0"; exit 1; }

ADMIN="${SUDO_USER:-adminsrv}"   # usuario administrador (el del instalador)
# shellcheck source=red.conf
. "$(dirname "$0")/red.conf"     # IP_SERVIDOR, RED_LAN, PUERTA_ENLACE, DOMINIO
NOMBRE="srv-odoo"

echo "== 1. Comprobaciones"
ip -4 addr | grep -q "inet $IP_SERVIDOR/" || {
  echo "La IP no es $IP_SERVIDOR. Ponla fija en el instalador o en /etc/netplan (ver erp/README.md)."; exit 1; }
ping -c1 -W3 1.1.1.1 >/dev/null || { echo "Sin salida a internet: revisa el adaptador puente y la puerta de enlace."; exit 1; }

echo "== 2. Nombre, hora y resolución local"
hostnamectl set-hostname "$NOMBRE"
timedatectl set-timezone Europe/Madrid
grep -q "$DOMINIO" /etc/hosts || echo "$IP_SERVIDOR $NOMBRE $DOMINIO" >> /etc/hosts

echo "== 3. Actualizar y paquetes base"
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get -y full-upgrade
apt-get -y install ufw fail2ban unattended-upgrades curl gnupg git

echo "== 4. Actualizaciones de seguridad automáticas"
cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

echo "== 5. SSH: sin root, solo el administrador y, si ya hay clave, sin contraseña"
CLAVES="/home/$ADMIN/.ssh/authorized_keys"
if [ -s "$CLAVES" ]; then
  PASS="no"
else
  PASS="yes"
  echo "AVISO: $ADMIN no tiene clave SSH. Se deja la contraseña activada."
  echo "       Copia tu clave (ssh-copy-id) y vuelve a ejecutar este script."
fi
cat > /etc/ssh/sshd_config.d/10-almichain.conf <<EOF
# Almi-Chain: acceso SSH con mínimos privilegios
PermitRootLogin no
AllowUsers $ADMIN
PasswordAuthentication $PASS
KbdInteractiveAuthentication no
MaxAuthTries 3
X11Forwarding no
EOF
sshd -t
systemctl try-reload-or-restart ssh

echo "== 6. Cortafuegos: todo cerrado salvo SSH y web desde la LAN de empleados"
ufw --force reset >/dev/null
ufw default deny incoming
ufw default allow outgoing
ufw allow from "$RED_LAN" to any port 22  proto tcp comment 'SSH admin'
ufw allow from "$RED_LAN" to any port 80  proto tcp comment 'HTTP -> HTTPS'
ufw allow from "$RED_LAN" to any port 443 proto tcp comment 'Odoo HTTPS'
ufw --force enable

echo "== 7. fail2ban: bloquea IP tras 5 intentos fallidos de SSH"
cat > /etc/fail2ban/jail.d/almichain.local <<'EOF'
[sshd]
enabled  = true
backend  = systemd
maxretry = 5
findtime = 10m
bantime  = 1h
EOF
systemctl enable --now fail2ban
systemctl restart fail2ban

echo "== 8. Carpeta de secretos (solo root)"
install -d -m 700 /root/secretos

echo
echo "Listo. Comprobación rápida:"
ufw status verbose | head -12
sshd -T | grep -E '^(permitrootlogin|allowusers|passwordauthentication) '
fail2ban-client status sshd | head -3 || true
