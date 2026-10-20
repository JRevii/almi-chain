# Pruebas de rendimiento · Recreativa MAME

VM con 1 núcleo y 1 GB de RAM (965 MB útiles), sin swap. Medidas tomadas con `uptime`, `free -m`, `ps`, `df -h`, `sar` (paquete sysstat) y `mame -bench`, mediante [`../scripts/medir.sh`](../scripts/medir.sh).

## Antes y después

| Medida | Antes (sin optimizar) | Después (optimizada) |
| --- | --- | --- |
| Momento de la medida | Recién arrancada, sin X ni MAME | Recién arrancada, con el menú de MAME abierto |
| Tiempo hasta medir (`uptime`) | 52 s | 62 s (incluye abrir X y MAME solos) |
| RAM usada | 162 MB de 965 | 389 MB (320 de caché) |
| RAM disponible | 803 MB | 575 MB |
| Swap | 0 | 0 |
| Procesos | 85 | 92 (X + MAME, con 4 consolas menos) |
| Servicios activos | 5 (dbus, opensysusers, seatd, ssh, udev) | Los mismos 5 |
| Disco usado | 2,3 GB (25 %) | 3,0 GB (33 %, por MAME y su ROM) |
| `mame -bench` (velocidad emulada) | 1613 % | 1353 % (medido con otro MAME abierto) |

## Jugando a Gridlee (optimizada)

- **CPU media (`sar`): 20,3 %**: 14,75 % usuario y 5,42 % sistema, con un 79,7 % libre.
- **RAM de MAME (RSS): 364 MB.**
- Sin tirones ni cortes de sonido; queda margen de sobra de CPU y de RAM.

## Cómo interpretarlo (para la defensa)

- La columna «antes» se tomó sin MAME abierto, así que la RAM no es comparable 1 a 1. Lo que sube es MAME funcionando, no un empeoramiento.
- `mame -bench` no usa vídeo ni sonido, y el segundo valor se midió con otra instancia de MAME abierta, por eso baja. Los dos valores están muy por encima del 100 %, que es la velocidad real de la máquina original.
- La mejora está en el uso real: arranque directo al juego, menos consolas, sin pantallas de aviso y con vídeo y sonido ajustados a un solo núcleo, todo sin swap.

Los ficheros en bruto (`medidas-antes.txt`, `medidas-despues.txt`, `medidas-jugando.txt`) se añaden a esta carpeta al sacarlos de la VM.
