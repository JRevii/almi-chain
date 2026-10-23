# Disco redundante y copias de seguridad

La base de datos del servidor Odoo (`srv-odoo`, 10.13.10.10) está en un **RAID 1**. Además se hace una **copia diaria cifrada** en otro disco y se comprueba con una **prueba de restauración**. La instalación está en [`../erp/`](../erp) (scripts `02-raid.sh` y `05-copias.sh`).

| Archivo | Qué es |
| --- | --- |
| [`scripts/copia.sh`](scripts/copia.sh) | La copia diaria. Se instala como `/usr/local/sbin/almichain-copia` |
| [`scripts/restaurar_prueba.sh`](scripts/restaurar_prueba.sh) | La prueba de restauración. Se instala como `/usr/local/sbin/almichain-restaurar-prueba` |
| [`scripts/almichain-copia.service`](scripts/almichain-copia.service) y [`.timer`](scripts/almichain-copia.timer) | Lanzan la copia todos los días a las 02:30 |
| `conf.bin` | Copia de la configuración del router del aula |

## 1. Disco redundante: RAID 1

```
 sdb (10 GB) ─┐
              ├─ /dev/md0 (RAID 1, ext4) → /srv/datos ─┬─ postgresql → /var/lib/postgresql
 sdc (10 GB) ─┘                                         └─ odoo       → /var/lib/odoo (adjuntos)
```

- Los dos discos guardan lo mismo. Si uno falla, el servidor sigue funcionando con el otro y no se pierde nada.
- PostgreSQL y Odoo **no arrancan si el RAID no está montado**, para que nunca escriban en el disco del sistema por error.
- Estado: `cat /proc/mdstat` o `sudo mdadm --detail /dev/md0`.

> **Un RAID no es una copia de seguridad.** Si alguien borra una factura o un virus cifra los datos, el cambio se copia al instante en los dos discos. Por eso existe también el plan de copias.

## 2. Plan de copias

| Pregunta | Respuesta |
| --- | --- |
| **Qué** | Volcado de todas las bases de datos (`pg_dump`) y de los roles. Adjuntos de Odoo. Configuración de Odoo, Nginx, certificados, CA, RAID, cortafuegos y SSH |
| **Cómo** | [restic](https://restic.net): copias **cifradas** (AES-256), **incrementales** y deduplicadas |
| **Dónde** | Disco `sdd`, montado en `/srv/copias`. Es un disco **aparte del RAID**, solo accesible por root |
| **Cuándo** | Todos los días a las 02:30, con el temporizador de systemd `almichain-copia.timer`. Si el servidor estaba apagado a esa hora, la copia se hace al encender |
| **Cuánto se guarda** | 7 copias diarias, 4 semanales y 6 mensuales: medio año de historial |
| **Comprobación** | Cada copia termina con `restic check`, que lee un 5 % de los datos para detectar corrupción. Cada mes, prueba de restauración completa |
| **Clave** | `/root/secretos/restic.txt` y KeePassXC. **Sin ella, las copias no se pueden recuperar** |

**Mejora para un restaurante real:** la regla 3-2-1 pide además una copia **fuera del local**, porque un incendio o un robo se llevan el servidor y el disco de copias a la vez. restic puede enviar la misma copia a un bucket S3 o a un disco USB que se lleve el gerente (`restic copy`).

### Comandos útiles

```bash
sudo systemctl start almichain-copia                 # hacer una copia ahora
sudo journalctl -u almichain-copia -n 30             # ver cómo fue la última
systemctl list-timers almichain-copia.timer          # cuándo es la próxima
sudo RESTIC_REPOSITORY=/srv/copias/restic RESTIC_PASSWORD_FILE=/root/secretos/restic.txt restic snapshots
```

## 3. Recuperación ante un desastre (restaurar sobre producción)

Solo si se han perdido los datos de verdad. Antes, **haz la prueba de restauración** (sección 4) para comprobar que la copia está bien.

```bash
export RESTIC_REPOSITORY=/srv/copias/restic RESTIC_PASSWORD_FILE=/root/secretos/restic.txt
sudo -E restic restore latest --host srv-odoo --target /var/tmp/recuperar
sudo systemctl stop odoo
sudo -u postgres dropdb almichain
sudo -u postgres createdb -O odoo almichain
sudo sh -c 'sudo -u postgres pg_restore --no-owner --role=odoo -d almichain < /var/tmp/recuperar/var/backups/almichain/almichain.dump'
sudo rsync -a --delete /var/tmp/recuperar/var/lib/odoo/filestore/ /var/lib/odoo/filestore/
sudo chown -R odoo:odoo /var/lib/odoo
sudo systemctl start odoo
sudo rm -rf /var/tmp/recuperar
```

## 4. Pruebas

| # | Prueba | Cómo | Resultado esperado | Evidencia |
| --- | --- | --- | --- | --- |
| 1 | RAID sano | `cat /proc/mdstat` | `md0 : active raid1 sdc[1] sdb[0]` … `[2/2] [UU]` | ⏳ |
| 2 | **Fallo de un disco (failover)** | Ver abajo | Con un disco fuera, `[_U]` y **Odoo sigue funcionando**. Al reponerlo, se resincroniza y vuelve a `[UU]` | ⏳ |
| 3 | Copia | `sudo systemctl start almichain-copia` y después `journalctl` | `Copia terminada correctamente` y una nueva instantánea en `restic snapshots` | ⏳ |
| 4 | **Restauración** | Emite una factura, haz una copia y ejecuta `sudo almichain-restaurar-prueba` | Las mismas facturas, importe, contactos y productos → `RESULTADO: RESTAURACIÓN CORRECTA` | ⏳ |
| 5 | Copia automática | Al día siguiente: `restic snapshots` | Aparece la copia de las 02:30 | ⏳ |

### Prueba 2 paso a paso: fallo de un disco del RAID

```bash
cat /proc/mdstat                                   # 1. Antes: [UU]
sudo mdadm /dev/md0 --fail /dev/sdb                # 2. Simular que sdb se estropea
cat /proc/mdstat                                   #    Ahora: [_U] (sdb marcado como (F))
#    3. Abrir Odoo en el navegador y emitir una factura: todo funciona
sudo mdadm /dev/md0 --remove /dev/sdb              # 4. «Sacar» el disco roto
sudo mdadm /dev/md0 --add /dev/sdb                 # 5. Poner el disco «nuevo»
watch cat /proc/mdstat                             # 6. Ver la resincronización hasta [UU] (Ctrl+C para salir)
```

Prueba más realista con VirtualBox: apaga la VM y, en *Configuración → Almacenamiento*, quita el disco 2 del RAID. Arranca: el servidor funciona con `[_U]`. Después añade un disco nuevo de 10 GB en ese hueco y ejecuta `sudo mdadm /dev/md0 --add /dev/sdX` con el nombre que te muestre `lsblk`.

Guarda las capturas en `backups/capturas/` y cambia ⏳ por ✅ y la fecha.
