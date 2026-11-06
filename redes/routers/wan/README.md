# Línea WAN: comparativa y elección

Responsable: Yeray. Comparativa de ofertas de fibra para empresa y elección de la línea del local. El documento completo está en [`Comparativa y contratación de la línea WAN.pdf`](<../../../docs/Comparativa y contratación de la línea WAN.pdf>), y el diseño de la red en [`../../README.md`](../../README.md).

## Elección

**Vodafone Empresas, fibra 1 Gb simétrica**, según la propuesta de Yeray al equipo ([captura](capturas/17_wan_mensaje_jose.png)):

| Concepto | Valor |
| --- | --- |
| Cuota | 20,66 €/mes sin IVA los 12 primeros meses; después, 28,93 €/mes sin IVA |
| Instalación | Sin coste |
| Router | Wi-Fi 6 incluido |
| Permanencia | **12 meses**. Si se da de baja antes, penalización proporcional al tiempo que falte ([Selectra](https://selectra.es/internet-telefono/companias/oferta-internet/vodafone/vodafone-fibra-1-gb-para-empresas) y [Comparaiso](https://comparaiso.es/ofertas/internet/vodafone/vodafone-fibra-1-gb-para-empresas), consultado el 06/11/2026) |
| IP fija | Es un servicio aparte de pago. **No se contrata, porque no hace falta:** la web está en AWS, la copia remota sale del local hacia S3 y no se administra nada desde fuera. Ningún servicio del local se ofrece a internet |

## Comparativa

![Tabla comparativa](capturas/16_wan_tabla.png)

| Captura | Qué muestra |
| --- | --- |
| [13_wan_movistar](capturas/13_wan_movistar.png) | Oferta de Movistar Empresas |
| [14_wan_vodafone](capturas/14_wan_vodafone.png) | Oferta de Vodafone Empresas |
| [15_wan_masmovil](capturas/15_wan_masmovil.png) | Oferta de MásMóvil Empresas |
| [16_wan_tabla](capturas/16_wan_tabla.png) | Tabla comparativa de las tres |
| [17_wan_mensaje_jose](capturas/17_wan_mensaje_jose.png) | Elección comunicada al equipo para el presupuesto |

## Por qué Vodafone

| Necesidad del restaurante | Cómo la cubre la línea |
| --- | --- |
| TPV y servidor de Odoo | Funcionan dentro del local, así que una caída de la fibra no deja sin cobrar. La línea solo se usa para salir a internet |
| Copia remota en AWS S3 cada noche | 1 Gb **simétrico**: la subida es igual de rápida que la bajada, y subir las copias a la nube no satura la línea |
| Wi-Fi de clientes en hora punta | 1 Gb de sobra para muchos móviles a la vez navegando |
| Coste | El primer año, casi igual que MásMóvil (25 € frente a 24,80 €/mes). A partir del mes 13, **la más barata**: 35 €/mes con IVA (28,93 € sin IVA), frente a 38 € de MásMóvil y 46,20 € de Movistar. Además, la instalación no cuesta nada y el router Wi-Fi 6 va incluido |

La permanencia de 12 meses no es un problema para un local que abre para quedarse. Movistar no tiene permanencia, pero cuesta bastante más cada mes.

Nunca se suben contraseñas ni la copia de configuración del router (`.bin`, `.cfg`): llevan la contraseña de administración y la clave del Wi-Fi.
