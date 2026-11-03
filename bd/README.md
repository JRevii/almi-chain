# Base de datos de los locales (carpeta `bd/`)

Base de datos PostgreSQL de la cadena de restaurantes Almi-Chain: locales, mesas, empleados, platos, ingredientes, proveedores, clientes, ventas, inventario y reservas. Convive con Odoo (ver [Relación con Odoo](#relación-con-odoo)).

- **Gestor:** PostgreSQL 16
- **Herramienta gráfica usada para el diseño físico:** pgAdmin 4
- **Normalización:** 3FN (justificada en el documento del modelo relacional)

## Contenido de la carpeta

Los scripts `.sql` están en `scripts/Scripts_postgre/`.

| Fichero | Qué es | Quién lo ejecuta |
|---|---|---|
| `00_reset.sql` | Borra las 14 tablas **y sus datos**. Solo para desarrollo y pruebas | `almichain_owner` |
| `01_roles_y_bd.sql` | Crea el rol dueño y la base de datos | Administrador (`postgres`) |
| `02_tablas.sql` | Crea las 14 tablas con claves primarias, claves externas y restricciones (DDL) | `almichain_owner` |
| `03_permisos.sql` | Crea el rol de uso diario y le da solo permisos de datos | Administrador (`postgres`) |
| `04_datos.sql` | Datos de ejemplo (ficticios). **Vacía las tablas al empezar** | `almichain_owner` |
| `05_consultas.sql` | Las 9 consultas útiles para el restaurante | `almichain_app` |
| `er-conceptual.png`, `er-fisico.png`, `er-entidades-relaciones.drawio` | Diagramas del modelo (E/R conceptual y modelo físico) | |

Documentación asociada (en esta misma carpeta): requisitos, atributos y claves, modelo relacional con la normalización y capturas de las pruebas (`capturas/`).

## Orden de ejecución

Desde la carpeta donde están los scripts. Las contraseñas **no están en ningún fichero**: se asignan a mano con `\password` y se guardan en un gestor de contraseñas.

```bash
# 1. Rol dueño y base de datos
sudo -u postgres psql < 01_roles_y_bd.sql
sudo -u postgres psql -c "\password almichain_owner"

# 2. Tablas
psql -h localhost -U almichain_owner -d almichain -f 02_tablas.sql

# 3. Rol de uso diario y permisos
sudo -u postgres psql -d almichain < 03_permisos.sql
sudo -u postgres psql -c "\password almichain_app"

# 4. Datos de ejemplo
psql -v ON_ERROR_STOP=1 -h localhost -U almichain_owner -d almichain -f 04_datos.sql

# 5. Consultas
psql -h localhost -U almichain_app -d almichain -f 05_consultas.sql
```

Comprobación rápida (con `almichain_app`): `SELECT count(*) FROM lineas_ventas;` debe devolver **32**.

Para repetir todo desde cero: `00_reset.sql`, `02_tablas.sql`, `03_permisos.sql` (`DROP TABLE` elimina también los permisos; el aviso `role "almichain_app" already exists` es inofensivo y los `GRANT` sí se aplican) y `04_datos.sql`.

> Los nombres `almichain`, `almichain_owner` y `almichain_app` son los del entorno de pruebas. Si en otro servidor cambian, basta con sustituirlos en los scripts.

## Seguridad (mínimo privilegio)

- **Dos roles.** `almichain_owner` es dueño de las tablas y solo se usa para modificar la estructura. `almichain_app` solo puede `SELECT`, `INSERT`, `UPDATE` y `DELETE`.
- **Sin superusuario** ni permisos de crear bases de datos o roles en ninguno de los dos.
- **Acceso cerrado por defecto:** `REVOKE ALL ... FROM PUBLIC` sobre la base de datos; solo entran los roles autorizados.
- **Prueba:** con `almichain_app`, la lectura funciona y `DROP TABLE` / `CREATE TABLE` fallan (`must be owner of table`, `permission denied for schema public`).
- **Conexiones cifradas:** `psql` negocia TLS 1.3 al conectar por `localhost`.
- **Sin secretos en el repositorio:** ni contraseñas ni claves.

## Modelo de datos

14 tablas:

- **Propias:** `locales`, `mesas`, `categorias`, `proveedores`.
- **Espejo de Odoo** (llevan `odoo_id`): `platos`, `productos`, `clientes`, `empleados`, `ventas`, `lineas_ventas`.
- **Relaciones N:M** (PK compuesta): `recetas`, `suministras`, `inventarios`, `reservas`.

Decisiones de diseño que cumplen la 3FN:

- `ventas` no guarda el local (se deduce por la mesa) ni el total (se calcula con `SUM(cantidad * precio_unitario)` de sus líneas).
- `lineas_ventas.precio_unitario` guarda el precio **en el momento de la venta**, distinto del precio actual del plato.
- `UNIQUE (local_id, numero)` en `mesas`: el número no se repite dentro del mismo local. La barra de cada local es la mesa 0.
- `UNIQUE (mesa_id, fecha, hora)` en `reservas`: una mesa no se puede reservar dos veces a la misma hora.
- `stock_minimo` está en `inventarios` (varía por local) y no en `productos`.

Diagramas:

![Modelo E/R conceptual](er-conceptual.png)

![Modelo físico generado desde pgAdmin](er-fisico.png)

## Relación con Odoo

Odoo y esta base de datos son **dos bases de datos separadas**. Odoo gestiona facturación, CRM, empleados, inventario, marketing y TPV; esta base de datos añade lo que Odoo no tiene en su configuración (locales, mesas, reservas, recetas, proveedores y el stock mínimo por local).

La unión es la columna `odoo_id` de las tablas espejo: guarda el identificador numérico que ese elemento tiene en Odoo (`UNIQUE NOT NULL`). Las tablas propias se enlazan con ellas mediante claves externas normales, y así PostgreSQL puede comprobar la integridad.

- Los `odoo_id` de platos, ingredientes, clientes y empleados son los reales de Odoo, obtenidos exportando el campo *ID* en CSV.
- Los de `ventas` y `lineas_ventas` son ficticios: todavía no hay ventas reales en Odoo.
- **Es una conexión por diseño y por carga de datos, no una integración en vivo.** Si un precio cambia en Odoo, esta base de datos no se entera hasta que se vuelvan a cargar los datos. En un entorno real habría que automatizarlo (un script programado o la API de Odoo).

## Consultas

Resultados esperados con los datos de ejemplo:

| # | Consulta | Resultado esperado |
|---|---|---|
| 1 | Ventas e ingresos por local y día | 9 filas. El 1 de octubre en Almi Centro: 2 ventas y 89,00 |
| 2 | Platos más vendidos | Caña de cerveza 18, Tortilla 9, Bacalao 8 |
| 3 | Ingresos por plato | Bacalao 145,00, Tortilla 70,50, Arroz meloso 69,00... Café 9,00 |
| 4 | Ventas e ingresos por mes | Septiembre: 3 ventas, 138,20. Octubre: 7 ventas, 272,90 |
| 5 | Empleados por local | Almi Centro 3, Almi Casco Viejo 2 |
| 6 | Ventas e ingresos de cada empleado | Jon 149,00, Maite 106,80, Unai 83,70, Ainhoa 71,60, Iker 0 |
| 7 | Productos con poco stock | 5 filas |
| 8 | Proveedores de un producto | Aceite de oliva: 2 proveedores |
| 9 | Stock de un producto por local | Bacalao: Almi Centro 3,00 y Almi Casco Viejo 6,00 |

Capturas de ejemplo:

![Consulta 1: ventas por local y día](capturas/consulta-01.png)

![Consulta 6: ventas por empleado](capturas/consulta-06.png)

![Consulta 7: productos con poco stock](capturas/consulta-07.png)

## Documentación

- [Requisitos](00-requisitos.pdf)
- [Atributos y claves](01-atributos-claves.pdf)
- [Modelo relacional y normalización](02-modelo-relacional.pdf)
