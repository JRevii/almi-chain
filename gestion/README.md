# Gestión del proyecto

Anexos I (contrato de equipo), II (11 pasos) y IX, y enlace al tablero Kanban/Gantt.

## Anexos

| Anexo | Documento | Estado |
| --- | --- | --- |
| I · Contrato de equipo | [`anexos/Anexo_I_Contrato_de_Equipo.pdf`](anexos/Anexo_I_Contrato_de_Equipo.pdf): roles, reparto de tareas (responsable y apoyo), normas, consecuencias y código de conducta | ✅ 26/10, firmado por los seis |
| II · Documento de 11 pasos | [`anexos/Anexo_II_11_pasos.xlsx`](anexos/Anexo_II_11_pasos.xlsx): la plantilla de los 11 pasos del reto introductorio rellenada con este reto (activación del equipo, plantear, identificar, parámetros, información, alternativas, selección, planificación, ejecución, presentación y reflexión) | ✅ 12/11 |
| IX · Seguimiento (Gantt/Kanban) y control de versiones | Gantt planificado: [`../docs/diagramas/reparto_y_gantt.png`](../docs/diagramas/reparto_y_gantt.png) · tablero de Trello: [Lista de tareas](https://trello.com/b/6ad9c97e065249af633349a0/lista-de-tareas) · control de versiones: este repositorio (ramas y PR, ver [`CONTRIBUTING.md`](../CONTRIBUTING.md)) | ✅ 27/10 · [captura del tablero](capturas/trello_tablero.png) |

### Capturas del tablero de Trello

| Captura | Qué muestra |
| --- | --- |
| [trello_tablero](capturas/trello_tablero.png) · [02_trello_tablero](capturas/02_trello_tablero.png) | El tablero con sus listas |
| [03_trello_info_reglas](capturas/03_trello_info_reglas.png) | Tarjetas de información y reglas del equipo |
| [04_trello_tarjeta_wan](capturas/04_trello_tarjeta_wan.png) | Una tarjeta por dentro: la de la línea WAN |
| [05_trello_etiquetas](capturas/05_trello_etiquetas.png) | Etiquetas usadas |

## Validaciones del profesor

Lo que el profesor (o la profesora de Redes) ha revisado y dado por bueno, con la fecha.

| Fecha | Criterio o parte | Resultado |
| --- | --- | --- |
| **12/11** | **Ampliación de la cobertura Wi-Fi**: router y repetidor con la red de clientes aislada del servidor · profesora de Redes ([routers](../redes/routers/router-y-repetidor.md)) | ✅ **Validado** |
| **12/11** | **Diseño y esquema de conectividad**: versión final del Packet Tracer · profesora de Redes ([`almichain.pkt`](../redes/packet-tracer/almichain.pkt)) | ✅ **Validado** |
| **10/11** | **Instalación de SO y arranque dual** (Windows 11 + Ubuntu, cifrados) · profesor de Sistemas | ✅ **Validado** |
| **10/11** | **Restricción de cuentas y equipos** (mínimo privilegio en el gerente, el TPV y la recreativa) · profesor de Sistemas | ✅ **Validado** |
| **10/11** | **Optimización y monitorización de la máquina recreativa** · profesor de Sistemas | ✅ **Validado** |
| **10/11** | **Plan de copias de seguridad** (local y en AWS S3, con restauración en directo) · profesor de Sistemas | ✅ **Validado** |
| **10/11** | **Disco redundante (RAID 1)** · profesor de Sistemas | ✅ **Validado** |
| **10/11** | **Configuración de la impresora** · profesor de Sistemas | ✅ **Validado** |
| **10/11** | **Diseño web** | ✅ **5** |
| **10/11** | **Implementación web** (HTTPS, dominio y AWS con Terraform) | ✅ **5** |
| **10/11** | **ERP (Odoo)** | ✅ **5** |
| **10/11** | **Copias de la BD**, con copia remota a S3 y restauración desde la nube hechas en directo delante del profesor ([prueba 18](../backups/README.md#pruebas)) | ✅ **5** |
| **10/11** | **Digitalización: tecnologías habilitadoras** | ✅ **5** |
| **10/11** | **Digitalización: arcade stick** | ✅ **5** |
| 29/10 | Medidas de rendimiento de la recreativa ([resultados](../recreativa/medidas/resultados.md)) | ✅ Suficientes como constancia |
| 27/10 | Venta en el TPV → ticket impreso solo, como impresión y factura automáticas ([TPV, prueba 8](../sistemas/tpv-barra/README.md#pruebas)) | ✅ Válido |
| 26/10 | Packet Tracer: esquema, plano y configuración (profesora de Redes) ([prueba 9](../redes/README.md#7-pruebas)) | ✅ Correcto |
| 26/10 | Windows 11 en lugar de Windows 10 en el equipo del gerente ([dual boot](../sistemas/gerente-dualboot/README.md)) | ✅ Válido |
| — | Repetidor (*Range Extender*) en lugar de WDS, porque el firmware del TL-WR841N no tiene WDS ([repetidor](../redes/routers/router-y-repetidor.md)) | ✅ Indicado por el profesor |
| — | Montaje y funcionamiento del arcade stick ([prueba 1](../arcade-stick/README.md#7-pruebas)) | ✅ Funciona |

## Planificación

![Reparto de tareas y Gantt](../docs/diagramas/reparto_y_gantt.png)

El Gantt es la **planificación inicial** (26/10 – 13/11). Cambios respecto al plan: la factura automática la llevan Yeray e Iñigo (en el plan, Sendoa), y la fecha de entrega del contrato es el 09/11.

## Roles

| Persona | Rol | Área técnica |
| --- | --- | --- |
| Jon Revillas | Coordinador | Nube (AWS), recreativa, Arduino e impresora |
| Yeray Arratibel | Secretario | Gantt, Trello y línea WAN |
| Jose Rizo | Documentación | Web y presupuesto |
| Iñigo Basterrechea | Portavoz | Redes y TPV |
| Sendoa Guerrero | Técnico | Servidor, RAID y copias |
| Alex Marquez | Técnico | Base de datos y ERP |

Como coordinador, Jon tenía sus propias tareas (las de la tabla) y, además, se encargaba de que el trabajo avanzara: resolver dudas, echar una mano a los compañeros cuando se atascaban y revisar que lo que se subía a GitHub estuviera completo. Cada parte es de su responsable, que es quien la ha hecho y quien la defiende.

## Cómo se lleva el seguimiento

1. **Planificar:** el Gantt reparte las tareas por persona y fecha, y el contrato (Anexo I) fija el responsable y el apoyo de cada una.
2. **Seguir el día a día:** cada tarea es una tarjeta de Trello que pasa de lista en lista hasta «Hecho».
3. **Entregar el trabajo:** cada cambio va en una rama de GitHub y entra en `main` con una Pull Request revisada ([`CONTRIBUTING.md`](../CONTRIBUTING.md)). El historial deja constancia de quién hizo cada cosa y cuándo.
4. **Documentar:** cada parte tiene su guía con pruebas y capturas, y el [documento final](../docs/documento_final.md) las resume.
