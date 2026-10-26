   -- 02_tablas.sql: estructura de la BD almichain (14 tablas).
   -- Ejecutar como almichain_owner:
   --   psql -h localhost -U almichain_owner -d almichain -f bd/02_tablas.sql
   CREATE TABLE categorias (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre varchar (60) NOT NULL UNIQUE 
   ); 

   CREATE TABLE locales (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    nombre varchar (60) NOT NULL,
    telefono varchar (20),
    direccion varchar (150) NOT NULL
   );

-- Espejo de Odoo 
   CREATE TABLE  productos (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    odoo_id integer NOT NULL UNIQUE, 
    nombre varchar (80) NOT NULL, 
    unidad varchar (20) NOT NULL  
   );

   CREATE TABLE proveedores (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    nombre varchar (80) NOT NULL,
    telefono varchar (20),
    correo varchar (100)
   );

-- Espejo de Odoo (CRM)
   CREATE TABLE clientes(
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    odoo_id integer NOT NULL UNIQUE, 
    nombre varchar (80) NOT NULL, 
    correo varchar (100) UNIQUE, 
    telefono varchar (20) 
   );

-- Espejo de Odoo. FK en la relación "clasifica" (categoria 1:N plato)
   CREATE TABLE platos (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    odoo_id integer NOT NULL UNIQUE,  
    nombre varchar (80) NOT NULL, 
    precio numeric (8,2) NOT NULL CHECK (precio >= 0) 
   );

-- FK de la relación "tiene" (local 1:N mesa)
   CREATE TABLE mesas (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    numero integer NOT NULL CHECK (numero >= 0),
    capacidad integer NOT NULL CHECK (capacidad > 0), 
    local_id integer NOT NULL REFERENCES locales(id), 
    UNIQUE (local_id, numero)
   );
   
-- Espejo de Odoo. FK de la relación "trabaja en" (local 1:N empleado)
   CREATE TABLE empleados (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    odoo_id integer NOT NULL UNIQUE, 
    nombre varchar (80) NOT NULL, 
    cargo varchar (50) NOT NULL, 
    local_id integer NOT NULL REFERENCES locales(id) 
   );

-- Espejo de Odoo. FK de "se sirve en" (mesa 1:N venta) y "realiza" (empleado 1:N venta) 
   CREATE TABLE ventas (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
    odoo_id integer NOT NULL UNIQUE, 
    fecha date NOT NULL,
    hora time NOT NULL, 
    mesa_id integer NOT NULL REFERENCES mesas(id), 
    empleado_id integer NOT NULL REFERENCES empleados(id)
   );

-- Espejo de Odoo. FK de "contiene" (venta 1:N linea) y "aparece en" (plato 1:N linea) 
   CREATE TABLE lineas_ventas (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    odoo_id integer NOT NULL UNIQUE, 
    cantidad integer NOT NULL CHECK (cantidad > 0), 
    precio_unitario numeric(8,2) NOT NULL CHECK (precio_unitario >= 0), 
    venta_id integer NOT NULL REFERENCES ventas(id), 
    plato_id integer NOT NULL REFERENCES platos(id) 
   ); 

-- RECETA: plato N:M producto
   CREATE TABLE recetas (
    plato_id integer NOT NULL REFERENCES platos (id),
    producto_id integer NOT NULL REFERENCES productos (id),
    cantidad_por_racion numeric (8,3) NOT NULL CHECK (cantidad_por_racion > 0)
   );

-- SUMINISTRA: proveedor N:M producto (sin atributos propios)
   CREATE TABLE suministras (
    producto_id integer NOT NULL REFERENCES productos (id), 
    proveedor_id integer NOT NULL REFERENCES proveedores (id),
    PRIMARY KEY (producto_id, proveedor_id)
   );

-- INVENTARIO: local N:M producto. cantidad_actual la manda Odoo; stock_minimo es de esta BD
   CREATE TABLE inventarios (
    local_id integer NOT NULL REFERENCES locales (id), 
    producto_id integer NOT NULL REFERENCES productos (id), 
    cantidad_actual numeric (10,2) NOT NULL DEFAULT 0 CHECK (cantidad_actual >= 0),
    stock_minimo numeric (10,2) NOT NULL DEFAULT 0 CHECK (stock_minimo >= 0),
    PRIMARY KEY (local_id, producto_id)
   );

-- RESERVA: mesa N:M cliente. La PK incluye fecha y hora para que el mismo cliente pueda reservar la misma mesa en momentos distintos.
   CREATE TABLE reservas (
    mesa_id integer NOT NULL REFERENCES mesas (id), 
    cliente_id integer NOT NULL REFERENCES clientes (id), 
    fecha date NOT NULL, 
    hora time NOT NULL, 
    num_personas integer NOT NULL CHECK (num_personas > 0), 
    PRIMARY KEY (mesa_id, cliente_id, fecha, hora)
   );









