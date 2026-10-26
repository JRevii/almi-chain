#!/bin/sh
# Uso: sh medir.sh <fase>   (antes, despues, antes-jugando, despues-jugando)
# Las fases que contienen "jugando" se miden con Gridlee en marcha e incluyen sar.
# Deja el resultado en ~/medidas-<fase>.txt
FASE="${1:-despues}"
OUT="$HOME/medidas-$FASE.txt"
{
  echo "== $FASE · $(date)"
  echo "-- uptime";        uptime
  echo "-- RAM (MB)";      free -m
  echo "-- procesos";      ps -e --no-headers | wc -l
  echo "-- servicios";     ls /etc/rc2.d
  echo "-- disco";         df -h /
  case "$FASE" in *jugando*)
    echo "-- CPU 60 s (sar)"; sar -u 2 30
    echo "-- RAM de MAME";    ps -o rss,cmd -C mame
    ;;
  esac
} > "$OUT" 2>&1
echo "Guardado en $OUT"
# Benchmark (sin vídeo ni sonido): /usr/games/mame -bench 60 gridlee
