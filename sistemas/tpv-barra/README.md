# TPV de barra e impresoras de tickets

Hardware, software y presupuesto de los 2 TPV Windows; cuentas restringidas (mínimos privilegios) e instalación de la impresora de tickets.

## Pasos para reproducir

_Pendiente._

## Impresora de tickets: impresión automática (Jon)

Objetivo: al cobrar en el TPV, el ticket sale solo por la impresora térmica, sin que el camarero pulse nada.

1. **Impresora:** por USB al PC que ejecuta la VM del TPV. En VirtualBox (con la VM apagada): *Configuración → USB*, controlador USB 2.0 o 3.0 y un **filtro** con la impresora, para que pase sola a la VM. En Windows, instalar el driver **con la cuenta de administrador** (el usuario de la barra no tiene permisos), ponerla como **predeterminada**, papel de **80 mm** y márgenes mínimos.
2. **Odoo:** *Punto de venta → Configuración → Ajustes → Facturas y recibos* → **Impresión automática del recibo** y encabezado y pie personalizados.
3. **Navegador sin diálogo de imprimir:** Odoo Community sin *IoT Box* imprime a través del navegador. Para que no salga la ventana de "Imprimir", Edge se abre con `--kiosk-printing`, que envía el ticket directamente a la impresora predeterminada. Acceso directo para el usuario de la barra, al iniciar sesión:
   ```
   "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" --kiosk https://odoo.almichain.lan/pos/ui --edge-kiosk-type=fullscreen --kiosk-printing
   ```
4. **Ticket de prueba de la impresora:** [`impresion_prueba_almichain_80mm.pdf`](impresion_prueba_almichain_80mm.pdf), con caracteres especiales (tildes, ñ y €), alineación y código de barras. Se imprime a tamaño real (100 %).

| Prueba | Resultado esperado | Estado | Evidencia |
| --- | --- | --- | --- |
| Ticket de prueba desde Windows | Se leen las tildes, el € y el código de barras | ⏳ | `capturas/imp_ticket_prueba.jpg` |
| Venta en el TPV → ticket automático | El ticket sale solo al validar el pago | ⏳ | `capturas/imp_ticket_odoo.jpg` |

