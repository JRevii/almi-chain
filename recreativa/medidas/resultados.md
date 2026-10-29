# Pruebas de rendimiento · Recreativa MAME

VM con 1 núcleo y 1 GB de RAM (965 MB útiles), sin swap. Medidas tomadas con `uptime`, `free -m`, `ps`, `df -h`, `sar` (paquete sysstat) y `mame -bench`, mediante [`../scripts/medir.sh`](../scripts/medir.sh).

## 1. Resultado: el juego va sobrado con 1 núcleo y 1 GB

Medido con la versión optimizada y **Gridlee en marcha**:

| Medida | Resultado | Qué significa |
| --- | --- | --- |
| CPU media (`sar`, 60 s) | **20,3 %** (14,75 % usuario y 5,42 % sistema) | Queda un 79,7 % de CPU libre |
| RAM de MAME (RSS) | **364 MB** | Cabe de sobra en 1 GB |
| RAM disponible | 575 MB | Sin necesidad de swap |
| Swap | 0 | Requisito del profesor: no se usa |
| `mame -bench 60 gridlee` | **1353–1613 %** | Emula entre 13 y 16 veces más rápido de lo necesario (100 % = velocidad de la máquina original) |
| Juego | Sin tirones ni cortes de sonido | Prueba de uso real |

## 2. Estado del sistema en cada fase

Estas dos columnas **no son una comparación directa**: se tomaron en momentos distintos (la primera sin MAME abierto y la segunda con el menú de MAME abierto). Sirven para ver cuánto ocupa cada parte.

| Medida | Sistema base, sin MAME abierto | Optimizada, con el menú de MAME abierto |
| --- | --- | --- |
| Tiempo desde el arranque (`uptime`) | 52 s | 62 s |
| RAM usada | 162 MB | 389 MB (320 de caché) |
| Procesos | 85 | 92 (X y MAME suman procesos; hay 4 consolas menos) |
| Servicios activos | 5 (dbus, opensysusers, seatd, ssh, udev) | Los mismos 5 |
| Disco usado | 2,3 GB (25 %) | 3,0 GB (33 %, por MAME y su ROM) |

La diferencia de RAM es MAME funcionando, no un empeoramiento. El sistema base ya era mínimo (antiX core con 5 servicios), así que la optimización no se centra en quitar servicios, sino en preparar la máquina para jugar.

## 3. Qué se ha optimizado

| Cambio | Efecto |
| --- | --- |
| Arranque directo a MAME (autologin, `startx` y `.xinitrc`) | Al encender, la máquina va sola al juego, sin escritorio ni usuario y contraseña |
| 4 consolas de texto desactivadas (tty3–tty6) | 4 procesos menos |
| `GRUB_TIMEOUT=1` | Arranque más rápido |
| `video soft` y `autoframeskip` | Vídeo estable sin aceleración 3D y sin ralentizaciones |
| `samplerate 22050` | Sonido más ligero para un solo núcleo |
| `skip_gameinfo` | Sin pantallas de aviso al cargar el juego |
| Sin swap | La RAM sobra, como muestra el apartado 1 |

## 4. Validación

✅ **Validado por el profesor el 29/10/2026:** las medidas de los apartados 1 y 2 son suficientes como constancia de las pruebas de rendimiento. No se repite la comparación con las instantáneas `02` y `03`.

Si se quisiera ampliar, se mediría lo mismo en las dos instantáneas: el tiempo desde encender hasta poder jugar, `sh medir.sh antes-jugando` / `despues-jugando` con Gridlee en marcha y `mame -bench 60 gridlee` sin otro MAME abierto.

## 5. Cómo interpretarlo (para la defensa)

- **El requisito se cumple:** con 1 núcleo y 1 GB, Gridlee usa el 20 % de la CPU y 364 MB, sin swap ni tirones.
- **`mame -bench`** mide la emulación sin vídeo ni sonido. Más del 100 % significa que va más rápido que la máquina original. El valor más bajo (1353 %) se tomó con otra instancia de MAME abierta, por eso no se usa para comparar.
- **La mejora principal es de uso:** la máquina arranca sola en el juego, con vídeo y sonido ajustados a un solo núcleo. Al encender, la máquina va sola al juego sin pasar por escritorio ni contraseña.

Los ficheros en bruto (`medidas-*.txt`) se añaden a esta carpeta al sacarlos de la VM.
