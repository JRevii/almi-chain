# Router y repetidor Wi-Fi

Responsables: Iñigo y Yeray. Estado: repetidor conectado, pruebas hechas.

## 1. Objetivo

Ampliar la Wi-Fi de clientes del local con un segundo aparato, manteniendo a los clientes aislados de los equipos de la empresa.

## 2. Decisión: repetidor en lugar de WDS

El reto pedía un segundo router enlazado por WDS. El segundo aparato es un TP-Link TL-WR841N v14 (firmware 0.9.1 4.16 v0001.0 Build 180319) y su panel no tiene WDS: ofrece los modos Wireless Router, WISP, Access Point y Range Extender, y en Wireless solo hay Basic Settings, WPS, Wireless Security, MAC Filtering, Wireless Advanced y Wireless Statistics. Se consultó al profesor, que indicó que el aparato hiciera de repetidor.

![Modos disponibles](capturas/02-router2-modos.png)
![Firmware](capturas/03-router2-firmware.png)
![Sin opción WDS](capturas/04-router2-sin-wds.png)

## 3. Router: red de clientes

El router es otro TL-WR841N con la Wi-Fi principal `Almi-cadena`, en el canal 6 fijo y modo 11bgn mixed. Su red de clientes (Guest Network) estaba desactivada, con el nombre de fábrica y sin cifrado. Se activó con el nombre `TP-Link-Revi` y una clave generada en KeePassXC, que no se escribe aquí. Antes de activarla, la opción "Allow Guests To Access My Local Network" estaba en Disable, que es el valor que aísla a los clientes de la red local, y se mantuvo.

## 4. Repetidor

Se configuró con Quick Setup, Range Extender: el repetidor escanea las redes, se conecta a `TP-Link-Revi` con su clave y repite la señal. Al escanear salen muchas redes de otros grupos con nombres parecidos, así que se comprobó que la elegida es la del router: su BSSID empieza por `50:D4:F7:3D:9A`, que es la MAC de la etiqueta del router. Para un técnico nuevo: no elegir nunca una red solo por el nombre.

Estado final: modo Range Extender, radio activada, canal 6 (el mismo que el router), MAC LAN C0:C9:E3:B3:9B:BA e IP 192.168.1.136 recibida por DHCP.

![Redes encontradas en el escaneo](capturas/06-repetidor-redes.png)

## 5. Seguridad

- WPS desactivado en el repetidor.
- La clave de la red de clientes está solo en KeePassXC.

![WPS desactivado](capturas/05-router2-wps-desactivado.png)

## 6. Incidencias

- **Error 80002 (Unknown error)** al guardar la red de clientes desde el móvil: al guardar, la Wi-Fi se reinicia y se corta la conexión con el panel. El cambio sí se aplicó. Solución: volver a entrar y comprobar. Recomendación: configurar por cable.
- Conectar el móvil al repetidor falló al principio por escribir mal la clave. La clave de la Wi-Fi no es la de administrador del panel.

## 7. Pruebas

Pendientes de realizar: conexión y ping desde el móvil, velocidad con y sin repetidor, cobertura y aislamiento (un móvil conectado al repetidor no debe llegar a los equipos de la LAN del router). Los resultados se añadirán a esta guía con sus capturas.

## 8. Riesgos y desviaciones

- No hay WDS: se usa repetidor.
- El repetidor tiene firmware de 2018, sin parches de seguridad.
- El nombre de la red de clientes no es el del plano (`AlmiChain-Clientes`).
- El repetidor tiene una IP del rango 192.168.1.x, distinto del plano (10.13.10.x).
- Canal 6 compartido con redes de otros grupos, lo que puede bajar la velocidad.
- Sin la prueba de aislamiento no se puede afirmar que el repetidor mantenga a los clientes separados de los equipos.

## 9. Cómo repetirlo

1. En el router, activar la red de clientes con cifrado WPA2, clave generada y acceso a la red local desactivado. Configurar por cable.
2. En el repetidor, Quick Setup, Range Extender, elegir esa red comprobando que el BSSID es el del router, y escribir su clave.
3. Cambiar la contraseña de administrador del repetidor y desactivar WPS.
4. Hacer las pruebas y guardar las capturas.

Prueba de aislamiento del repetidor:

Dispositivo conectado correctamente al repetidor.
Acceso a Internet verificado.
Ping a equipo de la LAN (192.168.1.175) fallido.
Se confirma que los clientes del repetidor no tienen acceso a la red interna.

| Captura | Qué muestra |
| --- | --- |
| [07-movil-conectado-repetidor](capturas/07-movil-conectado-repetidor.jpg) | Móvil conectado a `TP-Link-Revi` |
| [08-ping-desde-repetidor](capturas/08-ping-desde-repetidor.jpg) | Pruebas de conexión desde el móvil a `192.168.1.175` |
| [09-internet-desde-repetidor](capturas/09-internet-desde-repetidor.jpg) | Navegación a internet desde el repetidor |

