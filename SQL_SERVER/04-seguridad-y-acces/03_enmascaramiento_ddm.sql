-- ============================================================================
-- 03. DYNAMIC DATA MASKING (DDM) EN SQL SERVER
-- ============================================================================
-- Oculta información sensible (PII) en los resultados de consultas para
-- usuarios sin privilegios, sin modificar los datos reales almacenados.
-- ============================================================================

USE DB_Textil;


-- Creamos un esquema de prueba
CREATE SCHEMA SeguridadDemo;


-- Creamos una tabla dentro del esquema de prueba con distintas funciones de máscara
CREATE TABLE SeguridadDemo.Cliente (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    NombreCompleto NVARCHAR(100) NOT NULL,
    Correo VARCHAR(120) MASKED WITH (FUNCTION = 'email()') NOT NULL, -- Muestra inicial + dominio enmascarado (ej. cXXX@XXXX.com)
    Telefono VARCHAR(20) MASKED WITH (FUNCTION = 'partial(2, "XXXXXX", 2)') NOT NULL, -- Muestra 2 iniciales y 2 finales
    Salario DECIMAL(10,2) MASKED WITH (FUNCTION = 'default()') NOT NULL -- Muestra 0.00 para usuarios sin permiso
);


-- Insertamos datos de prueba
INSERT INTO SeguridadDemo.Cliente (NombreCompleto, Correo, Telefono, Salario)
VALUES
    (N'Cesar Mendoza', 'cesar.mendoza@empresa.com', '987654321', 4200.00),
    (N'Lucia Paredes', 'lucia.paredes@empresa.com', '912345678', 3800.00);


-- Usuario de prueba sin permiso UNMASK (WITHOUT LOGIN porque es solo para probar en la BD)
CREATE USER UsuarioSoporte WITHOUT LOGIN;

-- Permiso de lectura sobre la tabla Cliente
GRANT SELECT ON SeguridadDemo.Cliente TO UsuarioSoporte;


-- Probar cómo ve los datos un usuario sin UNMASK:
EXECUTE AS USER = 'UsuarioSoporte'; -- Cambia temporalmente la sesión al contexto de UsuarioSoporte
SELECT ClienteID, NombreCompleto, Correo, Telefono, Salario
FROM SeguridadDemo.Cliente;
REVERT;


-- Si un rol o usuario necesita ver los datos reales sin máscara:
-- GRANT UNMASK TO Rol_RRHH_Autorizado;
-- Para quitar el permiso de ver sin máscara:
-- REVOKE UNMASK FROM Rol_RRHH_Autorizado;
