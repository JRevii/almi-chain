# TPV de barra e impresora de tickets

Equipo de barra que solo sirve para cobrar: **Windows 10 Pro** con un usuario estándar, encerrado en un **quiosco de Edge** que abre el punto de venta de Odoo por HTTPS, con la impresora de tickets por USB.

Responsable: Iñigo (TPV) · Jon (impresora).

**La guía completa, paso a paso, está en [`tpv-quiosco.md`](tpv-quiosco.md):** máquina virtual, cuentas, certificado de la CA, modo quiosco, usuario cajero de Odoo, impresora, pruebas de restricción, riesgos y resumen para un técnico nuevo.

## Equipo del reto frente a la compra real

| | En el reto (VM del aula) | En la compra real ([presupuesto](../../docs/presupuesto/fichas_hw_sw.md)) |
| --- | --- | --- |
| TPV | **Una** VM con **Windows 10 Pro**; el segundo TPV sería un clon | 2 TPV todo en uno 10POS con **Windows 11 IoT Enterprise LTSC** |
| Impresora | **Samsung ML-2165** (láser A4, la disponible en el aula) | 2 **Epson TM-T20III** térmicas de 80 mm |

El usuario estándar, el quiosco, el certificado y la impresión se configuran igual en las dos versiones de Windows y con cualquier impresora instalada como predeterminada. El hardware y el software de la compra real, con precios, están en el [presupuesto](../../docs/presupuesto/fichas_hw_sw.md#2-tpv-de-barra-2).

## Mínimo privilegio

| Medida | Cómo | Detalle |
| --- | --- | --- |
| Usuario de Windows `tpv` | Cuenta local **estándar**, sin administrador | [`tpv-quiosco.md` §3](tpv-quiosco.md#3-cuentas) |
| Una sola aplicación | Acceso asignado (quiosco) con Edge a pantalla completa, sin barra de direcciones ni pestañas | [§5](tpv-quiosco.md#5-modo-quiosco) |
| Usuario de Odoo cajero | Solo *Punto de venta · Usuario*: no puede crear productos ni ver facturación | [§6](tpv-quiosco.md#6-odoo-usuario-del-cajero) |
| Drivers | Solo los instala el administrador, nunca `tpv` | [§7](tpv-quiosco.md#7-impresora) |
| Comunicaciones cifradas | Odoo por HTTPS con el certificado de nuestra CA instalado como de confianza | [§4](tpv-quiosco.md#4-certificado-de-la-ca) |
| Red | Cable a la red de empleados, nunca al Wi-Fi de clientes | [`../../redes/`](../../redes/) |

## Impresora de tickets

1. **USB a la VM:** con la VM apagada, *Configuración → USB*, controlador **USB 1.1 (OHCI)** y un filtro con la impresora. Con USB 3.0 Windows daba *Código 10* (ver [§7](tpv-quiosco.md#7-impresora)).
2. **Driver y predeterminada:** con la cuenta de administrador se instala el driver y se pone como **predeterminada**, desactivando que Windows la gestione. Papel: A4 con la ML-2165 del aula; 80 mm con la Epson térmica.
3. **Odoo:** *Punto de venta → Configuración → Ajustes → Facturas y recibos* → **Impresión automática del recibo**. Al validar el pago, Odoo lanza la impresión solo.
4. **Sin la ventana de imprimir (pendiente):** Odoo Community sin *IoT Box* imprime a través del navegador, y el navegador muestra su diálogo. Edge lo omite si se abre con `--kiosk-printing`, que envía el ticket directo a la impresora predeterminada:
   ```
   "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --kiosk https://192.168.1.50/pos/ui/2 --edge-kiosk-type=fullscreen --kiosk-printing
   ```
   **Ojo:** con el *Acceso asignado* de Windows, es Windows quien arranca Edge con sus propios parámetros, así que este acceso directo no sirve tal cual. Hay que probarlo primero fuera del quiosco y después buscar cómo pasarle el parámetro dentro.
5. **Ticket de prueba de la impresora:** [`impresion_prueba_almichain_80mm.pdf`](impresion_prueba_almichain_80mm.pdf), con tildes, ñ, € y código de barras. Se imprime a tamaño real (100 %).

## Pruebas

| # | Prueba | Resultado esperado | Estado | Evidencia |
| --- | --- | --- | --- | --- |
| 1 | IP fija del TPV | `10.13.10.21` en la red de empleados | ✅ | [captura](capturas/03-ip-fija.png) |
| 2 | Entrar con `tpv` | Edge se abre solo en el punto de venta, a pantalla completa | ✅ | [captura](capturas/07-quiosco-edge.png) · [plano de mesas](capturas/06-acceso-asignado.png) |
| 3 | Odoo por HTTPS desde el TPV | Sin aviso de certificado | ✅ | [captura](capturas/05-certificado-confianza.png) |
| 4 | Pruebas de restricción (tecla Windows, Alt+Tab, Alt+F4, Ctrl+Shift+Esc…) | No se puede salir del quiosco | ⏳ tabla por rellenar en [§8](tpv-quiosco.md#8-pruebas-de-restricción) | — |
| 5 | Impresora reconocida en la VM | Aparece en el Administrador de dispositivos | ✅ | [captura](capturas/09c-administrador-dispositivos.png) |
| 6 | **Venta en el TPV → ticket impreso** | El ticket sale por la impresora | ✅ 27/10, con el diálogo de imprimir de por medio | [vídeo](capturas/imp_01_venta_e_impresion.mp4) · [diálogo](capturas/21-odoo-prueba-ticket.png) |
| 7 | Ticket de prueba desde Windows | Se leen las tildes, el € y el código de barras | ⏳ | — |
| 8 | **Venta → ticket automático** | Sale solo al validar, sin ventana de imprimir | ⏳ ver el paso 4 de la impresora | — |

## Capturas

| Captura | Qué muestra |
| --- | --- |
| [01](capturas/01-vm-virtualbox.png) · [02](capturas/02-vm-virtualbox.png) · [03](capturas/03-vm-virtualbox.png) | Configuración de la VM en VirtualBox |
| [02-windows-10-pro](capturas/02-windows-10-pro.png) | Edición de Windows |
| [03-ip-fija](capturas/03-ip-fija.png) | `ipconfig` con la IP del plano |
| [04-usuario-estandar](capturas/04-usuario-estandar.png) | Cuenta `tpv` estándar |
| [05-certificado-confianza](capturas/05-certificado-confianza.png) · [13-certificado-detalles](capturas/13-certificado-detalles.png) | CA instalada como de confianza |
| [06-acceso-asignado(quiosco)](<capturas/06-acceso-asignado(quiosco).png>) | Configuración del acceso asignado |
| [06-acceso-asignado](capturas/06-acceso-asignado.png) · [07-quiosco-edge](capturas/07-quiosco-edge.png) | El quiosco abierto en el punto de venta |
| [09-quiosco-navega-enlaces](capturas/09-quiosco-navega-enlaces.png) | Prueba inicial: el quiosco seguía enlaces externos (ver riesgos en [§9](tpv-quiosco.md#9-riesgos-y-desviaciones)) |
| [09c-administrador-dispositivos](capturas/09c-administrador-dispositivos.png) | Impresora USB en el Administrador de dispositivos |
| [16-odoo-restaurante-activado](capturas/16-odoo-restaurante-activado.png) | Módulo Restaurante instalado en Odoo |
| [18-odoo-usuario-cajero](capturas/18-odoo-usuario-cajero.png) | Usuario cajero con permisos solo de punto de venta |
| [19-odoo-tpv-cajero](capturas/19-odoo-tpv-cajero.png) · [20-odoo-prueba-pedido](capturas/20-odoo-prueba-pedido.png) | Plano de mesas y pedido de prueba |
| [21-odoo-prueba-ticket](capturas/21-odoo-prueba-ticket.png) | Diálogo de impresión del ticket |
| [imp_01_venta_e_impresion](capturas/imp_01_venta_e_impresion.mp4) | Vídeo: venta, pago, diálogo de impresión y ticket impreso |
