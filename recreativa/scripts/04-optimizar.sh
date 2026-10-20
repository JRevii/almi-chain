#!/bin/sh
# Optimización de la recreativa. Ejecutar como recreativa.
set -e
CONF="$(cd "$(dirname "$0")/../config" && pwd)"

# 1. MAME
sed -i -e 's|^video .*|video soft|' \
       -e 's|^window .*|window 0|' \
       -e 's|^autoframeskip .*|autoframeskip 1|' \
       -e 's|^skip_gameinfo .*|skip_gameinfo 1|' \
       -e 's|^samplerate .*|samplerate 22050|' \
       -e 's|^joystick .*|joystick 1|' ~/.mame/mame.ini

# 2. Autologin en tty1, tty2 de emergencia, tty3-6 fuera (con copia de seguridad)
sudo cp /etc/inittab /etc/inittab.bak
sudo sed -i \
  -e 's|^1:2345:respawn:/sbin/getty --noclear 38400 tty1|1:2345:respawn:/sbin/getty --noclear --autologin recreativa 38400 tty1|' \
  -e 's|^2:23:respawn:|2:2345:respawn:|' \
  -e 's|^\([3-6]:23:respawn:\)|#\1|' /etc/inittab

# 3. Arrancar MAME al entrar en tty1
cp "$CONF/bash_profile" ~/.bash_profile
cp "$CONF/xinitrc" ~/.xinitrc

# 4. Arranque más rápido y limpieza
sudo sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub && sudo update-grub
sudo apt autoremove --purge -y && sudo apt clean

# 5. Comprobar que no hay swap (requisito)
[ -z "$(swapon --show)" ] && echo "OK: sin swap" || echo "AVISO: hay swap activa"
echo "Reinicia con: sudo reboot"
