# Fichas de hardware y software y presupuesto

| Responsable | Fechas (Gantt) | Carpeta en el repo | Precios consultados |
|---|---|---|---|
| Jose | 27/10 – 29/10 | `docs/` | 22/10/2026 (sin IVA + 21 % de IVA aparte) |

El presupuesto detallado, sin IVA y con el IVA aparte, está en `presupuesto_local_plano.xlsx`. Sigue el **plano del local (cableado y Wi-Fi)** y el **esquema de red** del equipo. Este documento explica **qué** se compra para cada equipo, **qué software** lleva y **por qué**.

> **Laboratorio frente a compra real.** En el reto montamos los equipos como máquinas virtuales en VirtualBox y la web en AWS Academy, así que a nosotros no nos cuesta nada. Este presupuesto es lo que tendría que comprar **el restaurante** para tenerlo funcionando de verdad.

## Resumen

| Concepto | Importe |
|---|---|
| Compra inicial de hardware | **5.595,56 €** con IVA (4.624,43 € + IVA) |
| Software | **0 €** (libre o incluido en el equipo) |
| Costes recurrentes | **≈ 47 €/mes** con IVA (≈ 568 €/año) |
| **Primer año** | **≈ 6.164 €** con IVA |

| Equipo | Total |
|---|---|
| Gerente | 1.053,59 € |
| TPV de barra (×2, con impresora) | 1.899,36 € |
| Servidor | 1.950,78 € |
| Red (router, switches y puntos de acceso) | 201,98 € |
| Rack y cableado | 431,40 € |
| Recreativa y arcade stick | 58,45 € |

## Por qué Windows 11 y no Windows 10

El enunciado de 2022-2023 pide Windows 10, pero **Windows 10 dejó de tener soporte el 14/10/2025**. Desde entonces solo recibe parches de seguridad pagando las actualizaciones ampliadas (ESU): para empresas cuestan **61 $** el primer año (terminó el 13/10/2026), **122 $** el segundo y **244 $** el tercero, por equipo.

Por eso el equipo decidió usar **Windows 11** en el gerente y en los TPV (validado por el profesor el 26/10/2026):
- **Seguridad por defecto:** sigue recibiendo actualizaciones gratis. Un TPV que cobra a clientes no puede llevar un sistema sin parches.
- **Sin coste extra:** los equipos presupuestados ya lo traen, el del gerente con Windows 11 Pro y los TPV con Windows 11 IoT Enterprise LTSC (soporte hasta 2034 y pensado para equipos de función fija como un TPV). Así nos ahorramos el ESU.

---

## 1. Equipo del gerente

| | |
|---|---|
| **Modelo** | Lenovo ThinkCentre neo 50s Gen 5 (SFF) |
| **Procesador** | Intel Core i5-14400 (10 núcleos, 16 hilos, hasta 4,7 GHz) |
| **RAM** | 16 GB DDR5 (ampliable a 64 GB) |
| **Disco** | SSD NVMe de 512 GB |
| **Red** | Ethernet 1 Gbps, Wi-Fi 6E, Bluetooth 5.3 |
| **Monitor** | AOC 24B2XH de 23,8″, IPS Full HD |
| **Precio** | 962,60 € + 90,99 € |

**Software:** Windows 11 Pro y Ubuntu Desktop 24.04 LTS en arranque dual con GRUB, Microsoft Edge y Firefox, el navegador para entrar en Odoo y KeePassXC.

**Por qué:** el i5 y los 16 GB sobran para ofimática y Odoo durante años. 512 GB dan para dos sistemas (unos 250 GB cada uno). La garantía y los repuestos de una gama profesional (ThinkCentre) son mejores que los de un equipo doméstico.

**Seguridad:** el gerente usa una cuenta **sin permisos de administrador** en los dos sistemas. El inicio rápido de Windows va desactivado (si no, Windows deja el disco bloqueado y Ubuntu no puede montarlo). Se recomienda cifrar el disco con BitLocker y LUKS.

## 2. TPV de barra (×2)

| | |
|---|---|
| **Modelo** | 10POS 10T 15″, todo en uno táctil |
| **Procesador** | Intel Core i5, 4 núcleos |
| **RAM / disco** | 8 GB DDR4 / SSD de 256 GB |
| **Pantalla** | 15″ táctil capacitiva, 1024×768 |
| **Puertos** | 6 USB, 2 RS-232, Ethernet Gigabit, HDMI y VGA (para un visor de cliente) |
| **Sistema incluido** | Windows 11 IoT Enterprise LTSC |
| **Precio** | 708,48 € cada uno |

**Software:** Windows 11 (Pro en el reto; IoT Enterprise LTSC en la compra real), Edge en **modo quiosco** abriendo el TPV de Odoo por HTTPS, el certificado del servidor instalado como de confianza y el driver de la impresora Epson.

**Por qué:** un TPV todo en uno ocupa poco en la barra y aguanta grasa y golpes mejor que un PC con monitor. La pantalla táctil es más rápida para el camarero. Como Odoo funciona en el navegador, no hace falta más potencia.

**Seguridad:** un usuario estándar sin administrador y en modo quiosco (solo puede usar el TPV), los USB que no se usan bloqueados y conexión por cable a la red de empleados, nunca al Wi-Fi de clientes.

## 3. Impresora de tickets (×2)

| | |
|---|---|
| **Modelo** | Epson TM-T20III |
| **Tecnología** | Térmica directa (no gasta tinta), papel de 80 mm |
| **Velocidad** | 250 mm/s |
| **Conexión** | USB + serie RS-232 |
| **Cortador** | Automático (1,5 millones de cortes) |
| **Precio** | 241,20 € cada una |

**Por qué:** Epson es el estándar en hostelería y la usan casi todos los programas de TPV. Es térmica, así que solo hay que comprar rollos de papel. Va por USB a su TPV, sin estar en la red, lo que reduce la superficie de ataque.

## 4. Servidor

| | |
|---|---|
| **Modelo** | Lenovo ThinkSystem ST50 V3 (torre) |
| **Procesador** | Intel Xeon E-2434 |
| **RAM** | 16 GB |
| **Discos** | 2 × 1 TB SATA (**discos A y B, RAID 1**) + Seagate IronWolf de 4 TB (**disco C, copias**) |
| **Bahías** | 3 × 3,5″ |
| **Fuente** | 500 W |
| **SAI** | APC Back-UPS de 700 VA / 405 W |
| **Precio** | 1.604,84 € + 214,95 € + 130,99 € |

**Software:** Ubuntu Server 24.04 LTS, Docker y Docker Compose, Odoo Community y PostgreSQL, Nginx con HTTPS delante de Odoo, `mdadm` (RAID 1), `restic` y `cron` (copias cifradas), UFW (cortafuegos) y SSH con claves.

**Por qué:**
- Un **servidor de verdad** (Xeon) admite memoria ECC, que corrige errores de RAM, y está pensado para funcionar 24 horas.
- **RAID 1:** si se rompe el disco A, el B tiene lo mismo y el restaurante sigue funcionando (failover).
- **Disco C aparte:** el RAID **no es una copia de seguridad** (si se borra algo, se borra en los dos discos). Por eso las copias van a otro disco.
- **SAI:** un corte de luz en plena escritura puede corromper la base de datos. El SAI da tiempo para apagar el servidor bien.

**Seguridad:** solo están abiertos los puertos necesarios (443, y 22 solo desde la red de administración), SSH sin contraseña (solo con claves) y sin acceso de `root`. PostgreSQL no se expone a la red y cada base de datos tiene su propio usuario. Las contraseñas se guardan en KeePassXC, nunca en GitHub.

## 5. Red

Así queda la red según el plano: la fibra entra en el **rack** del despacho del gerente. Allí están la ONT del operador, nuestro router **R1-AlmiChain** y dos switches. De ahí salen los cables a cada equipo y al punto de acceso del comedor.

| Equipo | Modelo | Función | Precio |
|---|---|---|---|
| R-Operador (ONT) | El que da el operador | Convierte la fibra en red. Da la IP pública por DHCP | Incluido en la fibra |
| R1-AlmiChain | TP-Link ER605 (5 puertos Gigabit, VLAN) | Router propio: NAT, DHCP, DNS. Red de empleados 10.13.10.0/24 y red de clientes 10.13.20.0/24, aisladas con ACL | 65,00 € |
| SW-Empleados | TP-Link TL-SG108E (8 puertos, gestionable) | Conecta servidor, PC del gerente, TPV 1, TPV 2 y recreativa | 29,99 € |
| SW-WiFi | TP-Link TL-SG105 (5 puertos) | Conecta el AP principal (red de clientes) | 16,99 € |
| AP principal | TP-Link Archer C6 AC1200 en modo punto de acceso | Wi-Fi de clientes en el comedor, WPA2-AES, canal 6 | 45,00 € |
| AP repetidor | TP-Link Archer C6 AC1200 | Repetidor **WDS** al otro lado del comedor, solo con corriente, DHCP desactivado | 45,00 € |

**Por qué un router propio:** el router del operador no deja hacer ACL ni separar bien las dos redes. Con R1 controlamos nosotros la red, y si cambiamos de operador solo cambia la ONT.

**Por qué dos switches:** así los equipos de empleados y el Wi-Fi de clientes van por cables y switches distintos. Un cliente del Wi-Fi no puede llegar al servidor ni a los TPV.

**Seguridad:** WPA2-AES (o WPA3 si los dos AP lo admiten), WPS desactivado, contraseñas de administración cambiadas y DHCP desactivado en el repetidor.

> Pendiente: confirmar con Yeray e Iñigo los modelos de red y que el firmware de los AP admite WDS. Los precios de R1 y de los switches son orientativos.

## 6. Rack y cableado

| Elemento | Cantidad | Precio |
|---|---|---|
| Armario rack mural 19" de 9U con puerta de cristal y llave | 1 | 89,90 € |
| Bandeja fija 1U (para la ONT, R1 y los switches) | 1 | 14,90 € |
| Regleta de rack de 8 enchufes | 1 | 24,90 € |
| Patch panel de 12 puertos Cat 6 | 1 | 24,90 € |
| Bobina de cable UTP Cat 6 de 100 m (cobre) | 2 | 99,80 € |
| Toma de red Cat 6 de superficie | 5 | 27,50 € |
| Latiguillos Cat 6 (6 de 0,5 m y 5 de 2 m) | 11 | 32,50 € |
| Canaleta de PVC de 2 m para el techo | 30 | 117,00 € |
| **Total** | | **431,40 €** |

**Cuánto cable:** según el plano, del rack a cada equipo hay TPV 1 29 m, TPV 2 23 m, AP principal 17 m, recreativa 27 m y PC del gerente 8 m. En total son **104 m**, por eso hacen falta 2 bobinas de 100 m. Todos los tramos miden menos de 90 m, y el límite del cable UTP es de 100 m.

**Por qué Cat 6:** llega a 1 Gbps sin problemas y es lo normal hoy en una instalación nueva. Va por canaleta en el techo para que no se pise ni se moje.

**Por qué rack con llave:** los equipos de red y el servidor quedan juntos, en el despacho y cerrados. Nadie de la sala puede desconectarlos ni enchufar algo. El servidor es de torre, así que va al lado del rack, y el SAI protege también la ONT, el router y los switches.

> La instalación la hace el propio equipo, así que no se presupuesta mano de obra. Los precios de esta tabla son orientativos.

## 7. Máquina recreativa y arcade stick

| | |
|---|---|
| **Equipo** | El que ya tiene el cliente: 1 núcleo y 1 GB de RAM (coste 0 €) |
| **Controlador** | Arduino Leonardo Rev3 (ATmega32u4): 25,40 € |
| **Mandos** | Kit de 1 jugador con Eurojoystick 2, 10 botones y cableado: 33,05 € |

**Software:** antiX core (una distribución Linux muy ligera, sin escritorio), MAME arrancando directamente y el IDE de Arduino para programar el stick.

**Por qué:**
- **antiX core:** con 1 GB de RAM no cabe un escritorio normal. antiX arranca con unos 100 MB y deja el resto para MAME.
- **Arduino Leonardo:** su chip (ATmega32u4) tiene USB nativo, así que el ordenador lo reconoce como un **teclado o mando** sin instalar drivers y funciona con cualquier emulador. Un Arduino Uno no puede hacerlo.
- El kit trae su propio encoder USB, pero lo sustituimos por el Arduino porque el enunciado pide que el control se pueda personalizar.

## 8. Software (todo de coste 0)

| Software | Dónde | Licencia | Por qué |
|---|---|---|---|
| Windows 11 Pro / Windows 11 IoT Enterprise LTSC | Gerente, TPV | Incluida con el equipo (OEM) | Con soporte, a diferencia de Windows 10 |
| Ubuntu Desktop / Server 24.04 LTS | Gerente, servidor | Libre (GPL) | Soporte hasta 2029 |
| Odoo Community | Servidor | Libre (LGPL) | ERP y TPV en uno (lo justifica Alejandro) |
| PostgreSQL | Servidor | Libre (licencia PostgreSQL) | Base de datos que usa Odoo |
| Docker / Docker Compose | Servidor | Libre (Apache 2.0) | Despliegue reproducible |
| Nginx, Certbot | Servidor, AWS | Libre | HTTPS |
| mdadm, restic, UFW | Servidor | Libre | RAID, copias cifradas, cortafuegos |
| KeePassXC | Gerente, administración | Libre (GPL) | Gestor de contraseñas: nada de contraseñas en papel ni en GitHub |
| antiX, MAME | Recreativa | Libre (GPL) | Ligero / emulador |
| Arduino IDE | Para programar el stick | Libre | |
| Terraform | Para AWS | Gratis (BSL) | Infraestructura como código |
| VirtualBox | Solo en el laboratorio | Libre (GPL) | No se usa en la compra real |

## 9. Costes recurrentes

| Concepto | Al mes |
|---|---|
| Fibra Vodafone Empresas 1 Gb simétrica (la eligió Yeray; precio desde el mes 13) | 35,00 € con IVA (28,93 € + IVA). El primer año, 25 € con IVA por oferta |
| AWS: EC2 t3.micro + IP elástica + disco de 8 GB | ≈ 11,90 $ (≈ 10,20 €) + IVA |
| DuckDNS + Let's Encrypt | 0 € |

En el reto, AWS Academy Learner Lab no nos cobra nada. El precio de AWS es lo que pagaría el restaurante con una cuenta normal.

## 10. Fuentes (consultadas el 22/10/2026)

Todos los enlaces de compra están en el Excel, en cada fila. Además:
- Fin del soporte de Windows 10 y precios de ESU (motivo para usar Windows 11): https://www.techrepublic.com/article/news-windows-10-esu-cheat-sheet/
- Precio de la IPv4 pública en AWS: https://aws.amazon.com/blogs/aws/new-aws-public-ipv4-address-charge-public-ip-insights
- Comparativa de fibra para empresas: https://selectra.es/internet-telefono/empresas/fibra
- Elección de la fibra: `docs/Comparativa y contratación de la línea WAN.pdf` (Yeray)

> Los precios cambian. Antes de entregar, vuelve a abrir los enlaces, actualiza los que hayan cambiado y pon la nueva fecha.
