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

**Copia fuera del local (regla 3-2-1):** además, `restic copy` lleva las copias a un bucket de AWS S3. Ver el [apartado 4](#4-copia-remota-en-aws-s3).

## 3. Pruebas

| # | Prueba | Cómo | Resultado esperado | Evidencia |
| --- | --- | --- | --- | --- |
| 11 | RAID sano | `cat /proc/mdstat` | `[2/2] [UU]` | ✅ 26/10 · `sdb` y `sdc` *active sync*, estado *clean* · [captura](../erp/capturas/srv_11_raid_sano.png). Persistente: `ARRAY /dev/md0` en `mdadm.conf`, `/srv/datos` en `fstab` con `nofail`, y `postgres/` y `odoo/` dentro del RAID · [captura](../erp/capturas/srv_11b_raid_persistente.png) |
| 12 | **Fallo de un disco** | Comandos de abajo | `[_U]` y Odoo sigue funcionando. Al reponer el disco vuelve a `[UU]` | ✅ 26/10 · `sdb` marcado `(F)` y RAID en `[_U]` ([captura](../erp/capturas/srv_12a_raid_degradado.png)); repuesto y reconstruido a `[UU]` en menos de 2 min ([captura](../erp/capturas/srv_12b_raid_reconstruido.png)); Odoo siguió funcionando durante el fallo ([captura](../erp/capturas/srv_12c_odoo_con_raid_degradado.png)) |
| 13 | Copia automática | Al día siguiente: `sudo tail /var/log/almichain-copia.log` | «Copia terminada correctamente» a las 02:30 | 🟡 27/10 · `05-copias.sh` ejecutado ([incidencia 3](../erp/README.md#incidencias)): `sdd` montado en `/srv/copias` ([captura](../erp/capturas/srv_13a_disco_copias.png)), cron a las 02:30 como root ([captura](../erp/capturas/srv_13b_cron.png)) y primera copia `76f0e3dc` con `restic check` sin errores ([captura](../erp/capturas/srv_13d_primera_copia.png)). Falta ver en el registro la copia automática del 28/10 a las 02:30 |
| 14 | **Restauración** | Vende algo en el TPV, ejecuta `sudo almichain-copia` y luego `sudo almichain-restaurar-prueba` | `RESULTADO: RESTAURACIÓN CORRECTA` | ✅ 27/10 · Venta en el TPV y copia manual `1e6be61a`, con `restic check` sin errores ([captura](../erp/capturas/srv_14a_copia_manual.png)). Restaurada en la BD aparte `almichain_restaurada`: 16 pedidos del TPV, 10 contactos, 6 productos y 484 adjuntos, iguales que en producción. Facturas 0 en las dos, porque la factura automática aún no está hecha. La BD de prueba se borra al terminar ([captura](../erp/capturas/srv_14b_restauracion_correcta.png)) |

```bash
cat /proc/mdstat                           # antes: [UU]
sudo mdadm /dev/md0 --fail /dev/sdb        # simula que el disco A se rompe -> [_U]
#   (vender en el TPV: Odoo sigue funcionando)
sudo mdadm /dev/md0 --remove /dev/sdb
sudo mdadm /dev/md0 --add /dev/sdb         # disco "nuevo"
watch cat /proc/mdstat                     # hasta [UU]
```

## 4. Copia remota en AWS S3

Tercera copia, **fuera del local**: si el restaurante sufre un incendio o un robo, el RAID y el disco C se pierden a la vez, pero la copia de la nube no. Así se cumple la regla **3-2-1** (3 copias, en 2 soportes distintos y 1 fuera del local).

```
 RAID 1 (/srv/datos) ──restic, 02:30──► disco C (/srv/copias/restic) ──restic copy, 03:30──► AWS S3 (cifrado)
```

| Pregunta | Respuesta |
| --- | --- |
| Dónde | Bucket S3 privado creado con Terraform: [`infra/terraform-copias/`](../infra/terraform-copias) |
| Cómo | [`scripts/copia_remota.sh`](scripts/copia_remota.sh) (`/usr/local/sbin/almichain-copia-remota`): `restic copy` del repositorio local al de S3, con la misma retención y `restic check` |
| Cifrado | Doble: restic cifra con AES-256 antes de subir, con una **clave distinta** a la local, y S3 cifra en reposo. Solo por HTTPS |
| Cuándo | Cron a las 03:30, después de la copia local. Registro en `/var/log/almichain-copia-remota.log` |
| Secretos | `/root/secretos/aws-s3.env` (credenciales) y `/root/secretos/restic-remoto.txt` (clave), solo root. La clave, también en KeePassXC |
| Limitación del Learner Lab | Las credenciales caducan al cerrar la sesión: hay que renovarlas en `aws-s3.env` cada vez, y con el lab apagado la copia falla y lo deja en el registro. En una empresa se usaría un usuario IAM fijo con permiso solo sobre el bucket ([política](../infra/terraform-copias/README.md#limitación-de-aws-academy-y-cómo-sería-en-una-empresa)) |

### Instalación (una vez)

```bash
# En el servidor, como adminsrv, con el repo actualizado (git pull)
sudo install -m 750 backups/scripts/copia_remota.sh /usr/local/sbin/almichain-copia-remota
sudo install -m 600 /dev/null /root/secretos/aws-s3.env
sudo nano /root/secretos/aws-s3.env      # las 4 líneas de abajo
sudo almichain-copia-remota --iniciar    # crea el repositorio en S3 y su clave
echo '30 3 * * * root /usr/local/sbin/almichain-copia-remota >> /var/log/almichain-copia-remota.log 2>&1' | sudo tee /etc/cron.d/almichain-copia-remota
```

Contenido de `/root/secretos/aws-s3.env` (los valores salen del Learner Lab, *AWS Details → AWS CLI*, y de `terraform output`):

```
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_SESSION_TOKEN=...
RESTIC_REPOSITORY=s3:s3.us-east-1.amazonaws.com/almichain-copias-XXXX/restic
```

### Pruebas

| # | Prueba | Cómo | Resultado esperado | Evidencia |
| --- | --- | --- | --- | --- |
| 16 | Bucket creado con Terraform | `terraform apply` y consola de S3 | 7 recursos; bucket privado, cifrado y con versionado | ⏳ |
| 17 | **Copia remota** | `sudo almichain-copia-remota` | Instantáneas copiadas, `restic check` sin errores y «Copia remota terminada correctamente» | ⏳ |
| 18 | **Restauración desde S3** | `sudo almichain-copia-remota --restaurar` | `RESULTADO: RESTAURACIÓN CORRECTA` leyendo de la nube | ⏳ |
| 19 | Sin credenciales válidas | Con el lab apagado: `sudo almichain-copia-remota` | Falla con un mensaje claro y no toca la copia local | ⏳ |

## 5. Recuperación real (sustituye la BD de producción)

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
