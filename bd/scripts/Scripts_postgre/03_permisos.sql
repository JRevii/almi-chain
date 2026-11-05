-- 03_permisos.sql: rol de uso diario con minimo privilegio. 
-- Ejecutar como administrador, conectado a almichain. 
-- La contraseña se asigna aparte, a mano: \password almichain_app

CREATE ROLE almichain_app LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE; 

GRANT CONNECT ON DATABASE almichain TO almichain_app; 
GRANT USAGE ON SCHEMA public TO almichain_app; 
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO almichain_app;
