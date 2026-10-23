# Servidor Odoo (ERP + TPV)

Servidor de la cadena: **Odoo 19 Community** sobre **Ubuntu Server 24.04 LTS**, con la base de datos en un **RAID 1**, acceso solo por **HTTPS**, **copias cifradas diarias** y la **emisión de facturas automatizada**. Todo se instala con cinco scripts, en orden.

```
 TPV 1 / TPV 2 / Gerente (navegador)          Portátil del administrador
              │ HTTPS 443                             │ SSH 22 (solo con clave)
              ▼                                       ▼
┌──────────────────────── srv-odoo · 10.13.10.10 · Ubuntu 24.04 ────────────────────────┐
│  UFW: solo 22/80/443 desde 10.13.10.0/24 · fail2ban                                   │
│  Nginx (HTTPS, CA Almi-Chain) ──► Odoo 19 (127.0.0.1:8069/8072) ──► PostgreSQL 16 (local) │
│                                                                                       │
│  sda  25 GB  Sistema (LVM)                                                            │
│  sdb + sdc   RAID 1 (/dev/md0) → /srv/datos → /var/lib/postgresql + /var/lib/odoo      │
│  sdd  20 GB  Copias restic cifradas → /srv/copias  (todos los días a las 02:30)       │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

| Archivo | Qué hace |
| --- | --- |
| [`scripts/01-base.sh`](scripts/01-base.sh) | Actualiza, actualizaciones automáticas, SSH seguro, cortafuegos y fail2ban |
| [`scripts/02-raid.sh`](scripts/02-raid.sh) | RAID 1 con dos discos. Ahí van la base de datos y los adjuntos |
| [`scripts/03-odoo.sh`](scripts/03-odoo.sh) | PostgreSQL y Odoo 19 del repositorio oficial. Crea la BD `almichain` con los módulos |
| [`scripts/04-https.sh`](scripts/04-https.sh) | CA propia, certificado y Nginx con HTTPS delante de Odoo |
| [`scripts/05-copias.sh`](scripts/05-copias.sh) | Disco de copias, restic y copia diaria automática |
| [`scripts/emitir_factura.py`](scripts/emitir_factura.py) | **Caso de uso automatizado:** emite una factura por la API de Odoo |
| [`config/nginx-odoo.conf`](config/nginx-odoo.conf) | Sitio de Nginx |
| [`../backups/`](../backups) | RAID, plan de copias, scripts de copia y prueba de restauración |

## 1. Qué pide el reto y cómo se cumple

| Requisito | Cómo |
| --- | --- |
| ERP para facturas, clientes, personal, marketing e inventario | Odoo con Facturación, Ventas, CRM, Empleados, Marketing por email e Inventario |
| ERP + TPV | Módulo Punto de venta. Los TPV de barra entran por el navegador |
| Automatizar un caso de uso real de extremo a extremo | `emitir_factura.py`: cliente → líneas → factura validada con número |
| La BD en un dispositivo redundante | PostgreSQL y adjuntos sobre RAID 1 (`mdadm`) |
| Plan de copias y prueba de restauración | restic diario, cifrado, en otro disco, y un script que restaura y compara |
| Mínimos privilegios | Usuarios de Odoo por rol, usuario de PostgreSQL sin superusuario, clave API solo de facturación, SSH sin root |
| Gestión de secretos | Contraseñas generadas al azar en `/root/secretos` (solo root) y en KeePassXC. Nada en Git |
| Comunicaciones cifradas | HTTPS con TLS 1.2/1.3, HSTS, y SSH con clave |
| Documentación reproducible y pruebas | Esta guía y la sección de pruebas (11) |

## 2. Decisiones

| Decisión | Motivo |
| --- | --- |
| **Odoo 19 Community** | Gratuito y de código abierto. Odoo 20 acaba de salir (septiembre de 2026), pero la 19 lleva un año de correcciones y su paquete oficial está probado en Ubuntu 24.04 |
| **Ubuntu Server 24.04 LTS** | Es la versión que soporta el paquete oficial de Odoo 19. Soporte hasta 2029 |
| **Paquete oficial (apt), no Docker** | Odoo queda como servicio normal del sistema, se actualiza con `apt` y es más fácil de explicar y de administrar |
| **RAID 1 por software (mdadm)** | Dos discos en espejo: si uno falla, el servidor sigue funcionando sin perder datos |
| **restic en un disco aparte** | El RAID no es una copia: si se borra algo, se borra en los dos discos. restic guarda versiones cifradas y deduplicadas |
| **CA propia en vez de Let's Encrypt** | El servidor es interno y no tiene dominio público. Con una CA propia, los equipos de la LAN ven el candado sin avisos |
| **Red NAT de VirtualBox `10.13.10.0/24`** | Las VM (servidor, TPV, gerente) tienen las IP del plan de direccionamiento y se ven entre ellas, también en el aula |

## 3. Máquina virtual

**Red** (una vez, para todas las VM del reto): en VirtualBox, *Archivo → Herramientas → Gestor de red → Redes NAT → Crear*.

| Ajuste | Valor |
| --- | --- |
| Nombre | `AlmiChain-LAN` |
| Prefijo IPv4 | `10.13.10.0/24` (la puerta de enlace es `10.13.10.1`) |
| DHCP | **Desactivado** (todas las IP son fijas) |
| Reenvío de puertos | `SSH-odoo`: TCP, IP anfitrión `127.0.0.1`, puerto `2223` → `10.13.10.10:22`<br>`HTTPS-odoo`: TCP, IP anfitrión `127.0.0.1`, puerto `8443` → `10.13.10.10:443` |

**VM `Servidor-Odoo`:** Linux / Ubuntu (64-bit).

| Ajuste | Valor |
| --- | --- |
| CPU / RAM | 2 núcleos / 4096 MB |
| Disco 1 (SATA 0) | 25 GB, VDI dinámico: sistema |
| Disco 2 y 3 (SATA 1 y 2) | 10 GB cada uno: RAID 1 de datos |
| Disco 4 (SATA 3) | 20 GB: copias de seguridad |
| Red | Adaptador 1: **Red NAT** → `AlmiChain-LAN` |

## 4. Instalar Ubuntu Server 24.04 LTS

ISO de [ubuntu.com/download/server](https://ubuntu.com/download/server). En el instalador:

1. **Idioma** español y **teclado** español.
2. **Red:** en la tarjeta de red, *Editar IPv4 → Manual*:
   - Subred `10.13.10.0/24`, dirección `10.13.10.10`, puerta de enlace `10.13.10.1`.
   - Servidores de nombres `1.1.1.1,9.9.9.9`.
3. **Almacenamiento:** *Usar un disco entero*, elige el de **25 GB** y deja marcado LVM. **No toques los otros tres discos.**
4. **Perfil:** nombre del servidor `srv-odoo` y usuario `adminsrv`, con una contraseña larga que guardas en KeePassXC.
5. Marca **Instalar servidor OpenSSH**. No instales ningún snap.
6. Al terminar, quita la ISO y reinicia.

## 5. Primer acceso por SSH (desde el portátil)

```bash
ssh-keygen -t ed25519                         # si aún no tienes clave
ssh-copy-id -p 2223 adminsrv@127.0.0.1        # pide la contraseña de adminsrv (última vez)
ssh -p 2223 adminsrv@127.0.0.1
```

## 6. Instalación (en el servidor)

```bash
git clone https://github.com/JRevii/almi-chain.git
cd almi-chain/erp/scripts
sudo bash 01-base.sh      # deja SSH solo con clave: comprueba en otra terminal que sigues entrando
sudo bash 02-raid.sh      # pide escribir SI (borra sdb y sdc)
sudo bash 03-odoo.sh      # tarda 5-10 min
sudo bash 04-https.sh
sudo bash 05-copias.sh    # pide escribir SI (borra sdd)
```

Antes de `02-raid.sh` y `05-copias.sh`, comprueba con `lsblk` que los discos se llaman `sdb`, `sdc` y `sdd`. Si se llaman de otra forma: `sudo bash 02-raid.sh sdX sdY`.

Al terminar, en `/root/secretos/` (solo root) están:
- `odoo-admin.txt`: la contraseña del usuario `admin` de Odoo.
- `odoo-master.txt`: la contraseña maestra.
- `restic.txt`: la contraseña de las copias.

**Pásalas a KeePassXC.** Se ven con `sudo cat /root/secretos/odoo-admin.txt`.

## 7. Configurar Odoo (primera vez)

En el portátil, añade al fichero `hosts` la línea `127.0.0.1 odoo.almichain.lan` y abre **https://odoo.almichain.lan:8443**. Entra con `admin`.

1. **Empresa** (*Ajustes → Empresas*): pon el nombre, la dirección y un CIF ficticio. El país es España, porque lo pone el script. Así se carga el plan contable español con el IVA.
2. **Carta** (*Facturación → Clientes → Productos*): crea los productos con su precio y el impuesto **IVA 10 %**, el de la hostelería. Por ejemplo «Menú del día», «Txakoli (botella)» o «Kokotxas».
3. **Usuarios con mínimos privilegios** (*Ajustes → Usuarios*). El usuario `admin` se usa solo para configurar.

   | Usuario | Permisos | Para qué |
   | --- | --- | --- |
   | Gerente | Administrador en Facturación, Ventas, CRM, Empleados, Inventario y TPV. Sin acceso a Ajustes | Gestión diaria |
   | Barra 1 / Barra 2 | **Solo** Punto de venta: Usuario | Cobrar en los TPV |
   | Automatización facturas | **Solo** Facturación: Facturación, y creación de contactos | Clave API de `emitir_factura.py` |

4. **TPV** (*Punto de venta → Configuración*): crea «Barra 1» y «Barra 2», cada una con su usuario. La impresora de tickets y los equipos van en [`../sistemas/tpv-barra/`](../sistemas/tpv-barra).
5. **Clave API:** entra como «Automatización facturas» y ve a *Mi perfil → Seguridad de la cuenta → Nueva clave API*, con una duración de un año. Cópiala al servidor:

   ```bash
   install -d -m 700 ~/.config/almichain
   nano ~/.config/almichain/odoo-apikey     # pega la clave y guarda
   chmod 600 ~/.config/almichain/odoo-apikey
   ```

## 8. Caso de uso automatizado: emisión de una factura

```bash
python3 ~/almi-chain/erp/scripts/emitir_factura.py --cliente "Ane Etxeberria" \
    --email ane@example.com --linea "Menú del día:2" --linea "Txakoli (botella):1"
```

El script comprueba que los productos existen. Después busca al cliente o lo crea, crea la factura y la valida, y Odoo le pone número. Al final muestra la base, el IVA y el total. La factura aparece en *Facturación → Clientes → Facturas* y se puede imprimir en PDF.

- Se conecta por **HTTPS** verificando el certificado de la CA.
- Usa la **clave API de un usuario que solo puede facturar**. Si alguien la roba, no puede tocar empleados ni ajustes.
- Si el fichero de la clave no tiene permisos `600`, el script se niega a usarla.

Se apoya en la API **JSON-2** de Odoo 19 (`/json/2/<modelo>/<método>`), la que recomienda Odoo. XML-RPC está marcado como obsoleto.

## 9. Acceso desde los demás equipos (TPV y gerente)

Los TPV y el PC del gerente están en la misma Red NAT. En cada uno:

1. **Añadir al fichero hosts** la línea `10.13.10.10 odoo.almichain.lan`. En Windows es `C:\Windows\System32\drivers\etc\hosts` y hay que abrir el Bloc de notas como administrador.
2. **Instalar la CA:**
   - Trae el certificado desde el portátil con `scp -P 2223 adminsrv@127.0.0.1:almichain-ca.crt .`.
   - En Windows, doble clic → *Instalar certificado → Equipo local → Entidades de certificación raíz de confianza*.
   - En Firefox: *Ajustes → Certificados → Importar*.
3. Abrir **https://odoo.almichain.lan**: tiene que salir el candado, sin avisos.

## 10. Seguridad aplicada

| Capa | Medida |
| --- | --- |
| Sistema | Actualizaciones de seguridad automáticas. Administración con `adminsrv` y `sudo`, nunca como root |
| SSH | Solo con clave, sin login de root y solo el usuario `adminsrv`. fail2ban banea una IP 1 h tras 5 intentos |
| Cortafuegos (UFW) | Entrada cerrada. Solo 22, 80 y 443, y solo desde `10.13.10.0/24` |
| Odoo | Escucha solo en `127.0.0.1`, así que no se puede saltar Nginx. Una sola BD (`dbfilter`). Gestor de bases de datos desactivado (`list_db = False`). Contraseña maestra guardada cifrada (pbkdf2) |
| PostgreSQL | Solo local. El usuario `odoo` no es superusuario: solo puede crear BD |
| HTTPS | TLS 1.2/1.3, HTTP redirige a HTTPS, HSTS, cookie de sesión `secure` y `SameSite=Lax`. Cabeceras `X-Content-Type-Options`, `X-Frame-Options` y `Referrer-Policy`. Sin versión de Nginx |
| Usuarios de Odoo | Un usuario por rol con los permisos justos (sección 7). La clave API es solo de facturación |
| Secretos | Generados al azar, en `/root/secretos` con permisos `700` y en KeePassXC. La clave de la CA, en `/root/ca`. **Nada de esto se sube a Git** |
| Disponibilidad | RAID 1. Odoo y PostgreSQL no arrancan si el RAID no está montado, para no escribir en el disco del sistema |
| Copias | Cifradas (AES-256) en otro disco, con retención y comprobación diaria del repositorio. Detalles en [`../backups/`](../backups) |

## 11. Pruebas

| # | Prueba | Cómo | Resultado esperado | Evidencia |
| --- | --- | --- | --- | --- |
| 1 | Servicios activos | `systemctl is-active postgresql odoo nginx almichain-copia.timer` | 4 × `active` | ⏳ |
| 2 | Odoo no está expuesto | `sudo ss -tlnp` | 8069, 8072 y 5432 solo en `127.0.0.1`. 80, 443 y 22 abiertos | ⏳ |
| 3 | Cortafuegos | `sudo ufw status verbose` | `deny (incoming)`. 22, 80 y 443 solo desde `10.13.10.0/24` | ⏳ |
| 4 | HTTPS con candado | Navegador del TPV o del portátil | Pantalla de inicio de sesión de Odoo, conexión segura | ⏳ |
| 5 | HTTP redirige | `curl -I http://odoo.almichain.lan` (en el servidor) | `301` a `https://` | ⏳ |
| 6 | Cabeceras de seguridad | `curl -I https://odoo.almichain.lan/web/login` | `Strict-Transport-Security`, `X-Frame-Options`… | ⏳ |
| 7 | Gestor de BD bloqueado | `https://odoo.almichain.lan:8443/web/database/manager` | «The database manager has been disabled» | ⏳ |
| 8 | SSH seguro | `ssh -p 2223 root@127.0.0.1` y `ssh -p 2223 -o PubkeyAuthentication=no adminsrv@127.0.0.1` | Los dos: `Permission denied` | ⏳ |
| 9 | PostgreSQL con mínimos privilegios | `sudo -u postgres psql -c '\du'` | `odoo`: solo «Create DB» | ⏳ |
| 10 | **Factura automática** | `emitir_factura.py` (sección 8) | `FAC/2026/00001 · estado: posted`. Aparece en Odoo y se imprime en PDF | ⏳ |
| 11 | La clave API no sirve para más | `curl -s https://odoo.almichain.lan/json/2/hr.employee/search -H "Authorization: bearer $(cat ~/.config/almichain/odoo-apikey)" -H 'Content-Type: application/json' -d '{"domain":[]}'` | Error de acceso (`AccessError`) | ⏳ |
| 12 | RAID 1 sano y fallo de un disco | [`../backups/`](../backups), pruebas 1 y 2 | `[UU]`. Con un disco fallado, Odoo sigue funcionando | ⏳ |
| 13 | Copia y restauración | [`../backups/`](../backups), pruebas 3 y 4 | `RESULTADO: RESTAURACIÓN CORRECTA` | ⏳ |
| 14 | fail2ban | `sudo fail2ban-client status sshd` | Jaula activa | ⏳ |

Guarda las capturas en `erp/capturas/` con nombres como `srv_10_factura_automatica.png` y cambia ⏳ por ✅ y la fecha.

## 12. Problemas frecuentes

| Problema | Solución |
| --- | --- |
| `01-base.sh` dice que la IP no es 10.13.10.10 | Ponla en `/etc/netplan/50-cloud-init.yaml` (dirección, puerta de enlace y DNS de la sección 4) y ejecuta `sudo netplan apply` |
| Tras `01-base.sh` no entras por SSH | Entra por la consola de la VM: `sudo ufw status` y `sudo journalctl -u ssh -n 20`. Comprueba que tu clave está en `~/.ssh/authorized_keys` |
| No se ha cargado el plan contable español | *Ajustes → Facturación → Localización fiscal* → «España - PYMEs (2008)» |
| Odoo no responde | `sudo tail -50 /var/log/odoo/odoo-server.log` y `systemctl status odoo` |
| `502 Bad Gateway` en el navegador | Odoo está parado o arrancando: `sudo systemctl restart odoo` y espera unos segundos |
| El navegador dice «no seguro» | Falta instalar `almichain-ca.crt` en ese equipo (sección 9) |
| Las facturas en PDF salen sin estilos | Comprueba en *Ajustes → Técnico → Parámetros del sistema* que existe `report.url = http://127.0.0.1:8069` |
| El script de facturas da `401 Unauthorized` | La clave API ha caducado o está mal copiada: genera otra (sección 7) |
