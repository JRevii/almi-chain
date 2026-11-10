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

**Arquitectura:** [`docs/diagramas/esquema_definitivo.png`](docs/diagramas/esquema_definitivo.png) · **Planificación y anexos:** [`gestion/`](gestion)

Cada carpeta tiene su propio `README.md` con los pasos para reproducir esa parte desde cero.

## Cómo trabajamos

Ver [`CONTRIBUTING.md`](CONTRIBUTING.md): ramas, formato de commits y qué no se sube nunca (secretos, ISOs, discos de VM).
