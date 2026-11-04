# Almi-Chain · Documento final del Reto 1

| Ciclo | Equipo | Entrega |
|---|---|---|
| ASIR 1º · Centro de Estudios ALMI | Jon, Sendoa, Yeray, Iñigo, Alejandro y Jose | 13/11/2026 |

> **Esqueleto (Jose).** Cada apartado indica su responsable y el documento del repositorio de donde sale. Para cerrar el documento, cada responsable escribe el resumen de su apartado (3–5 líneas) en el hueco marcado con *Resumen pendiente* y comprueba que los enlaces y las capturas funcionan. Los pasos detallados no se copian aquí: se enlazan, para no tener dos versiones distintas.

## Índice

1. [Introducción y arquitectura](#1-introducción-y-arquitectura)
2. [Organización del equipo](#2-organización-del-equipo)
3. [Necesidades de comunicación](#3-necesidades-de-comunicación)
4. [Equipos: presupuesto y fichas de hardware y software](#4-equipos-presupuesto-y-fichas-de-hardware-y-software)
5. [Sistemas operativos y cuentas de usuario](#5-sistemas-operativos-y-cuentas-de-usuario)
6. [Red: WAN, plano, Wi-Fi y repetidor](#6-red-wan-plano-wi-fi-y-repetidor)
7. [Máquina recreativa](#7-máquina-recreativa)
8. [Arcade stick con Arduino](#8-arcade-stick-con-arduino)
9. [Página web y hosting en AWS](#9-página-web-y-hosting-en-aws)
10. [ERP + TPV y factura automática](#10-erp--tpv-y-factura-automática)
11. [Base de datos](#11-base-de-datos)
12. [Disco redundante y copias de seguridad](#12-disco-redundante-y-copias-de-seguridad)
13. [Digitalización](#13-digitalización)
14. [Revisión de seguridad y pruebas](#14-revisión-de-seguridad-y-pruebas)
15. [Conclusiones](#15-conclusiones)
16. [Anexos](#16-anexos)

---

## 1. Introducción y arquitectura

**Responsable:** todos · **Fuente:** [`README.md`](../README.md)

Una cadena de restaurantes nos encarga su informática: equipos del gerente y de barra, máquina recreativa, red con Wi-Fi para clientes, web en la nube, ERP con TPV, base de datos de los locales y plan de copias de seguridad.

![Arquitectura de la solución](diagramas/esquema_definitivo.png)

*Resumen pendiente: explicar el esquema en 4–5 líneas (qué hay en el local, qué hay en AWS y cómo se conectan).*

## 2. Organización del equipo

**Responsable:** Yeray · **Fuente:** [`gestion/README.md`](../gestion/README.md)

- Contrato de equipo (Anexo I), Gantt, Trello y actas.
- Reparto de tareas: [`diagramas/reparto_y_gantt.png`](diagramas/reparto_y_gantt.png)
- Normas del repositorio: [`CONTRIBUTING.md`](../CONTRIBUTING.md)

*Resumen pendiente.*

## 3. Necesidades de comunicación

**Responsable:** Iñigo · **Fuente:** [`necesidades/necesidades-comunicacion.md`](necesidades/necesidades-comunicacion.md)

*Resumen pendiente: inventario de equipos, redes (empleados y clientes) y tráfico.*

## 4. Equipos: presupuesto y fichas de hardware y software

**Responsable:** Jose · **Fuente:** [`presupuesto/fichas_hw_sw.md`](presupuesto/fichas_hw_sw.md) · Excel: [`presupuesto/presupuesto_local_plano.xlsx`](presupuesto/presupuesto_local_plano.xlsx)

Para cada equipo (gerente, TPV, impresora de tickets, servidor, red, rack y cableado, recreativa y arcade stick) se indica el modelo, las características, el software, el precio real con su enlace y fecha, y por qué se ha elegido. Todo el software es libre o viene incluido con el equipo. En vez de Windows 10, que ya no tiene soporte, se usa Windows 11. El presupuesto da los precios sin IVA, con el 21 % de IVA aparte, y separa la compra inicial de los gastos mensuales (fibra y AWS).

## 5. Sistemas operativos y cuentas de usuario

### 5.1 Equipo del gerente (dual boot)

**Responsable:** Sendoa · **Fuente:** [`sistemas/gerente-dualboot/README.md`](../sistemas/gerente-dualboot/README.md)

*Resumen pendiente: Windows 11 Pro + Ubuntu, GRUB, usuario sin administrador.*

### 5.2 TPV de barra e impresora de tickets

**Responsables:** Iñigo (TPV) y Jon (impresora) · **Fuentes:** [`sistemas/tpv-barra/README.md`](../sistemas/tpv-barra/README.md) y [`sistemas/tpv-barra/tpv-quiosco.md`](../sistemas/tpv-barra/tpv-quiosco.md)

*Resumen pendiente: modo quiosco, usuario estándar, certificado del servidor e impresión desde Odoo.*

## 6. Red: WAN, plano, Wi-Fi y repetidor

**Responsables:** Yeray (WAN), Jon (Packet Tracer), Iñigo y Yeray (routers)

| Parte | Fuente |
|---|---|
| Comparativa y contratación de la línea WAN | [`redes/routers/wan/README.md`](../redes/routers/wan/README.md) |
| Esquema de conectividad, plano y Packet Tracer | [`redes/README.md`](../redes/README.md) |
| Router y repetidor Wi-Fi (en lugar de WDS) | [`redes/routers/repetidor/repetidor-wifi.md`](../redes/routers/repetidor/repetidor-wifi.md) |

*Resumen pendiente: por qué esa fibra, las dos redes aisladas y por qué repetidor y no WDS.*

## 7. Máquina recreativa

**Responsable:** Jon · **Fuentes:** [`recreativa/README.md`](../recreativa/README.md) y [`recreativa/medidas/resultados.md`](../recreativa/medidas/resultados.md)

La recreativa es una máquina virtual con los mismos límites que el equipo real: **1 núcleo, 1 GB de RAM y sin swap**. Lleva **antiX 26.1 core** (5 servicios y unos 160 MB de RAM al arrancar) y **MAME 0.276**, con una ROM legal y gratuita (Gridlee). Al encenderla entra sola en el menú de MAME a pantalla completa, sin escritorio ni contraseña, y ese menú hace de front-end para elegir juego. La optimización ajusta MAME a un solo núcleo (vídeo por software, salto de fotogramas y sonido más ligero), quita consolas sobrantes y acorta el arranque. Jugando, usa un **20,3 % de CPU** y MAME ocupa **364 MB**. Para el mínimo privilegio, el usuario que juega no tiene `sudo`, se administra con otro usuario y SSH no admite root. Las incidencias (instalador, SSH y permisos de antiX) están documentadas con sus capturas.

## 8. Arcade stick con Arduino

**Responsable:** Jon · **Fuente:** [`arcade-stick/README.md`](../arcade-stick/README.md)

El arcade stick usa un **Arduino Leonardo**, que tiene USB nativo y el ordenador reconoce como un **teclado USB, sin drivers**. Por eso funciona en MAME y en cualquier otro programa. Se eligió frente al *encoder* USB del kit porque el *encoder* tiene la asignación de botones fija, y el enunciado pide input personalizable. El código usa las resistencias internas (`INPUT_PULLUP`), tiene antirrebote de 10 ms y guarda todas las teclas en una sola tabla, así que cambiar un control es cambiar un valor. Además, se puede remapear desde el propio emulador sin reprogramar. Los botones envían las teclas por defecto de MAME (acción, moneda y start), y mantener start 2 segundos vuelve al menú. Cuesta 58,45 € entre el Arduino y el kit.

## 9. Página web y hosting en AWS

**Responsables:** Jose (bocetos y web) y Jon (AWS)

| Parte | Fuente |
|---|---|
| Bocetos (diseño conceptual) | [`bocetos/bocetos.md`](bocetos/bocetos.md) |
| Web: diseño, código, accesibilidad y pruebas | [`web/guia_web.md`](web/guia_web.md) |
| Despliegue en AWS con Terraform, Nginx, HTTPS y DuckDNS | [`infra/despliegue_aws.md`](infra/despliegue_aws.md) y [`infra/terraform/README.md`](../infra/terraform/README.md) |

Antes de programar la web se hicieron 19 bocetos, que se valoraron con cinco criterios. Ganó el concepto **Latón** (fondo negro y detalles dorados), con un 8,8 sobre 10. La web es unidireccional: solo informa. Es responsiva y accesible, y tiene un slideshow de platos, un mapa de los locales con Leaflet y geolocalización, y un formulario de muestra que no envía datos. Está publicada en https://almichain.duckdns.org con HTTPS. En el validador del W3C da 0 errores y 0 avisos, y en Lighthouse saca entre 99 y 100.

El despliegue es **infraestructura como código**: un solo `terraform apply` crea en AWS una **EC2 t3.micro** con Ubuntu, su grupo de seguridad (80 y 443 abiertos, y el 22 solo desde la IP del administrador) y una **IP elástica**, para que la dirección no cambie entre sesiones del laboratorio. Al arrancar, el script de `user-data` instala **Nginx** con compresión y cabeceras de seguridad, da de alta el dominio gratuito en **DuckDNS** y saca el certificado de **Let's Encrypt** con **Certbot**, con redirección de HTTP a HTTPS y renovación automática. Se comprobó que es reproducible destruyéndolo todo y volviéndolo a crear: la web volvió a estar en marcha, con un certificado nuevo, en 1 minuto y 45 segundos. Ninguna credencial está en el repositorio: el token y el estado de Terraform se quedan fuera de Git.

## 10. ERP + TPV y factura automática

**Responsables:** Sendoa (servidor y factura automática) y Alejandro (configuración de Odoo) · **Fuente:** [`erp/README.md`](../erp/README.md)

*Resumen pendiente: Odoo Community + PostgreSQL en Docker, módulos, usuarios por rol, importación de datos y factura automática al vender en el TPV.*

## 11. Base de datos

**Responsable:** Alejandro · **Fuente:** [`bd/README.md`](../bd/README.md)

*Resumen pendiente: modelo E/R, modelo relacional normalizado, scripts SQL y consultas.*

## 12. Disco redundante y copias de seguridad

**Responsable:** Sendoa · **Fuentes:** [`backups/README.md`](../backups/README.md) y [`infra/terraform-copias/README.md`](../infra/terraform-copias/README.md)

*Resumen pendiente: RAID 1 con mdadm y prueba de failover, copias con restic y cron, copia remota en S3 y prueba de restauración.*

## 13. Digitalización

**Responsable:** Jose · **Fuente:** [`digitalizacion/digitalizacion.md`](digitalizacion/digitalizacion.md)

La solución usa varias tecnologías habilitadoras digitales: un ERP (Odoo), análisis de datos (PostgreSQL), la nube (AWS), IoT con Arduino y ciberseguridad. Con ellas el restaurante cobra antes, controla el stock al momento, se da a conocer en internet y protege su información frente a averías y cortes de luz.

## 14. Revisión de seguridad y pruebas

**Responsables:** Iñigo y todos

*Pendiente: tabla resumen con cada prueba (qué se prueba, resultado esperado, resultado y enlace a la evidencia), sacada de las tablas de pruebas de cada guía, y comprobación del mínimo privilegio en cada parte.*

## 15. Conclusiones

*Pendiente (todos): qué ha funcionado, qué problemas hubo y cómo se resolvieron, y qué se mejoraría.*

## 16. Anexos

- Anexo I: contrato de equipo → [`gestion/`](../gestion)
- Anexo II: documento de los 11 pasos → [`gestion/`](../gestion)
- Reparto y Gantt → [`diagramas/reparto_y_gantt.png`](diagramas/reparto_y_gantt.png)
