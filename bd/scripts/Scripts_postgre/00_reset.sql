-- 00_reset.sql: borra las 14 tablas de la BD almichain.
-- SOLO PARA DESARROLLO Y PRUEBAS: elimina tablas Y TODOS SUS DATOS.
-- No ejecutar nunca en el servidor con datos reales sin copia de seguridad.
-- Ejecutar como almichain_owner:
--   psql -h localhost -U almichain_owner -d almichain -f 00_reset.sql

DROP TABLE IF EXISTS
    pedidos_suministro,
    historial_precios,
    telefonos_local,
    reservas,
    inventarios,
    suministras,
    recetas,
    lineas_ventas,
    ventas,
    empleados,
    mesas,
    platos,
    clientes,
    proveedores,
    productos,
    locales,
    categorias;
