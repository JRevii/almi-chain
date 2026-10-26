# Digitalización del restaurante

| Responsable | Fechas (Gantt) | Carpeta en el repo |
|---|---|---|
| Jose | 5/11 – 9/11 | `docs/` |

## 1. Qué es la digitalización

**Digitalizar** una empresa no es solo usar ordenadores. Es cambiar la forma de trabajar gracias a la tecnología, para hacerlo más rápido, con menos errores y llegando a más clientes.

Las **tecnologías habilitadoras digitales** son las que hacen posible ese cambio: la nube, el IoT, la ciberseguridad, los sistemas de gestión (ERP), el análisis de datos o la inteligencia artificial.

## 2. Cómo trabajaba el restaurante antes

Sin el sistema que proponemos, el restaurante funcionaría así:

- **Cobro:** el camarero apunta la comanda en papel, suma la cuenta a mano o con una caja registradora y cobra con el datáfono o en efectivo, según el cliente. Es lento y es fácil equivocarse al sumar o dejarse algo sin cobrar.
- **Control del negocio:** el gerente revisa el inventario contando a mano lo que hay en el almacén y junta los tickets del día para saber cuánto se ha vendido. Le lleva tiempo, la información llega tarde y no sabe con facilidad qué plato se vende más o cuándo hay que pedir género.
- **Clientes nuevos:** el restaurante solo se da a conocer por el boca a boca o pagando publicidad (carteles, folletos, prensa). Sin web, quien busca dónde comer en internet no lo encuentra.

Además, toda la información está en papel o en un solo sitio: si se pierde o se estropea, no hay copia.

## 3. Tecnologías habilitadoras del proyecto

| Tecnología | Dónde está en el proyecto | Problema que resuelve |
|---|---|---|
| Sistema de gestión (ERP) | Odoo con su TPV | Cobro lento, inventario a mano |
| Datos | PostgreSQL, consultas de la BD | No saber qué se vende ni cuándo pedir |
| Nube | Web en AWS | Sin web, los clientes no te encuentran |
| IoT / sistemas embebidos | Arduino del arcade stick | Ocio para clientes, mando personalizable |
| Ciberseguridad | HTTPS, cortafuegos, usuarios sin permisos, copias | Pérdida o robo de la información |

**ERP (Odoo).** Es un solo programa para cobrar, facturar, controlar el almacén, el personal y los clientes. El camarero cobra en el TPV táctil, la factura sale automáticamente por la impresora de tickets y **el inventario se descuenta solo** con cada venta. El gerente ya no tiene que contar a mano: ve el stock al momento y sabe cuándo pedir.

**Datos (PostgreSQL).** Todo lo que se vende queda guardado en la base de datos. Con consultas se puede saber qué plato se vende más, qué día hay más clientes o qué local factura más, y tomar decisiones con datos reales en vez de a ojo.

**Nube (AWS).** La web está en un servidor de Amazon, disponible las 24 horas aunque pase algo en el local, sin comprar ni mantener un servidor propio (unos 10 € al mes). Muestra la carta, los platos y dónde están los locales con un mapa, así que el restaurante se da a conocer sin pagar publicidad.

**IoT y sistemas embebidos (Arduino).** El arcade stick de la recreativa lleva un Arduino Leonardo que el ordenador reconoce como un teclado. Es un pequeño ejemplo de cómo un aparato físico se conecta y se programa para hacer lo que necesita el negocio: aquí, ofrecer ocio a los clientes mientras esperan.

**Ciberseguridad.** Al digitalizar, la información pasa a ser lo más valioso del restaurante. Por eso la web va por HTTPS, el servidor tiene cortafuegos, los TPV y el gerente usan cuentas sin permisos de administrador, los discos están en espejo (RAID 1) y se hacen copias de seguridad cifradas.

## 4. Cómo cambia el restaurante

**Para el cliente**
- **Menos espera y mejor servicio:** el camarero cobra en el TPV táctil y el ticket sale solo, así que se atiende con más agilidad.
- **Sin sorpresas al pedir:** como el stock está actualizado al momento, el camarero sabe si un plato se ha acabado antes de que el cliente lo pida.
- **Encuentra el restaurante en internet:** desde la web ve la carta, los platos y cómo llegar con el mapa, en el móvil o en el ordenador.
- **Ocio mientras espera:** la máquina recreativa.

**Para el negocio**
- **Menos errores** al cobrar y facturar, porque el cálculo lo hace el programa.
- **Ahorro de tiempo:** nadie cuenta el inventario ni junta tickets a mano.
- **Decisiones con datos:** qué plato funciona, cuándo pedir género o qué local va mejor.
- **Publicidad más barata:** la web da a conocer el restaurante sin pagar anuncios.
- **La información no se pierde:** está en el servidor, en dos discos y con copias.

## 5. Riesgos y cómo los cubrimos

Al digitalizar, el restaurante depende de la tecnología. Si algo falla, puede quedarse sin cobrar o perder información. Estos son los riesgos y lo que hemos montado contra cada uno:

| Riesgo | Qué pasaría | Cómo lo cubrimos |
|---|---|---|
| Se rompe un disco del servidor | Se perderían los datos de Odoo | **RAID 1:** el otro disco tiene lo mismo y todo sigue funcionando |
| Se borra algo por error, o un virus cifra los datos | El RAID copia también el error a los dos discos | **Copias de seguridad** cifradas en otro disco, con restauración probada |
| Se rompe el servidor entero | Los TPV no pueden registrar ventas en Odoo hasta repararlo | Se restaura la última copia en otro equipo; el servidor es profesional y tiene **SAI** contra cortes de luz |
| Alguien entra sin permiso | Robo de datos de clientes o manipulación de cobros | Cuentas **sin permisos de administrador**, TPV en modo quiosco, cortafuegos, SSH solo con claves y Wi-Fi de clientes separado |
| Se cae el local o internet | — | La **web sigue funcionando** porque está en la nube |
| Contraseñas filtradas | Acceso a todo el sistema | Gestor de contraseñas **KeePassXC**; nunca se suben a GitHub |

## 6. Conclusión

Al restaurante le conviene digitalizarse por tres motivos. Primero, **agiliza los procesos**: se cobra antes, se controla el stock al momento y eso **mejora el servicio** al cliente. Segundo, **está protegido ante imprevistos**: con el RAID, las copias de seguridad y el SAI, una avería o un corte de luz no le hacen perder la información. Y tercero, **no se queda anticuado**: con una web en la nube y un sistema de gestión moderno puede competir con otros restaurantes y llegar a clientes nuevos.

Todo esto con una inversión moderada y con software libre, sin pagar licencias.
