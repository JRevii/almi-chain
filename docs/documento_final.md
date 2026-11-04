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

El esquema reparte la solución en cuatro zonas. **En la nube (AWS Academy)** está la web pública, en un servidor EC2 que se crea con Terraform y se sirve por HTTPS con el dominio de DuckDNS. **En el local** están los dos routers (red de empleados y red de clientes aislada, con un repetidor para el Wi-Fi), la impresora de tickets y el arcade stick. **En VirtualBox** están el equipo del gerente (Windows 11 + Ubuntu), el TPV de barra en modo quiosco, la recreativa y el servidor del local con Odoo y PostgreSQL, RAID 1 y copias cifradas. El TPV y el gerente entran a Odoo por HTTPS dentro del local, las copias salen a un bucket S3 en AWS y los clientes llegan a la web desde internet. Los **servicios externos** (GitHub, Trello, DuckDNS, Let's Encrypt y el operador de fibra) se usan sin instalar nada.

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

*Resumen pendiente: antiX + MAME en 1 núcleo y 1 GB, optimización y medidas.*

## 8. Arcade stick con Arduino

**Responsable:** Jon · **Fuente:** [`arcade-stick/README.md`](../arcade-stick/README.md)

*Resumen pendiente: Arduino Leonardo como teclado USB, compatible con cualquier emulador y personalizable.*

## 9. Página web y hosting en AWS

**Responsables:** Jose (bocetos y web) y Jon (AWS)

| Parte | Fuente |
|---|---|
| Bocetos (diseño conceptual) | [`bocetos/bocetos.md`](bocetos/bocetos.md) |
| Web: diseño, código, accesibilidad y pruebas | [`web/guia_web.md`](web/guia_web.md) |
| Despliegue en AWS con Terraform, Nginx, HTTPS y DuckDNS | [`infra/despliegue_aws.md`](infra/despliegue_aws.md) y [`infra/terraform/README.md`](../infra/terraform/README.md) |

Antes de programar la web se hicieron 19 bocetos, que se valoraron con cinco criterios. Ganó el concepto **Latón** (fondo negro y detalles dorados), con un 8,8 sobre 10. La web es unidireccional: solo informa. Es responsiva y accesible, y tiene un slideshow de platos, un mapa de los locales con Leaflet y geolocalización, y un formulario de muestra que no envía datos. Está publicada en https://almichain.duckdns.org con HTTPS. En el validador del W3C da 0 errores y 0 avisos, y en Lighthouse saca entre 99 y 100.

*Resumen pendiente (Jon): EC2 con IP elástica, Terraform, Nginx, Certbot y DuckDNS.*

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

Cada tecnología se eligió comparándola con otras opciones: AWS frente a Azure, Google Cloud y un hosting compartido; Odoo frente a SAP Business One, Holded y un TPV suelto; PostgreSQL frente a MySQL y SQL Server; y Arduino Leonardo frente a un encoder USB comercial y una Raspberry Pi. Los motivos principales son el coste (software libre y Learner Lab gratis), que Odoo solo funciona con PostgreSQL y que el Leonardo se reconoce como teclado USB sin drivers.

## 14. Revisión de seguridad y pruebas

**Responsables:** Iñigo y todos

*Pendiente: tabla resumen con cada prueba (qué se prueba, resultado esperado, resultado y enlace a la evidencia), sacada de las tablas de pruebas de cada guía, y comprobación del mínimo privilegio en cada parte.*

## 15. Conclusiones

**Qué ha funcionado.** Hemos montado entera la informática de un restaurante: equipos, red, web en la nube, ERP con TPV, base de datos y copias de seguridad. Cada parte tiene su guía en el repositorio y se puede volver a montar desde cero. Todo el software es libre o gratuito, así que el restaurante solo paga el hardware, la fibra y el servidor de AWS. Además, cada parte se ha probado y las evidencias están en las guías. Por ejemplo, la web da 0 errores en el W3C y entre 99 y 100 en Lighthouse, y el servidor sigue funcionando al quitarle un disco del RAID.

**Problemas y cómo se resolvieron.** Los fallos que fueron saliendo se apuntaron en cada guía, con la causa y la solución. Por ejemplo, el servidor de Odoo aceptaba contraseñas por SSH porque el script de seguridad se ejecutó antes de copiar la clave, y se corrigió dejando solo el acceso con clave. Las copias automáticas no se hacían porque la máquina virtual del servidor está apagada por la noche, a la hora programada, y se resolvió haciendo también una copia unos minutos después de cada arranque. También hubo que adaptarse a cambios de planteamiento, como pasar de Windows 10 a Windows 11 en el equipo del gerente al quedarse Windows 10 sin soporte. Trabajar con GitHub y con ramas y Pull Requests nos ayudó a no pisarnos el trabajo entre seis personas.

**Qué mejoraríamos.** En un restaurante real, el servidor estaría encendido siempre, con su SAI, para que las copias se hagan a su hora. También tendríamos un dominio propio en lugar de DuckDNS y una cuenta normal de AWS en lugar del Learner Lab, que se apaga al cerrar la sesión. Y la web, que ahora solo informa, podría tener reservas de verdad conectadas con Odoo.

## 16. Anexos

- Anexo I: contrato de equipo → [`gestion/`](../gestion)
- Anexo II: documento de los 11 pasos → [`gestion/`](../gestion)
- Reparto y Gantt → [`diagramas/reparto_y_gantt.png`](diagramas/reparto_y_gantt.png)
