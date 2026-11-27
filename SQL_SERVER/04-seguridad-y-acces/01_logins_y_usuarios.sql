-- ============================================================================
-- 01. LOGINS Y USUARIOS EN SQL SERVER
-- ============================================================================
-- LOGIN : Identidad a nivel de servidor/instancia (define QUIÉN se autentica).
-- USER  : Identidad dentro de una base de datos específica (define QUÉ puede hacer ahí).
-- ============================================================================
-- 1. Crear LOGIN a nivel de servidor (autenticación SQL Server)
CREATE LOGIN DBA_Mant_Login
    WITH PASSWORD = N'LG_admin12@12',
         DEFAULT_DATABASE = [master],
         CHECK_EXPIRATION = OFF,
         CHECK_POLICY = ON;

-- Opciones útiles para administrar el LOGIN:
-- ALTER LOGIN DBA_Mant_Login DISABLE; -- Bloquear acceso temporal al servidor
-- ALTER LOGIN DBA_Mant_Login ENABLE;  -- Habilitar acceso nuevamente
-- DROP LOGIN DBA_Mant_Login;          -- Eliminar login del servidor

-- 2. Cambiar a la base de datos de trabajo y crear el USER asociado al LOGIN
USE DB_Textil;

CREATE USER Cesar FOR LOGIN DBA_Mant_Login
    WITH DEFAULT_SCHEMA = dbo;

-- Opciones útiles para administrar el USER:
-- ALTER USER Cesar WITH DEFAULT_SCHEMA = Ventas; -- Asignar el esquema Ventas como predeterminado en DB_Textil
-- DROP USER Cesar;                               -- Eliminar el usuario de la base de datos

-- NOTA: Muchos usuarios pueden compartir el mismo LOGIN, pero en diferentes bases de datos
-- (dentro de la misma base de datos solo puede haber un usuario mapeado a ese LOGIN).
