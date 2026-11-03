-- 01_roles_y_bd.sql: crea el rol dueño y la base de datos almichain.
-- Ejecutar como administrador (postgres):
--   sudo -u postgres psql < 01_roles_y_bd.sql
--
-- La contraseña NO está en este fichero. Se asigna aparte, a mano:
--   sudo -u postgres psql -c "\password almichain_owner"
 
CREATE ROLE almichain_owner LOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE;
 
CREATE DATABASE almichain OWNER almichain_owner;
 
-- Mínimo privilegio: nadie entra por defecto, solo los roles autorizados.
REVOKE ALL ON DATABASE almichain FROM PUBLIC;
 