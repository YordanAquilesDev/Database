-- ============================================================================
-- DDL (Data Definition Language): Ejemplos de creación (CREATE) en SQL Server
-- ============================================================================

-- 1. SCHEMA: Espacio de nombres lógico para agrupar objetos y controlar permisos
CREATE SCHEMA Ventas;
GO

-- 2. TABLE: Estructura principal de filas y columnas con restricciones de integridad
CREATE TABLE Ventas.Pedido (
    PedidoID INT IDENTITY(1,1) CONSTRAINT PK_Pedido PRIMARY KEY,
    ClienteID INT NOT NULL,
    CodigoPedido VARCHAR(20) NOT NULL CONSTRAINT UQ_Pedido_Codigo UNIQUE,
    Monto DECIMAL(10,2) NOT NULL CONSTRAINT CHK_Pedido_Monto CHECK (Monto > 0),
    Estado VARCHAR(20) NOT NULL CONSTRAINT DF_Pedido_Estado DEFAULT ('Pendiente'),
    FechaRegistro DATETIME2 NOT NULL CONSTRAINT DF_Pedido_Fecha DEFAULT (SYSDATETIME())
);
GO

-- 3. VIEW: Consulta guardada reutilizable (facilita acceso y encapsula consultas)
CREATE VIEW Ventas.vw_PedidosResumen
AS -- indica desde aca comienza la logica  --->
SELECT
    PedidoID,
    ClienteID,
    CodigoPedido,
    Monto,
    Estado
FROM Ventas.Pedido;
GO

-- 4. PROCEDURE: Bloque T-SQL reutilizable (útil para lógica de negocio y transacciones)
CREATE PROCEDURE Ventas.usp_RegistrarPedido
    @ClienteID INT,
    @CodigoPedido VARCHAR(20),
    @Monto DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Ventas.Pedido (ClienteID, CodigoPedido, Monto)
    VALUES (@ClienteID, @CodigoPedido, @Monto);
END;


-- 5. FUNCTION: Rutina que devuelve un valor (escalar) o un conjunto de filas (tabla)
CREATE FUNCTION Ventas.fn_CalcularImpuesto (@Monto DECIMAL(10,2))
RETURNS DECIMAL(10,2) -- tipo de dato de retorno
AS
BEGIN  -- indica el cuerpo logica de la funcion
    -- LOGICA ....
    RETURN @Monto * 0.18;
END;
GO

-- 6. TRIGGER: Disparador que se ejecuta automáticamente ante un evento (ej. AFTER INSERT)
-- Muy usado en auditoría, validaciones o automatización de procesos
CREATE TRIGGER Ventas.trg_Pedido_AfterInsert
ON Ventas.Pedido -- se ejecuta cuando   se  registra un evento en la tabla Pedido
AFTER INSERT   -- indica el evento de Insert (cuando se inserta un dato)
AS
BEGIN
    -- LOGICA ....
    SET NOCOUNT ON;

    SELECT PedidoID, CodigoPedido, Monto
    FROM inserted;
END;


-- 7. INDEX: Estructura auxiliar para acelerar búsquedas y filtros (ej. por Estado)
CREATE NONCLUSTERED INDEX IX_Pedido_Estado
    ON Ventas.Pedido (Estado);


-- 8. SEQUENCE: Generador de números correlativos independiente de una tabla
CREATE SEQUENCE Ventas.Seq_CodigoInterno
    AS INT
    START WITH 100
    INCREMENT BY 1;


-- 9. SYNONYM: Alias para referenciar otro objeto (útil para desacoplar nombres/rutas)
CREATE SYNONYM Ventas.PedidoActual
    FOR Ventas.Pedido;


-- 10. LOGIN: Credencial/identidad de acceso a nivel de instancia SQL Server
-- (Aplica en entornos con logins de instancia; no en Azure SQL Database)
CREATE LOGIN VentasApp_Login  -- nombre dek login
    WITH PASSWORD = N'CambiarEstaClave!2026'; -- su password


-- 11. USER: Usuario dentro de la base de datos actual asociado al LOGIN
CREATE USER VentasApp_User  -- nombre del user
    FOR LOGIN VentasApp_Login; -- a que login pertenece


-- 12. ROLE: Rol de base de datos para agrupar permisos y asignar usuarios
CREATE ROLE Rol_AnalistaVentas;


-- Ejemplo de cómo asignar el usuario al rol creado:
ALTER ROLE Rol_AnalistaVentas ADD MEMBER VentasApp_User;
GO
