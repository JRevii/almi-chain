-- 04_datos.sql: datos de ejemplo de la BD almichain (ficticios).
-- Ejecutar como almichain_owner (necesita TRUNCATE):
--   psql -h localhost -U almichain_owner -d almichain -f 04_datos.sql
--
-- SOLO PARA DESARROLLO Y PRUEBAS: la primera sentencia VACIA todas las tablas
-- y reinicia los id a 1, de modo que el script se puede repetir siempre igual.
-- No ejecutar nunca en el servidor con datos reales sin copia de seguridad.
--
-- Todo va dentro de una transaccion: si algo falla, no se guarda nada a medias.
-- Los id se asignan en orden de insercion (1, 2, 3...), por eso las claves externas
-- usan esos numeros. Los odoo_id son inventados y no se repiten:
--   platos 101-108, productos 201-210, clientes 301-303,
--   empleados 401-405, ventas 501-510, lineas de venta 601-632.

BEGIN;

TRUNCATE TABLE
    pedidos_suministro, historial_precios, telefonos_local,
    reservas, inventarios, suministras, recetas, lineas_ventas, ventas,
    empleados, mesas, platos, clientes, proveedores, productos, locales, categorias
RESTART IDENTITY;

-- ============================================================
-- GRUPO 1: tablas sin claves externas
-- ============================================================

INSERT INTO categorias (nombre) VALUES
    ('Entrantes'),      -- id 1
    ('Principales'),    -- id 2
    ('Postres'),        -- id 3
    ('Bebidas');        -- id 4

INSERT INTO locales (nombre, calle, numero, codigo_postal, ciudad) VALUES
    ('Almi Centro',      'Calle Ejemplo',    '12', '48001', 'Bilbao'),   -- id 1
    ('Almi Casco Viejo', 'Plaza de Muestra', '3',  '48005', 'Bilbao');   -- id 2

INSERT INTO telefonos_local (local_id, telefono) VALUES
    (1, '944000001'),
    (1, '944000011'),   -- segundo teléfono del mismo local (atributo multivaluado)
    (2, '944000002');

INSERT INTO productos (odoo_id, nombre, unidad) VALUES
    (22, 'Tomate',          'kg'),       -- id 1
    (33, 'Patata',          'kg'),       -- id 2
    (34, 'Huevos',          'unidad'),   -- id 3
    (35, 'Bacalao',         'kg'),       -- id 4
    (36, 'Arroz',           'kg'),       -- id 5
    (37, 'Aceite de oliva', 'l'),        -- id 6
    (38, 'Leche',           'l'),        -- id 7
    (39, 'Azúcar',          'kg'),       -- id 8
    (40, 'Cerveza',         'l'),        -- id 9
    (32, 'Café',            'kg');       -- id 10

INSERT INTO proveedores (nombre, telefono, correo) VALUES
    ('Huerta del Norte',     '944100001', 'pedidos@huertanorte.example'),      -- id 1
    ('Pescados Cantábrico',  '944100002', 'ventas@pescados.example'),          -- id 2
    ('Despensa Bilbao',      '944100003', 'comercial@despensa.example'),       -- id 3
    ('Bodega y Cafés Norte', '944100004', 'info@bodegacafes.example');         -- id 4

INSERT INTO clientes (odoo_id, nombre, correo, telefono) VALUES
    (11, 'Laura Gómez', 'laura.gomez@correo.example', '600000001'),   -- id 1
    (14, 'Mikel Sáenz', 'mikel.saenz@correo.example', '600000002'),   -- id 2
    (15, 'Carmen Ortiz', NULL,                        '600000003');   -- id 3 (sin correo)

-- ============================================================
-- GRUPO 2: tablas con una FK a las anteriores
-- ============================================================

INSERT INTO platos (odoo_id, nombre, precio, categoria_id) VALUES
    (7,  'Ensalada de tomate',  6.50, 1),   -- id 1
    (15, 'Tortilla de patata',  8.00, 1),   -- id 2
    (16, 'Bacalao al pil-pil', 18.50, 2),   -- id 3
    (17, 'Arroz meloso',       14.00, 2),   -- id 4
    (18, 'Arroz con leche',     5.00, 3),   -- id 5
    (19, 'Flan casero',         4.50, 3),   -- id 6
    (20, 'Caña de cerveza',     2.50, 4),   -- id 7
    (21, 'Café con leche',      1.80, 4);   -- id 8

-- Historial de precios: fecha_hasta vacía = precio vigente (el mismo que platos.precio)
INSERT INTO historial_precios (plato_id, precio, fecha_desde, fecha_hasta) VALUES
    (1,  6.00, '2026-01-01', '2026-09-30'),   -- Ensalada de tomate
    (1,  6.50, '2026-10-01', NULL),
    (2,  7.50, '2026-01-01', '2026-09-30'),   -- Tortilla de patata
    (2,  8.00, '2026-10-01', NULL),
    (3, 17.50, '2026-01-01', '2026-09-30'),   -- Bacalao al pil-pil
    (3, 18.50, '2026-10-01', NULL),
    (4, 13.50, '2026-01-01', '2026-09-30'),   -- Arroz meloso
    (4, 14.00, '2026-10-01', NULL),
    (5,  4.80, '2026-01-01', '2026-09-30'),   -- Arroz con leche
    (5,  5.00, '2026-10-01', NULL),
    (6,  4.50, '2026-01-01', NULL),           -- Flan casero (sin cambios)
    (7,  2.50, '2026-01-01', NULL),           -- Caña de cerveza (sin cambios)
    (8,  1.80, '2026-01-01', NULL);           -- Café con leche (sin cambios)
    
-- numero 0 = barra de cada local
INSERT INTO mesas (numero, capacidad, local_id) VALUES
    (0, 8, 1),   -- id 1  barra Almi Centro
    (1, 4, 1),   -- id 2
    (2, 4, 1),   -- id 3
    (3, 6, 1),   -- id 4
    (0, 6, 2),   -- id 5  barra Almi Casco Viejo
    (1, 2, 2),   -- id 6
    (2, 4, 2);   -- id 7

INSERT INTO empleados (odoo_id, nombre, cargo, local_id) VALUES
    (2, 'Maite Goikoetxea', 'Camarera',  1),   -- id 1
    (7, 'Jon Arana',        'Camarero',  1),   -- id 2
    (19, 'Ainhoa Ruiz',      'Camarera',  2),   -- id 3
    (16, 'Unai Pérez',       'Encargado', 2),   -- id 4
    (10, 'Iker Larrea',      'Cocinero',  1);   -- id 5 (no hace ventas)

-- ============================================================
-- GRUPO 3: ventas y lineas (septiembre y octubre, dos locales)
-- ============================================================

INSERT INTO ventas (odoo_id, fecha, hora, mesa_id, empleado_id) VALUES
    (501, '2026-10-01', '13:45', 2, 1),   -- id 1   Almi Centro
    (502, '2026-10-01', '21:10', 4, 2),   -- id 2   Almi Centro
    (503, '2026-10-01', '14:05', 6, 3),   -- id 3   Almi Casco Viejo
    (504, '2026-10-02', '13:30', 1, 1),   -- id 4   Almi Centro (barra)
    (505, '2026-10-02', '20:55', 7, 4),   -- id 5   Almi Casco Viejo
    (506, '2026-10-15', '14:20', 3, 2),   -- id 6   Almi Centro
    (507, '2026-10-15', '22:00', 5, 3),   -- id 7   Almi Casco Viejo (barra)
    (508, '2026-09-20', '13:15', 4, 1),   -- id 8   Almi Centro
    (509, '2026-09-20', '21:40', 6, 4),   -- id 9   Almi Casco Viejo
    (510, '2026-09-27', '14:00', 2, 2);   -- id 10  Almi Centro

-- precio_unitario = precio en el momento de la venta
-- (en septiembre algunos platos costaban menos que ahora)
INSERT INTO lineas_ventas (odoo_id, cantidad, precio_unitario, venta_id, plato_id) VALUES
    -- venta 1
    (601, 2,  6.50, 1, 1),
    (602, 1, 18.50, 1, 3),
    (603, 2,  2.50, 1, 7),
    -- venta 2
    (604, 1,  8.00, 2, 2),
    (605, 2, 14.00, 2, 4),
    (606, 2,  4.50, 2, 6),
    (607, 3,  2.50, 2, 7),
    -- venta 3
    (608, 2, 18.50, 3, 3),
    (609, 1,  5.00, 3, 5),
    (610, 2,  1.80, 3, 8),
    -- venta 4
    (611, 2,  2.50, 4, 7),
    (612, 1,  8.00, 4, 2),
    (613, 1,  1.80, 4, 8),
    -- venta 5
    (614, 1, 14.00, 5, 4),
    (615, 1,  6.50, 5, 1),
    (616, 2,  2.50, 5, 7),
    (617, 2,  5.00, 5, 5),
    -- venta 6
    (618, 2, 18.50, 6, 3),
    (619, 2,  8.00, 6, 2),
    (620, 2,  4.50, 6, 6),
    -- venta 7
    (621, 4,  2.50, 7, 7),
    (622, 2,  8.00, 7, 2),
    -- venta 8 (precios de septiembre)
    (623, 1, 17.50, 8, 3),
    (624, 1,  6.00, 8, 1),
    (625, 2, 13.50, 8, 4),
    (626, 2,  2.50, 8, 7),
    -- venta 9 (precios de septiembre)
    (627, 2, 17.50, 9, 3),
    (628, 2,  4.80, 9, 5),
    (629, 2,  1.80, 9, 8),
    -- venta 10 (precio de septiembre)
    (630, 3,  7.50, 10, 2),
    (631, 3,  2.50, 10, 7),
    (632, 1,  4.50, 10, 6);

-- ============================================================
-- GRUPO 4: relaciones N:M
-- ============================================================

-- RECETA (plato, producto, cantidad por racion en la unidad del producto)
INSERT INTO recetas (plato_id, producto_id, cantidad_por_racion) VALUES
    (1, 1, 0.200), (1, 6, 0.020),                 -- ensalada: tomate, aceite
    (2, 2, 0.250), (2, 3, 3.000), (2, 6, 0.050),  -- tortilla: patata, huevos, aceite
    (3, 4, 0.250), (3, 6, 0.100),                 -- bacalao: bacalao, aceite
    (4, 5, 0.100), (4, 1, 0.050),                 -- arroz meloso: arroz, tomate
    (5, 5, 0.060), (5, 7, 0.250), (5, 8, 0.030),  -- arroz con leche: arroz, leche, azucar
    (6, 3, 2.000), (6, 7, 0.150), (6, 8, 0.040),  -- flan: huevos, leche, azucar
    (7, 9, 0.330),                                -- cana: cerveza
    (8, 10, 0.010), (8, 7, 0.100);                -- cafe con leche: cafe, leche

-- SUMINISTRA (producto, proveedor). El aceite lo suministran dos proveedores.
INSERT INTO suministras (producto_id, proveedor_id) VALUES
    (1, 1), (2, 1), (3, 1),     -- tomate, patata, huevos: Huerta del Norte
    (4, 2),                     -- bacalao: Pescados Cantabrico
    (5, 3), (7, 3), (8, 3),     -- arroz, leche, azucar: Despensa Bilbao
    (6, 3), (6, 4),             -- aceite: Despensa Bilbao y Bodega y Cafes Norte
    (9, 4), (10, 4);            -- cerveza, cafe: Bodega y Cafes Norte

-- Relación ternaria proveedor - producto - local: pedidos de reposición
INSERT INTO pedidos_suministro (proveedor_id, producto_id, local_id, fecha, cantidad, precio_unitario) VALUES
    (3, 6, 2, '2026-10-20', 10.00,  6.50),   -- aceite: Despensa Bilbao -> Casco Viejo
    (4, 6, 1, '2026-10-22',  8.00,  6.80),   -- aceite: Bodega y Cafés Norte -> Centro
    (4, 9, 2, '2026-10-20', 40.00,  1.20),   -- cerveza: Bodega y Cafés Norte -> Casco Viejo
    (1, 1, 2, '2026-10-18', 15.00,  2.10),   -- tomate: Huerta del Norte -> Casco Viejo
    (2, 4, 1, '2026-10-25', 10.00, 14.50),   -- bacalao: Pescados Cantábrico -> Centro
    (4, 10, 1, '2026-10-25', 5.00,  9.80);   -- café: Bodega y Cafés Norte -> Centro

-- INVENTARIO (local, producto, cantidad actual, stock minimo)
-- Algunos productos estan por debajo del minimo a proposito,
-- para que la consulta de "poco stock" devuelva resultados.
INSERT INTO inventarios (local_id, producto_id, cantidad_actual, stock_minimo) VALUES
    -- Almi Centro
    (1, 1, 12.00,  5.00), (1, 2, 30.00, 10.00), (1, 3, 60.00, 24.00),
    (1, 4,  3.00,  5.00),   -- bacalao: POCO STOCK
    (1, 5, 15.00,  5.00), (1, 6,  8.00,  4.00), (1, 7, 20.00, 10.00),
    (1, 8,  6.00,  3.00), (1, 9, 40.00, 20.00),
    (1, 10, 1.50,  2.00),   -- cafe: POCO STOCK
    -- Almi Casco Viejo
    (2, 1,  4.00,  5.00),   -- tomate: POCO STOCK
    (2, 2, 25.00, 10.00), (2, 3, 48.00, 24.00), (2, 4,  6.00,  5.00),
    (2, 5,  9.00,  5.00),
    (2, 6,  2.00,  4.00),   -- aceite: POCO STOCK
    (2, 7, 12.00, 10.00), (2, 8,  4.00,  3.00),
    (2, 9, 18.00, 20.00),   -- cerveza: POCO STOCK
    (2, 10, 3.00,  2.00);

-- RESERVA (mesa, cliente, fecha, hora, personas)
-- El mismo cliente reserva la misma mesa en dos momentos distintos
-- (por eso fecha y hora forman parte de la clave primaria).
INSERT INTO reservas (mesa_id, cliente_id, fecha, hora, num_personas) VALUES
    (4, 1, '2026-11-07', '21:00', 5),
    (4, 1, '2026-11-14', '14:00', 6),
    (7, 2, '2026-11-07', '21:00', 3);

COMMIT;
