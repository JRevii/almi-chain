#!/bin/sh
# Xorg mínimo (sin escritorio) + MAME. Ejecutar como recreativa.
set -e
sudo apt install -y --no-install-recommends \
  xserver-xorg-core xserver-xorg-legacy xserver-xorg-input-libinput \
  xserver-xorg-video-vmware xserver-xorg-video-fbdev \
  xinit x11-xserver-utils alsa-utils mame sysstat
# En el equipo real: cambiar xserver-xorg-video-vmware por el driver de su gráfica (o vesa)
sudo usermod -aG audio,video,input recreativa
# Permite abrir X sin ser root
sudo cp "$(dirname "$0")/../config/Xwrapper.config" /etc/X11/Xwrapper.config
mkdir -p ~/mame/roms ~/.mame
cd ~/.mame && /usr/games/mame -createconfig && cd ~
sed -i "s|^rompath .*|rompath  $HOME/mame/roms|" ~/.mame/mame.ini
echo "Copia las ROMs legales (.zip sin descomprimir) a ~/mame/roms"
