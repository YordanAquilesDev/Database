-- ============================================================================
-- 04. ROW-LEVEL SECURITY (RLS) EN SQL SERVER
-- ============================================================================
-- Filtra automáticamente las filas visibles (y opcionalmente bloquea escrituras
-- no autorizadas) según el usuario que ejecuta la consulta, mediante una
-- función predicado y una SECURITY POLICY.
-- ============================================================================

USE DB_Textil;
GO

-- Reutilizamos o creamos esquema de seguridad
IF SCHEMA_ID(N'SeguridadDemo') IS NULL
    EXEC(N'CREATE SCHEMA SeguridadDemo;');
GO

-- 1. Creación de una tabla de muestra en el esquema SeguridadDemo
CREATE TABLE SeguridadDemo.PedidoRegional (
    PedidoID INT IDENTITY(1,1) PRIMARY KEY,
    CodigoPedido VARCHAR(20) NOT NULL,
    UsuarioAsignado SYSNAME NOT NULL,
    Monto DECIMAL(10,2) NOT NULL
);
GO

INSERT INTO SeguridadDemo.PedidoRegional (CodigoPedido, UsuarioAsignado, Monto)
VALUES
    ('PED-001', 'VendedorNorte', 1500.00),
    ('PED-002', 'VendedorSur',   2300.00),
    ('PED-003', 'VendedorNorte',  950.00);
GO

-- 2. Usuarios de prueba sin login (solo para demostración en la BD)
CREATE USER VendedorNorte WITHOUT LOGIN;
CREATE USER VendedorSur   WITHOUT LOGIN;
CREATE USER SupervisorRLS WITHOUT LOGIN;

-- Asignar permisos de lectura a los usuarios
GRANT SELECT ON SeguridadDemo.PedidoRegional TO VendedorNorte;
GRANT SELECT ON SeguridadDemo.PedidoRegional TO VendedorSur;
GRANT SELECT ON SeguridadDemo.PedidoRegional TO SupervisorRLS;
GO

-- 3. Función predicado (Inline Table-Valued Function con SCHEMABINDING)
-- Recibe el nombre de usuario de la fila y devuelve 1 si la fila es visible
-- para el usuario actual (o 0 filas si no cumple).
-- SCHEMABINDING ata la función a la estructura de los objetos referenciados.
CREATE FUNCTION SeguridadDemo.fn_PredicadoPedidoRegional (@UsuarioAsignado SYSNAME)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS Permitido
    WHERE
        @UsuarioAsignado = USER_NAME()
        OR USER_NAME() = 'SupervisorRLS'
        OR IS_MEMBER('db_owner') = 1;
GO

-- 4. Crear la política de seguridad (SECURITY POLICY)
-- Enlaza la función predicado con la tabla y activa el filtrado automático.
CREATE SECURITY POLICY SeguridadDemo.SecPol_PedidoRegional
    ADD FILTER PREDICATE SeguridadDemo.fn_PredicadoPedidoRegional(UsuarioAsignado)
        ON SeguridadDemo.PedidoRegional
    -- Opcional: bloquear INSERT/UPDATE/DELETE sobre filas que no correspondan al usuario
    -- ADD BLOCK PREDICATE SeguridadDemo.fn_PredicadoPedidoRegional(UsuarioAsignado)
    --     ON SeguridadDemo.PedidoRegional AFTER INSERT,
    -- ADD BLOCK PREDICATE SeguridadDemo.fn_PredicadoPedidoRegional(UsuarioAsignado)
    --     ON SeguridadDemo.PedidoRegional BEFORE UPDATE
WITH (STATE = ON); -- Activa la política de seguridad
GO

-- 5. Pruebas con EXECUTE AS USER
EXECUTE AS USER = 'VendedorNorte';
SELECT PedidoID, CodigoPedido, UsuarioAsignado, Monto
FROM SeguridadDemo.PedidoRegional; -- Solo ve PED-001 y PED-003
REVERT;
GO

EXECUTE AS USER = 'VendedorSur';
SELECT PedidoID, CodigoPedido, UsuarioAsignado, Monto
FROM SeguridadDemo.PedidoRegional; -- Solo ve PED-002
REVERT;
GO

EXECUTE AS USER = 'SupervisorRLS';
SELECT PedidoID, CodigoPedido, UsuarioAsignado, Monto
FROM SeguridadDemo.PedidoRegional; -- Ve todos los pedidos
REVERT;
GO

-- Administrar la política:
-- ALTER SECURITY POLICY SeguridadDemo.SecPol_PedidoRegional WITH (STATE = OFF);
-- DROP SECURITY POLICY IF EXISTS SeguridadDemo.SecPol_PedidoRegional;
-- DROP FUNCTION IF EXISTS SeguridadDemo.fn_PredicadoPedidoRegional;
GO
