# Almi-Chain · Reto 1 ASIR1 (2026-2027)

Proyecto en equipo del Centro de Estudios ALMI: infraestructura informática completa para una cadena de restaurantes (equipos, red, web en la nube, ERP, base de datos y copias de seguridad).

**Equipo:** Sendoa · Jon · Jose · Iñigo · Yeray · Alejandro

## Estructura del repositorio

| Carpeta | Contenido | Tarea del reto |
| --- | --- | --- |
| `docs/` | Documentación general y diagramas de arquitectura | Documentación reproducible |
| `gestion/` | Anexos (I, II, IX), Gantt/Kanban, actas | Seguimiento del trabajo |
| `sistemas/gerente-dualboot/` | Equipo del gerente: Windows 10 + GNU/Linux | Implantación de SO |
| `sistemas/tpv-barra/` | 2 TPV Windows + impresoras de tickets, hardening y mínimos privilegios | Equipos, permisos, impresora |
| `recreativa/` | VM con MAME optimizada (1 núcleo, 1 GB RAM) y pruebas de rendimiento | Máquina recreativa |
| `arcade-stick/` | Código Arduino y montaje del arcade stick | Arcade stick |
| `redes/` | Línea WAN, plano de red, Wi-Fi, WDS, Packet Tracer | Conectividad |
| `web/` | Web estática responsiva y accesible | Página web |
| `infra/terraform/` | Despliegue en AWS (EC2/S3), Nginx + HTTPS, DuckDNS | Hosting reproducible |
| `erp/` | ERP + TPV y caso de uso automatizado (emisión de factura) | ERP |
| `bd/` | Modelo E/R, modelo relacional y scripts SQL | Base de datos |
| `backups/` | Disco redundante (RAID), plan de copias y prueba de restauración | Copias de seguridad |

Cada carpeta tiene su propio `README.md` con los pasos para reproducir esa parte desde cero.

## Cómo trabajamos

Ver [`CONTRIBUTING.md`](CONTRIBUTING.md): ramas, formato de commits y qué no se sube nunca (secretos, ISOs, discos de VM).
