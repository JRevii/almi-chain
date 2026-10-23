#!/bin/sh
# Uso: sh medir.sh menu|jugando|bench 02|03
# Mismas condiciones en las dos instantáneas: unos 2 min tras arrancar,
# con el menú de MAME abierto en tty1 (en la 02 se abre a mano con startx).
# Deja el resultado en ~/medidas-<instantánea>-<fase>.txt
FASE="${1:-menu}"
SNAP="${2:-xx}"
OUT="$HOME/medidas-$SNAP-$FASE.txt"
{
  echo "== instantánea $SNAP · $FASE · $(date)"
  echo "-- uptime";                 uptime
  echo "-- RAM (MB)";               free -m
  echo "-- swap (vacío = sin swap)"; swapon --show
  echo "-- procesos";               ps -e --no-headers | wc -l
  echo "-- servicios";              ls /etc/rc2.d
  echo "-- disco";                  df -h /
  echo "-- RAM de MAME (RSS en KB)"; ps -o rss=,args= -C mame
  case "$FASE" in
    jugando)
      echo "-- CPU 60 s (vmstat cada 2 s; columnas us sy id)"
      vmstat 2 31 ;;
    bench)
      echo "-- mame -bench 60 gridlee (sin vídeo ni sonido)"
      /usr/games/mame -bench 60 gridlee ;;
  esac
} > "$OUT" 2>&1
echo "Guardado en $OUT"
