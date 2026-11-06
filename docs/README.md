# Documentación

Documento final del reto y diagramas de arquitectura (en `diagramas/`).

| Documento | Contenido |
| --- | --- |
| [`documento_final.md`](documento_final.md) | Documento final del reto: índice y esqueleto que enlaza la guía de cada parte |
| [`diagramas/esquema_definitivo.png`](diagramas/esquema_definitivo.png) | Esquema de la arquitectura completa |
| [`diagramas/reparto_y_gantt.png`](diagramas/reparto_y_gantt.png) | Reparto de tareas y Gantt |
| [`Comparativa y contratación de la línea WAN.pdf`](<Comparativa y contratación de la línea WAN.pdf>) | Comparativa de fibra y elección de la línea WAN |
| [`infra/despliegue_aws.md`](infra/despliegue_aws.md) | Web en AWS con Terraform, Nginx, DuckDNS y HTTPS |
| [`bocetos/bocetos.md`](bocetos/bocetos.md) | Bocetos de la web (diseño conceptual) y PDF con las opciones valoradas |
| [`web/guia_web.md`](web/guia_web.md) | Diseño, código y pruebas de la web |
| [`necesidades/necesidades-comunicacion.md`](necesidades/necesidades-comunicacion.md) | Inventario, redes y tráfico del local |
| [`presupuesto/fichas_hw_sw.md`](presupuesto/fichas_hw_sw.md) | Fichas de hardware y software de un local |
| [`presupuesto/presupuesto_local_plano.xlsx`](presupuesto/presupuesto_local_plano.xlsx) | Presupuesto de un local según el plano de cableado y Wi-Fi |
| [`digitalizacion/digitalizacion.md`](digitalizacion/digitalizacion.md) | Tecnologías habilitadoras digitales, comparativa de alternativas y cómo transforman el restaurante |

## Pasos para reproducir

Orden para montar todo desde cero. Cada guía es independiente y explica sus pasos, comandos y pruebas.

1. **Red:** diseño y direccionamiento en [`../redes/README.md`](../redes/README.md). Routers del aula en [`../redes/routers/repetidor/repetidor-wifi.md`](../redes/routers/repetidor/repetidor-wifi.md).
2. **Servidor (Odoo, PostgreSQL y HTTPS):** scripts `01` a `04` de [`../erp/README.md`](../erp/README.md).
3. **RAID y copias:** script `05` y pruebas en [`../backups/README.md`](../backups/README.md). Copia en S3 con [`../infra/terraform-copias/README.md`](../infra/terraform-copias/README.md).
4. **Base de datos del local:** scripts `00` a `05`, en orden, desde [`../bd/README.md`](../bd/README.md).
5. **Configuración de Odoo:** impuestos, carta, usuarios por rol, CRM y Marketing en [`../erp/README.md`](../erp/README.md).
6. **TPV e impresora:** [`../sistemas/tpv-barra/tpv-quiosco.md`](../sistemas/tpv-barra/tpv-quiosco.md), con el servidor ya funcionando.
7. **Equipo del gerente:** [`../sistemas/gerente-dualboot/README.md`](../sistemas/gerente-dualboot/README.md).
8. **Recreativa y arcade stick:** [`../recreativa/README.md`](../recreativa/README.md) y [`../arcade-stick/README.md`](../arcade-stick/README.md).
9. **Web en AWS:** `terraform apply` siguiendo [`infra/despliegue_aws.md`](infra/despliegue_aws.md).

Las contraseñas y claves no están en el repositorio: se generan al instalar y se guardan en KeePassXC.

### Leer y exportar la documentación

1. Abrir [`documento_final.md`](documento_final.md) en GitHub. Es el documento principal, con un resumen de cada parte.
2. Cada apartado enlaza la guía de su carpeta (web, red, ERP, base de datos…), donde están los pasos para montarlo y las capturas.
3. Para entregarlo en Word o PDF, dentro de la carpeta `docs/`: `pandoc documento_final.md -o documento_final.docx`.
4. Los diagramas se editan con draw.io y se exportan en PNG a [`diagramas/`](diagramas).
