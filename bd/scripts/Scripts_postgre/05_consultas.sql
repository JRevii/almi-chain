-- 1. Ventas e ingresos por local y día. 

SELECT l.nombre AS local,
    v.fecha,
    count (DISTINCT v.id) AS ventas,
    sum(lv.cantidad * lv.precio_unitario) AS ingresos
FROM ventas v
JOIN mesas m            ON m.id = v.mesa_id 
JOIN locales l          ON l.id = m.local_id
JOIN lineas_ventas lv   ON lv.venta_id = v.id
GROUP BY l.nombre, v.fecha
ORDER BY v.fecha, l.nombre; 

--2. Platos mas vendidos (por unidades)

SELECT p.nombre,
    sum (lv.cantidad) AS unidades
FROM lineas_ventas lv
JOIN platos p ON p.id = lv.plato_id
GROUP BY p.nombre
ORDER BY unidades DESC; 

--3. Ingresos por plato. 

SELECT p.nombre AS plato, 
    sum (lv.cantidad) AS unidades,
    sum (lv.cantidad * lv.precio_unitario) AS ingresos
FROM lineas_ventas lv
JOIN platos p ON p.id = lv.plato_id 
GROUP BY p.nombre 
ORDER BY ingresos DESC; 

--4. Ventas e ingresos por mes

SELECT date_trunc ('month', v.fecha)::date AS mes,
    count (DISTINCT v.id)   AS ventas, 
    sum (lv.cantidad * lv.precio_unitario) AS ingresos
FROM ventas v
JOIN lineas_ventas lv ON lv.venta_id = v.id
GROUP BY date_trunc ('month', v.fecha)
ORDER BY mes;

--5. Empleados por local

SELECT l.nombre AS local, 
    e.nombre AS empleado, 
    e.cargo
FROM empleados e
JOIN locales l ON l.id = e.local_id
ORDER BY l.nombre, e.nombre; 

--5b. Cuantos empleados tiene cada local.
--LEFT JOIN: un local sin empleados saldria igualmente, con 0.

SELECT l.nombre AS local, 
    count (e.id) AS empleado
FROM locales l
LEFT JOIN empleados e ON e.local_id = l.id
GROUP BY l.nombre 
ORDER BY l.nombre;

--6. Ventas e ingresos de cada empleado

SELECT e.nombre AS empleado, 
    e.cargo,
    count (DISTINCT v.id)   AS ventas, 
    coalesce (sum (lv.cantidad * lv.precio_unitario), 0) AS ingresos
FROM empleados e
LEFT JOIN ventas v ON v.empleado_id = e.id
LEFT JOIN lineas_ventas lv ON lv.venta_id = v.id
GROUP BY e.id, e.nombre, e.cargo
ORDER BY ingresos DESC, e.nombre; 

--7. Productos con poco stock (por debajo del minimo de su local)

SELECT l.nombre AS local, 
    p.nombre AS producto,
    p.unidad, 
    i.cantidad_actual, 
    i.stock_minimo,
    i.stock_minimo - i.cantidad_actual AS faltan
FROM inventarios i 
JOIN locales l ON l.id = i.local_id
JOIN productos p ON p.id = i.producto_id 
WHERE i.cantidad_actual < i.stock_minimo
ORDER BY l.nombre, faltan DESC; 

--8. Proveedores de un producto concreto (cambiar el nombre del producto)

SELECT p.nombre AS producto,
    pr.nombre AS proveedor, 
    pr.telefono, 
    pr.correo
FROM productos p 
JOIN suministras s      ON s.producto_id = p.id
JOIN proveedores pr     ON pr.id = s.proveedor_id
WHERE p.nombre ='Aceite de oliva' 
ORDER BY pr.nombre; 

--9. Stock de un producto en cada local (cambiar el nombre del producto)

SELECT p.nombre AS producto, 
    l.nombre AS local,
    i.cantidad_actual, 
    i.stock_minimo,
    p.unidad
FROM inventarios i
JOIN locales l ON l.id = i.local_id 
JOIN productos p ON p.id = i.producto_id
WHERE p.nombre = 'Bacalao'
ORDER BY l.nombre; 
