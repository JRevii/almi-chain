# Máquina recreativa (MAME)

Máquina virtual de VirtualBox que imita el equipo de la recreativa: **1 núcleo y 1 GB de RAM, sin swap**. Funciona con **antiX 26.1 core** y **MAME 0.276**. Al encenderla entra sola y abre el menú de MAME, sin escritorio y sin pedir contraseña.

**Resultado:** jugando a Gridlee usa un **20,3 % de CPU** y MAME ocupa **364 MB de RAM**. Ver [`medidas/resultados.md`](medidas/resultados.md).

## Contenido de la carpeta

| Ruta | Qué es |
| --- | --- |
| `scripts/01-base.sh` | Puesta a punto tras instalar antiX: sudo, actualización y zona horaria |
| `scripts/02-ssh.sh` | Instalación de SSH, con el arreglo del grupo `_ssh` |
| `scripts/03-mame.sh` | Xorg mínimo + MAME + carpeta de ROMs |
| `scripts/04-optimizar.sh` | Optimización: `mame.ini`, autologin, arranque directo, GRUB y limpieza |
| `scripts/medir.sh` | Recoge las medidas de rendimiento en un `.txt` |
| `config/` | Ficheros de configuración que acaban en la VM |
| `medidas/` | Resultados de las pruebas de rendimiento |
| `capturas/` | Capturas del proceso |

> No se suben al repositorio contraseñas, ROMs ni el disco `.vdi`. La ROM de prueba (Gridlee) es legal y gratuita: se descarga de mamedev.org.

## 1. Máquina virtual

| Ajuste | Valor |
| --- | --- |
| Nombre | Recreativa-MAME |
| Tipo | Linux / Debian (64-bit) |
| CPU | 1 núcleo, límite de ejecución 100 % |
| RAM | 1024 MB |
| Disco | 10 GB VDI dinámico, una partición `sda1` ext4 con tabla MBR |
| Pantalla | VMSVGA, 16 MB, sin aceleración 3D |
| Red | NAT, reenvío **127.0.0.1:2222 → 22** para administrarla por SSH |
| USB | Controlador USB 1.1 (OHCI), para el arcade stick |
| Audio | ICH AC97 |

Instantáneas de VirtualBox, una por fase: `01 - antiX instalado y actualizado`, `02 - MAME sin optimizar` y `03 - optimizada`.

## 2. Instalación de antiX core

1. Arrancar la ISO de antiX 26.1 core y elegir **`antiX-26.1 x64-core (sysvinit)`**. El autoarranque se configura en `/etc/inittab`, que solo existe con sysvinit.
2. Entrar en el live como `root` y ejecutar `cli-installer`.
3. Responder así al instalador:
   - **Reparticionar:** sí. Aunque la pregunta sale en español, el instalador solo acepta `y`/`n` (con `s` dice «Inválido»).
   - **Tabla:** `dos` (MBR), porque la VM arranca en modo BIOS.
   - **Partición:** `sda1`, 10 GB, tipo Linux (83), marcada como arranque.
   - **Sistema de archivos:** ext4, sin `/home` aparte.
   - **GRUB:** en el **MBR** (opción 1). En la partición raíz, que es lo que viene por defecto, la VM no arranca.
   - **Idioma:** solo `es_ES.UTF-8`. **Teclado:** español.
   - **Equipo y usuario:** `recreativa`.
4. Al terminar, quitar la ISO (*Dispositivos → Unidades ópticas → Eliminar disco*) antes de reiniciar. Si no se quita, vuelve a arrancar el live.

## 3. Puesta a punto, SSH y MAME

Ejecutar los scripts por orden. El `01` va como root; el resto, como `recreativa`:

```bash
sh scripts/01-base.sh          # como root
sh scripts/02-ssh.sh
sh scripts/03-mame.sh
```

Para copiar la ROM desde el PC anfitrión:

```bash
scp -P 2222 gridlee.zip recreativa@127.0.0.1:~/mame/roms/
ssh -p 2222 recreativa@127.0.0.1
```

Para probar el juego: `startx /usr/games/mame gridlee`. Antes de optimizar, se toman las medidas «antes» con `sh scripts/medir.sh antes`.

## 4. Optimización

```bash
sh scripts/04-optimizar.sh
sudo reboot     # tiene que aparecer el menú de MAME directamente
```

| Cambio | Para qué |
| --- | --- |
| `video soft` | Dibujo por software: lo más estable sin aceleración 3D |
| `autoframeskip 1` | Si no llega a tiempo, salta fotogramas en vez de ir lento |
| `samplerate 22050` | Sonido más ligero para un solo núcleo |
| `skip_gameinfo 1` | Sin pantallas de aviso al cargar el juego |
| `window 0` | Pantalla completa |
| `joystick 1` | Mando activado, para el arcade stick |
| Autologin en tty1 (`/etc/inittab`) | Arranca sin pedir usuario ni contraseña |
| `.bash_profile` → `startx` → `.xinitrc` | Abre MAME directamente, sin escritorio |
| tty3 a tty6 desactivadas | 4 procesos menos; tty2 queda como consola de emergencia (`Ctrl+Alt+F2`) |
| `GRUB_TIMEOUT=1` | Arranque más rápido |
| Sin swap | Requisito del profesor; la RAM sobra (ver medidas) |

## 5. Incidencias resueltas

| Incidencia | Causa | Solución |
| --- | --- | --- |
| El instalador rechaza la respuesta `s` | Solo acepta respuestas en inglés | Responder `y` |
| Al reiniciar vuelve a salir el live | La ISO seguía montada | Quitarla en *Dispositivos → Unidades ópticas* |
| `openssh-server` no se instala (error de `dpkg`) | El script de `openssh-client` no consigue crear el grupo `_ssh` | `sudo groupadd -r _ssh && sudo dpkg --configure -a` |
| SSH: `Connection refused` | La regla de reenvío aún no estaba activa | Activarla en *Red → Avanzadas → Reenvío de puertos* |
| Aviso `XDG_RUNTIME_DIR` | Lanzar MAME por SSH | Es inofensivo |

## 6. Seguridad (mínimos privilegios)

- Se trabaja con el usuario `recreativa`, que solo usa `sudo` cuando hace falta.
- La parte gráfica se abre sin ser root (`xserver-xorg-legacy` + `config/Xwrapper.config`).
- SSH solo escucha en 127.0.0.1 del anfitrión, así que nadie de la red puede conectarse.
- **Pendiente:** poner a root una contraseña segura (`sudo passwd root`) y guardarla en KeePassXC; decidir si SSH se queda y, si se queda, desactivar el login de root.

## Pendiente

- [ ] Contraseña de root segura y decisión sobre SSH
- [ ] (Opcional) Medir «antes jugando» con la instantánea `02`
- [ ] Añadir los ficheros reales de la VM (ver abajo)
- [ ] Arcade stick con Arduino (tareas 44 y 45) → carpeta [`../arcade-stick/`](../arcade-stick/)

### Sacar los ficheros reales de la VM

Desde el portátil, en la raíz del repo y con la VM encendida:

```bash
scp -P 2222 recreativa@127.0.0.1:.mame/mame.ini recreativa/config/mame.ini
scp -P 2222 recreativa@127.0.0.1:/etc/inittab recreativa/config/inittab
scp -P 2222 'recreativa@127.0.0.1:medidas-*.txt' recreativa/medidas/
git add recreativa && git commit -m "feat(recreativa): ficheros reales de la VM" && git push
```
