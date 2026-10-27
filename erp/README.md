# Servidor Odoo (ERP + TPV)

VM con **Ubuntu Server 24.04 LTS** que ejecuta con **Docker Compose** tres contenedores: **Odoo 19 Community**, **PostgreSQL 16** y **Nginx con HTTPS**. Los datos están en un **RAID 1** y hay **copias cifradas diarias** (restic + cron) en un tercer disco. Cada venta del TPV emite su factura sola.

La guía paso a paso, desde crear la VM hasta las pruebas, está en el documento «Guía · Servidor Odoo Almi-Chain». Este README es el resumen técnico.

```
 TPV / gerente (HTTPS 443)            Portátil del admin (SSH 22, solo con clave)
            │                                      │
┌───────────▼──────── srv-odoo · 192.168.1.50 ─────▼──────────────────────────┐
│ UFW: solo 22/80/443 desde 192.168.1.0/24 · fail2ban                          │
│ Docker Compose (red interna):  nginx ──► odoo:19.0 ──► postgres:16            │
│                                  (443)     (sin puertos)  (sin puertos)       │
│ sda 25 GB sistema · sdb+sdc RAID 1 → /srv/datos (postgres/ y odoo/)          │
│ sdd 20 GB → /srv/copias: restic cifrado, cron 02:30                          │
└──────────────────────────────────────────────────────────────────────────────┘
```

| Archivo | Qué es |
| --- | --- |
| [`scripts/red.conf`](scripts/red.conf) | **IP del servidor y red** (en el aula: `192.168.1.50`, `192.168.1.0/24`). Único sitio donde se cambia |
| [`scripts/01-base.sh`](scripts/01-base.sh) | Actualizaciones automáticas, SSH solo con clave, UFW y fail2ban |
| [`scripts/02-raid.sh`](scripts/02-raid.sh) | RAID 1 (discos A y B) en `/srv/datos` para los volúmenes |
| [`scripts/03-certificados.sh`](scripts/03-certificados.sh) | CA propia «Almi-Chain CA» y certificado de `odoo.almichain.lan` |
| [`scripts/04-odoo-docker.sh`](scripts/04-odoo-docker.sh) | Docker, secretos, `odoo.conf`, BD `almichain` con los módulos y arranque |
| [`scripts/05-copias.sh`](scripts/05-copias.sh) | Disco C, restic y copia diaria con cron |
| [`scripts/emitir_factura.py`](scripts/emitir_factura.py) | Extra: emitir facturas por la API JSON-2 de Odoo |
| [`docker/`](docker) | `docker-compose.yml`, Nginx, plantilla de `odoo.conf`, usuarios de PostgreSQL (`initdb/`) y configuración inicial |
| [`datos/`](datos) | CSV de ejemplo para importar: carta (`productos.csv`) y clientes (`clientes.csv`) |
| [`../backups/`](../backups) | Copia, prueba de restauración y recuperación |

## Instalación (resumen)

1. **VM:** 2 CPU, 4 GB, adaptador puente a la red de clase. Discos SATA: 25 GB (sistema), 10 + 10 GB (A y B, RAID), 20 GB (C, copias).
2. **Ubuntu Server 24.04:** IP fija `192.168.1.50/24`, puerta de enlace `192.168.1.1`, DNS `192.168.1.1,1.1.1.1`. LVM solo en el disco de 25 GB, ampliado al máximo. Usuario `adminsrv` y OpenSSH.
3. **Desde el portátil, ANTES de `01-base.sh`:** crea la clave (`ssh-keygen -t ed25519`, con frase de paso guardada en KeePassXC), cópiala con `ssh-copy-id adminsrv@192.168.1.50` y comprueba que entras sin contraseña con `ssh -o PasswordAuthentication=no adminsrv@192.168.1.50`. Si `01-base.sh` no encuentra la clave, deja la contraseña activada (ver [incidencia 1](#incidencias)).
4. **En el servidor:**

```bash
git clone https://github.com/JRevii/almi-chain.git && cd almi-chain/erp/scripts
sudo bash 01-base.sh
sudo bash 02-raid.sh           # pide SI (borra sdb y sdc)
sudo bash 03-certificados.sh
sudo bash 04-odoo-docker.sh    # 10-15 min
sudo bash 05-copias.sh         # pide SI (borra sdd)
```

5. **Odoo:**
   - Configura la empresa y el IVA del 10 % por defecto.
   - Crea los usuarios por rol (Gerente, Barra 1 y Barra 2, que solo pueden usar el TPV) y los dos puntos de venta.
   - Importa `datos/*.csv`.
   - Crea la regla de automatización *TPV: factura automática de cada venta* (modelo «Pedido del punto de venta», desencadenante «Al crear», acción «Ejecutar código»):

```python
cliente_contado = env['res.partner'].search([('name', '=', 'Cliente de contado')], limit=1)
for pedido in records:
    valores = {'to_invoice': True}
    if not pedido.partner_id:
        valores['partner_id'] = cliente_contado.id
    pedido.write(valores)
```

6. **En cada equipo cliente:**
   - Añade `192.168.1.50 odoo.almichain.lan` al fichero `hosts` (Windows: `C:\Windows\System32\drivers\etc\hosts` como administrador; Linux: `echo "192.168.1.50 odoo.almichain.lan" | sudo tee -a /etc/hosts`). Sin esto, el navegador da `DNS_PROBE_FINISHED_NXDOMAIN`.
   - Copia el certificado **público** de la CA (`scp adminsrv@192.168.1.50:almichain-ca.crt .`; nunca la `.key`) e instálalo como entidad raíz de confianza. Windows: doble clic → *Instalar certificado* → *Entidades de certificación raíz de confianza*. Chrome en Linux no usa el almacén del sistema: `chrome://certificate-manager` → *Local certificates* → *Installed by you* → *Trusted certificates* → *Import*. Sin esto sale `NET::ERR_CERT_AUTHORITY_INVALID`.
   - Abre `https://odoo.almichain.lan`.

7. **BD del local (`almichain_local`):** las tablas de Alejandro están en [`../bd/scripts/Scripts_postgre/02_tablas.sql`](../bd/scripts/Scripts_postgre/02_tablas.sql). En este servidor se cargan en `almichain_local` con su dueño `local_app`, **nunca** en `almichain`, que es la BD de Odoo:

```bash
sudo docker compose -f /opt/almichain/docker-compose.yml exec -T db \
  psql -v ON_ERROR_STOP=1 -U local_app -d almichain_local < ~/almi-chain/bd/scripts/Scripts_postgre/02_tablas.sql
sudo docker compose -f /opt/almichain/docker-compose.yml exec db psql -U local_app -d almichain_local -c '\dt'
```

   > Los comentarios de `02_tablas.sql` y `03_permisos.sql` usan la BD `almichain` y los roles `almichain_owner`/`almichain_app`. En este servidor esos nombres no aplican: `03_permisos.sql` **no se ejecuta** tal cual, porque daría acceso a la BD de Odoo. Pendiente de acordar con Alejandro.

## Configuración de Odoo (26/10/2026)

Configuración funcional hecha desde la interfaz web, con el usuario administrador.

| Paso | Qué se ha hecho | Estado | Evidencia |
| --- | --- | --- | --- |
| Impuestos | Activos solo los necesarios: **IVA 10% (Bienes) · Ventas** (hostelería), IVA 21% (Bienes) · Ventas (general) y 10% IVA (bienes corrientes) · Compras. Los demás impuestos del plan español quedan desactivados para que nadie elija uno equivocado | ✅ | [captura](capturas/odoo_01_impuestos_activos.png) |
| Productos de prueba | *Café* (1,60 €) y *Txangurro* (22,00 €), con IVA 10% (Bienes) y disponibles en el TPV. La carta completa se importa después desde [`datos/productos.csv`](datos/productos.csv) | ✅ | ⏳ captura de la lista |
| Punto de venta «Restaurante» | **Impresión automática del recibo** y **encabezado y pie personalizados** (`Almi-Chain · Cocina vasca de temporada · Bilbao` / `¡Gracias por su visita!`) | ✅ | ⏳ captura de los ajustes guardados |
| Autofacturación por QR | **Desactivada:** el QR enlaza al portal de Odoo, que solo es accesible dentro del local (`odoo.almichain.lan`), y la factura ya se crea sola con la regla automática | ✅ | ⏳ (misma captura) |
| Regla *TPV: factura automática de cada venta* | Ver el código en el apartado de instalación | ⏳ | — |
| Carta, clientes y usuarios por rol | Importar los CSV de `datos/` y crear Gerente y Barra (solo TPV) | ⏳ Alejandro | — |

> **Por qué IVA 10% (Bienes):** la localización española solo trae activo el 10 % de ventas como «Bienes». Servir comida es técnicamente una prestación de servicios, también al 10 %. El porcentaje y el cálculo son los correctos.

## Seguridad aplicada

| Capa | Medida |
| --- | --- |
| Sistema | Actualizaciones de seguridad automáticas. Administración con `adminsrv` y `sudo`. `adminsrv` no está en el grupo `docker`, que equivale a ser root |
| SSH | Solo con clave, sin root, solo `adminsrv` y 3 intentos. fail2ban banea 1 h |
| Cortafuegos | UFW: entrada cerrada salvo 22, 80 y 443 desde la red local. Docker se salta UFW, así que Nginx se publica **solo en la IP de la LAN**, y Odoo y PostgreSQL no se publican |
| HTTPS | TLS 1.2/1.3 con CA propia. HTTP → HTTPS, HSTS, cookie `secure` y `SameSite=Lax`, `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy`. Sin versión de Nginx |
| Odoo | Una sola BD (`dbfilter`), gestor de BD desactivado (`list_db = False`), contraseña maestra cifrada, `proxy_mode`. Usuarios por rol |
| PostgreSQL | Tres usuarios: `postgres` (superusuario, solo administración), `odoo` (crea su BD, no es superusuario) y `local_app` (solo `almichain_local`). `REVOKE CONNECT` en la BD de Odoo |
| Secretos | Generados al azar en `/root/secretos` (solo root) y en KeePassXC. Cada contenedor lee solo el suyo (Docker secrets). `odoo.conf` y `.env` reales fuera de Git |
| Datos | RAID 1. Docker no arranca si el RAID no está montado |
| Copias | restic cifrado (AES-256) en otro disco. Retención 7/4/6 y `restic check` diario |

## Pruebas

| # | Prueba | Resultado esperado | Evidencia |
| --- | --- | --- | --- |
| 1 | `sudo docker compose ps` (en `/opt/almichain`) | `db` healthy, `odoo` y `nginx` running | ✅ 26/10 · [captura](capturas/srv_01_docker_ps.png). Nginx publicado solo en `192.168.1.50`; Odoo y PostgreSQL sin publicar |
| 2 | `sudo ss -tlnp` | Solo 22, y 80/443 en `192.168.1.50`. Ni 5432 ni 8069 | ✅ 26/10 · [captura](capturas/srv_02_puertos.png) |
| 3 | `sudo ufw status verbose` | `deny (incoming)`. 22/80/443 solo desde `192.168.1.0/24` | ✅ 26/10 · [captura](capturas/srv_03_ufw.png) |
| 3b | Desde otro equipo de la LAN: `nmap -sV 192.168.1.50` | Solo 22 (OpenSSH), 80 (Nginx) y 443 abiertos; el resto filtrados | ✅ 26/10: 997 puertos filtrados. PostgreSQL (5432) y Odoo (8069) no aparecen · [captura](capturas/srv_03b_nmap.png) |
| 4 | Navegador → `https://odoo.almichain.lan` | Candado sin avisos | ✅ 26/10 · «La conexión es segura» · [captura](capturas/srv_04_candado.png) |
| 5 | `curl -I http://…` y `curl -I https://…/web/login` | `301`. Cabeceras de seguridad | ✅ 26/10 · HTTP → `301` a HTTPS y `Server: nginx` sin versión ([captura](capturas/srv_05a_http_301_sin_version.png)); HTTPS con HSTS, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy` y cookie `Secure; HttpOnly; SameSite=Lax` ([captura](capturas/srv_05b_https_cabeceras.png), cookie difuminada). Ver [incidencia 2](#incidencias) |
| 6 | `/web/database/manager` | «The database manager has been disabled» | ✅ 26/10 · desde un PC de la LAN, sin avisos de certificado · [captura](capturas/srv_06_gestor_bd_desactivado.png) |
| 7 | `ssh root@…` y `ssh -o PubkeyAuthentication=no adminsrv@…` | `Permission denied` | ✅ 26/10 (repetida tras corregir la [incidencia 1](#incidencias)) · login con clave y contraseña prohibida ([captura](capturas/srv_07d_login_con_clave.png)); `sshd -T`: `permitrootlogin no`, `passwordauthentication no`, `allowusers adminsrv` ([captura](capturas/srv_07b_sshd_config.png)); root y contraseña → `Permission denied (publickey)` sin pedir contraseña ([captura](capturas/srv_07c_ssh_rechazado.png)) |
| 8 | `psql -U postgres -c '\du'` y `psql -U local_app -d almichain` | `odoo` solo «Create DB». `local_app` sin acceso | ✅ 26/10 · `odoo` solo «Create DB», `local_app` sin atributos y `permission denied for database "almichain"` · [captura](capturas/srv_08_postgres_roles.png) |
| 9 | **Venta en TPV → factura** | Pedido facturado y factura publicada con número e IVA 10 % | ⏳ |
| 10 | Importar CSV y exportar a XLSX | Sin errores | ⏳ |
| 11-14 | RAID, fallo de un disco, copia y restauración | 11 y 12 ✅ 26/10 · 14 ✅ 27/10 · 13 🟡: copias instaladas el 27/10, falta comprobar la copia automática de las 02:30 · ver [`../backups/`](../backups#3-pruebas) |
| 15 | `sudo fail2ban-client status sshd` | Jaula activa | ✅ 26/10 · [captura](capturas/srv_15_fail2ban.png) |

Capturas en `erp/capturas/`.

## Incidencias

| # | Qué pasó | Causa | Solución |
| --- | --- | --- | --- |
| 1 | La prueba 7 fallaba: el servidor pedía contraseña por SSH | `01-base.sh` se ejecutó antes de copiar la clave de `adminsrv`, así que dejó `PasswordAuthentication yes`. Además, alguien había añadido a mano `AllowUsers root` en `/etc/ssh/sshd_config.d/10-almichain.conf` (no lo bloqueaba `PermitRootLogin no`, pero sobraba) | Copia de seguridad del fichero, clave ed25519 con `ssh-copy-id`, comprobación con `ssh -o PasswordAuthentication=no`, quitar `AllowUsers root`, `PasswordAuthentication no`, `sshd -t` y `systemctl reload ssh` sin cerrar la sesión abierta. Volver a lanzar `01-base.sh` hace lo mismo, y ahora el script avisa al final si la contraseña sigue activa. `50-cloud-init.conf` también dice `yes`, pero no manda: sshd se queda con el primer valor y `10-` se lee antes |
| 2 | `curl -I http://…` mostraba `Server: nginx/1.28.3` | `server_tokens off` solo estaba en el bloque del 443 | Añadido también al bloque del 80 en [`docker/nginx/odoo.conf`](docker/nginx/odoo.conf). En un servidor ya montado: editar `/opt/almichain/nginx/odoo.conf` y `docker compose restart nginx` (no basta `reload`: `sed -i` crea un fichero nuevo y el contenedor seguiría viendo el viejo) |
| 3 | No existía `/srv/copias` ni el cron de copias | `05-copias.sh` no se llegó a ejecutar: `sdd` (20 GB) estaba vacío y sin montar ([captura](capturas/srv_11c_discos_lsblk.png)) | ✅ 27/10 · `sudo bash 05-copias.sh` (pide escribir `SI` antes de formatear `sdd`). La clave de restic se guarda en KeePassXC. Después, pruebas 13 y 14 ([`../backups/`](../backups#3-pruebas)) |
| 4 | En el servidor, `git pull` daba `dubious ownership` y luego `divergent branches` | La copia del repo en `~/almi-chain` se había clonado como root, seguía en la rama antigua `feat/servidor-odoo` (de antes de reorganizar el historial) y tenía un cambio local sin subir en `03-certificados.sh`, ya obsoleto | `sudo chown -R adminsrv:adminsrv ~/almi-chain`, `git restore` del cambio, `git switch main`, `git reset --hard origin/main` y `git config pull.ff only`, para que un `pull` nunca vuelva a mezclar historiales ([captura](capturas/srv_16_repo_servidor_sincronizado.png)). Clonar el repo siempre como `adminsrv`, nunca con `sudo` |
