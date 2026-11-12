# Almi-Chain · Reto 1 ASIR1 (2026-2027)

Proyecto en equipo del Centro de Estudios ALMI: infraestructura informática completa para una cadena de restaurantes (equipos, red, web en la nube, ERP, base de datos y copias de seguridad).

**Equipo:** Sendoa · Jon · Jose · Iñigo · Yeray · Alejandro

## Estructura del repositorio

| Carpeta | Contenido | Tarea del reto |
| --- | --- | --- |
| `docs/` | Documentación general y diagramas de arquitectura | Documentación reproducible |
| `gestion/` | Anexos (I, II, IX) y Gantt/Kanban | Seguimiento del trabajo |
| `sistemas/gerente-dualboot/` | Equipo del gerente: Windows 11 Pro + Ubuntu (dual boot) | Implantación de SO |
| `sistemas/tpv-barra/` | TPV de barra en Windows (una VM; el segundo TPV es un clon) + impresora de tickets, mínimos privilegios | Equipos, permisos, impresora |
| `recreativa/` | VM con MAME optimizada (1 núcleo, 1 GB RAM) y pruebas de rendimiento | Máquina recreativa |
| `arcade-stick/` | Código Arduino y montaje del arcade stick | Arcade stick |
| `redes/` | Línea WAN (`routers/wan/`), plano de red, Wi-Fi, repetidor (`routers/repetidor/`) y Packet Tracer | Conectividad |
| `web/` | Web estática responsiva y accesible | Página web |
| `infra/terraform/` | Despliegue en AWS (EC2 con IP elástica), Nginx + HTTPS con Let's Encrypt, DuckDNS | Hosting reproducible |
| `infra/terraform-copias/` | Bucket S3 cifrado para la copia remota de restic | Copias de seguridad (regla 3-2-1) |
| `erp/` | ERP + TPV y caso de uso automatizado (emisión de factura) | ERP |
| `bd/` | Modelo E/R, modelo relacional y scripts SQL | Base de datos |
| `backups/` | Disco redundante (RAID), plan de copias local y remoto (AWS S3) y pruebas de restauración | Copias de seguridad |

## Manual técnico (entrega)

**[`docs/Almi-Chain_Manual_tecnico.pdf`](docs/Almi-Chain_Manual_tecnico.pdf)**: el manual completo en PDF (127 páginas): portada, índice, y para cada parte un cuadro «Dónde está en GitHub», el resumen y la guía paso a paso con sus capturas, comandos y pruebas. Empieza por la red (Packet Tracer). Se genera a partir de las guías de este repositorio.

## Dónde está cada tarea del reto

Las 16 tareas de la hoja de seguimiento, con el documento que la explica y dónde están sus pruebas.

| # | Tarea | Documento | Pruebas y evidencias |
| --- | --- | --- | --- |
| 1 | Identificar y documentar el hardware necesario | [Fichas de hardware y software](docs/presupuesto/fichas_hw_sw.md) (apartados 1–7) | [Presupuesto en Excel](docs/presupuesto/presupuesto_local_plano.xlsx): 4.624,43 € + IVA = 5.595,56 €, con enlace de compra en cada fila |
| 2 | Identificar, documentar e instalar el software necesario | [Fichas, apartado 8](docs/presupuesto/fichas_hw_sw.md#8-software-todo-de-coste-0) | La instalación de cada programa está en la guía de su equipo (columna «Instalación» de esa tabla) |
| 3 | Web en AWS | [Guía de la web](docs/web/guia_web.md) · [Despliegue en AWS](docs/infra/despliegue_aws.md) | [Pruebas de la web](docs/web/guia_web.md#6-pruebas-y-evidencias) · [pruebas de AWS](docs/infra/despliegue_aws.md#6-pruebas-y-evidencias) |
| 4 | ERP + TPV | [ERP](erp/README.md) · [TPV](sistemas/tpv-barra/README.md) | [Pruebas del ERP](erp/README.md#pruebas) |
| 5 | Arcade stick con Arduino | [Arcade stick](arcade-stick/README.md) | [Pruebas](arcade-stick/README.md#7-pruebas) |
| 6 | Configurar una impresora | [TPV, impresora](sistemas/tpv-barra/README.md#impresora-de-tickets) | [Pruebas 5–8 del TPV](sistemas/tpv-barra/README.md#pruebas) |
| 7 | Instalación de SO con arranque dual | [Dual boot](sistemas/gerente-dualboot/README.md) | [Resultado final](sistemas/gerente-dualboot/README.md#9-resultado-final) |
| 8 | Elección de la conectividad WAN | [Línea WAN](redes/routers/wan/README.md) | [Comparativa (PDF)](docs/Comparativa%20y%20contratación%20de%20la%20línea%20WAN.pdf) |
| 9 | Diseño y esquema de conectividad | [Redes](redes/README.md) | [Packet Tracer](redes/packet-tracer/almichain.pkt) · [pruebas](redes/README.md#6-pruebas) |
| 10 | Ampliación de la cobertura Wi-Fi | [Repetidor](redes/routers/router-y-repetidor.md) | [Pruebas](redes/routers/router-y-repetidor.md#6-prueba-de-aislamiento) |
| 11 | Restricción de cuentas y equipos | [Gerente](sistemas/gerente-dualboot/README.md#11-seguridad-aplicada) · [TPV](sistemas/tpv-barra/README.md#mínimo-privilegio) · [recreativa](recreativa/README.md#6-seguridad-mínimos-privilegios) | [Mínimo privilegio en cada parte](docs/documento_final.md#142-mínimo-privilegio-en-cada-parte) |
| 12 | Optimizar y monitorizar la recreativa | [Recreativa](recreativa/README.md) | [Medidas](recreativa/medidas/resultados.md) |
| 13 | Plan de copias de seguridad | [Copias](backups/README.md) | [Pruebas 13–19](backups/README.md#3-pruebas) |
| 14 | Disco redundante | [Copias, RAID 1](backups/README.md#1-raid-1) | [Pruebas 11–12](backups/README.md#3-pruebas) |
| 15 | Diseño del modelo E/R y tablas | [Base de datos](bd/README.md) | [Diagrama E/R](bd/er-conceptual.png) · [modelo relacional](bd/02-modelo-relacional.pdf) · [requisitos](bd/00-requisitos.pdf) |
| 16 | Implementación de la base de datos | [Base de datos, orden de ejecución](bd/README.md) | [Scripts SQL](bd/scripts/Scripts_postgre) · [modelo físico](bd/er-fisico.png) · [capturas de las 11 consultas](bd/capturas) |

Resumen de todas las pruebas: [documento final, apartado 14](docs/documento_final.md#14-revisión-de-seguridad-y-pruebas). Validaciones del profesor: [`gestion/`](gestion/README.md#validaciones-del-profesor).

**Arquitectura:** [`docs/diagramas/esquema_definitivo.png`](docs/diagramas/esquema_definitivo.png) · **Planificación y anexos:** [`gestion/`](gestion)

Cada carpeta tiene su propio `README.md` con los pasos para reproducir esa parte desde cero.

## Cómo trabajamos

Ver [`CONTRIBUTING.md`](CONTRIBUTING.md): ramas, formato de commits y qué no se sube nunca (secretos, ISOs, discos de VM).
