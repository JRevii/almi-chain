# Disco redundante y copias de seguridad

Las bases de datos del servidor (`almichain`, la de Odoo, y `almichain_local`, la del local) y los adjuntos de Odoo están en un **RAID 1**. Además, cron hace una **copia diaria cifrada** con restic en un disco aparte, que se comprueba con una **prueba de restauración**. La instalación está en [`../erp/`](../erp), con los scripts `02-raid.sh` y `05-copias.sh`.

| Archivo | Qué es |
| --- | --- |
| [`scripts/copia.sh`](scripts/copia.sh) | Copia diaria. Se instala como `/usr/local/sbin/almichain-copia` y la lanza `/etc/cron.d/almichain-copia` a las 02:30 |
| [`scripts/restaurar_prueba.sh`](scripts/restaurar_prueba.sh) | Prueba de restauración. Se instala como `/usr/local/sbin/almichain-restaurar-prueba` |

## 1. RAID 1

```
 disco A (sdb, 10 GB) ─┐
                       ├─ /dev/md0 (RAID 1, ext4) → /srv/datos ─┬─ postgres/ → contenedor db   (/var/lib/postgresql/data)
 disco B (sdc, 10 GB) ─┘                                         └─ odoo/     → contenedor odoo (/var/lib/odoo, adjuntos)
```

Si un disco falla, todo sigue funcionando con el otro. Docker no arranca si el RAID no está montado. Para ver el estado: `cat /proc/mdstat` o `sudo mdadm --detail /dev/md0`.

> **La copia de configuración del router no se sube a GitHub:** contiene la contraseña de administración y la clave del Wi-Fi. Se guarda en KeePassXC como adjunto.

> **Un RAID no es una copia.** Si alguien borra una factura, se borra en los dos discos a la vez. Para eso está el plan de copias.

## 2. Plan de copias

| Pregunta | Respuesta |
| --- | --- |
| Qué | `pg_dump` de las dos BD y los usuarios de PostgreSQL, adjuntos de Odoo, stack de Docker (`/opt/almichain`), certificados, CA, RAID, UFW y SSH |
| Cómo | restic: copia **cifrada** (AES-256), incremental y deduplicada |
| Dónde | Disco C (`sdd`) en `/srv/copias`, aparte del RAID y solo para root |
| Cuándo | Cron, todos los días a las 02:30. Registro en `/var/log/almichain-copia.log` |
| Retención | 7 diarias, 4 semanales y 6 mensuales |
| Comprobación | `restic check` en cada copia y una prueba de restauración completa al mes |
| Clave | `/root/secretos/restic.txt` y KeePassXC. **Sin ella, la copia no se puede recuperar** |

**Mejora para un restaurante real:** guardar además una copia fuera del local (regla 3-2-1). `restic copy` puede llevarla a un disco USB o a un bucket S3.

## 3. Pruebas

| # | Prueba | Cómo | Resultado esperado | Evidencia |
| --- | --- | --- | --- | --- |
| 11 | RAID sano | `cat /proc/mdstat` | `[2/2] [UU]` | ✅ 26/10 · `sdb` y `sdc` *active sync*, estado *clean* · [captura](../erp/capturas/srv_11_raid_sano.png) |
| 12 | **Fallo de un disco** | Comandos de abajo | `[_U]` y Odoo sigue funcionando. Al reponer el disco vuelve a `[UU]` | ✅ 26/10 · `sdb` marcado `(F)` y RAID en `[_U]` ([captura](../erp/capturas/srv_12a_raid_degradado.png)); repuesto y reconstruido a `[UU]` en menos de 2 min ([captura](../erp/capturas/srv_12b_raid_reconstruido.png)). Falta una captura de Odoo funcionando durante el fallo |
| 13 | Copia automática | Al día siguiente: `sudo tail /var/log/almichain-copia.log` | «Copia terminada correctamente» a las 02:30 | ⏳ |
| 14 | **Restauración** | Vende algo en el TPV, ejecuta `sudo almichain-copia` y luego `sudo almichain-restaurar-prueba` | `RESULTADO: RESTAURACIÓN CORRECTA` | ⏳ |

```bash
cat /proc/mdstat                           # antes: [UU]
sudo mdadm /dev/md0 --fail /dev/sdb        # simula que el disco A se rompe -> [_U]
#   (vender en el TPV: Odoo sigue funcionando)
sudo mdadm /dev/md0 --remove /dev/sdb
sudo mdadm /dev/md0 --add /dev/sdb         # disco "nuevo"
watch cat /proc/mdstat                     # hasta [UU]
```

## 4. Recuperación real (sustituye la BD de producción)

Antes, haz siempre la prueba de restauración.

```bash
cd /opt/almichain
export RESTIC_REPOSITORY=/srv/copias/restic RESTIC_PASSWORD_FILE=/root/secretos/restic.txt
sudo -E restic restore latest --host srv-odoo --target /var/tmp/recuperar
sudo docker compose stop odoo
sudo docker compose exec -u postgres db dropdb almichain
sudo docker compose exec -u postgres db createdb -O odoo almichain
sudo sh -c 'docker compose exec -T -u postgres db pg_restore --no-owner --role=odoo -d almichain < /var/tmp/recuperar/var/backups/almichain/almichain.dump'
sudo docker compose exec -u postgres db psql -c 'REVOKE CONNECT ON DATABASE almichain FROM PUBLIC'
sudo rsync -a --delete /var/tmp/recuperar/srv/datos/odoo/filestore/ /srv/datos/odoo/filestore/
sudo docker compose start odoo
sudo rm -rf /var/tmp/recuperar
```
