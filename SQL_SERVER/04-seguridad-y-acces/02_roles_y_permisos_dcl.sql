-- ============================================================================
-- 02. ROLES Y PERMISOS (DCL) EN SQL SERVER
-- ============================================================================
-- ROLE : Agrupa permisos dentro de una base de datos para administrarlos
--        en bloque y asignar usuarios a ese perfil (Principio de Mínimo Privilegio).
-- ============================================================================

USE DB_Textil;


-- 1. Crear un rol personalizado dentro de la base de datos actual
CREATE ROLE Rol_OperadorVentas;

-- Ejemplo de otro rol (por ejemplo, de solo lectura)
CREATE ROLE Rol_LecturaGeneral;

-- 2. Agregar miembros (usuarios u otros roles) al rol creado
ALTER ROLE Rol_OperadorVentas ADD MEMBER Cesar;


-- 3. Asignar permisos al rol (GRANT / DENY / REVOKE)
-- Ejemplo: dar lectura y escritura sobre un esquema o tabla
GRANT SELECT, INSERT, UPDATE ON SCHEMA::Ventas TO Rol_OperadorVentas;

GRANT SELECT ON DATABASE::DB_Textil TO Rol_LecturaGeneral;

-- Bloquear explícitamente una acción si hace falta (DENY prevalece sobre GRANT)
DENY DELETE ON SCHEMA::Ventas TO Rol_OperadorVentas;

-- Quitar un permiso previamente otorgado
REVOKE INSERT ON SCHEMA::Ventas TO Rol_OperadorVentas;


-- Opciones útiles para administrar el ROLE:
ALTER ROLE Rol_OperadorVentas DROP MEMBER Cesar; -- Quitar usuario del rol
DROP ROLE Rol_LecturaGeneral;                   -- Eliminar rol (debe no tener miembros ni permisos críticos)
