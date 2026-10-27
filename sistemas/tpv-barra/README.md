# TPV de barra e impresoras de tickets

Hardware, software y presupuesto de los 2 TPV Windows; cuentas restringidas (mínimos privilegios) e instalación de la impresora de tickets.

> **Sistema y equipos del reto frente a la compra real**
>
> | | En el reto (VM del aula) | En la compra real ([presupuesto](../../docs/presupuesto/fichas_hw_sw.md)) |
> | --- | --- | --- |
> | TPV | **Una** VM con **Windows 10 Pro**; el segundo TPV sería un clon | 2 TPV todo en uno 10POS con **Windows 11 IoT Enterprise LTSC** |
> | Impresora | **Samsung ML-2165** (láser, la disponible en el aula) | 2 **Epson TM-T20III** térmicas de 80 mm |
>
> El usuario estándar, el modo quiosco, el certificado y la impresión automática se configuran igual en las dos versiones de Windows y con cualquier impresora instalada como predeterminada.

Pasos para reproducir

1. Arrancar la máquina virtual del TPV.
2. Conectar la impresora Samsung ML-2165 mediante USB.
3. Verificar que Windows detecta la impresora.
4. Abrir Odoo.
5. Acceder al módulo Punto de Venta.
6. Realizar una venta de prueba.
7. Validar el pago.
8. Comprobar la impresión del ticket.

## Impresora de tickets: impresión automática (Jon)

Objetivo: al cobrar en el TPV, el ticket sale solo por la impresora predeterminada, sin que el camarero pulse nada.

1. **Impresora:** por USB al PC que ejecuta la VM del TPV. En VirtualBox (con la VM apagada): *Configuración → USB*, controlador USB 2.0 o 3.0 y un **filtro** con la impresora, para que pase sola a la VM. En Windows, instalar el driver **con la cuenta de administrador** (el usuario de la barra no tiene permisos), ponerla como **predeterminada** y márgenes mínimos (con la Epson térmica, papel de **80 mm**; con la ML-2165 del aula, A4).
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

Resultado
La impresora Samsung ML-2165 ha quedado operativa dentro de la máquina virtual del TPV.

Se verificó:

Reconocimiento USB en VirtualBox.
Instalación correcta del controlador.
Impresión desde Windows.
Impresión desde Odoo TPV.
La impresión de tickets funciona correctamente.

