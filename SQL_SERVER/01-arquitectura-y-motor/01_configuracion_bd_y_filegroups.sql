-- ============================================================================
-- 01_configuracion_bd_y_filegroups.sql
-- Propósito: Comparar creación por defecto vs. creación explícita con control
-- de archivos físicos (.mdf, .ndf, .ldf), límites, crecimiento y filegroups.
-- ============================================================================

/*
-- FORMA SIMPLE (menos control):
CREATE DATABASE Example;
-- SQL Server toma los valores por defecto de la base de datos 'model' y de la
-- carpeta predeterminada de la instancia: el tamaño inicial suele ser pequeño,
-- el crecimiento puede ser porcentual o por defecto y no siempre defines la ruta
-- ni la separación de archivos desde el inicio.
*/

-- FORMA EXPLÍCITA (con control de almacenamiento, crecimiento y filegroups):
CREATE DATABASE Example
ON PRIMARY
(
    NAME = N'Example_Primary', -- Nombre lógico del archivo principal dentro de SQL Server
    FILENAME = N'C:\SQLData\Example_Primary.mdf', -- Ruta física del archivo principal de datos (.mdf)
    SIZE = 64MB, -- Tamaño inicial para evitar múltiples ampliaciones al arrancar
    MAXSIZE = UNLIMITED, -- Sin tope lógico definido (en práctica, limitado por el espacio del disco)
    FILEGROWTH = 32MB -- Incremento fijo en MB cuando el archivo necesita más espacio
),
FILEGROUP FG_DATOS_TRANSACCIONALES -- Agrupa uno o más archivos de datos para organizar y aislar tablas/índices
(
    NAME = N'Example_Trans', -- Nombre lógico del archivo secundario
    FILENAME = N'C:\SQLData\Example_Trans.ndf', -- Archivo secundario de datos (.ndf) para este filegroup
    SIZE = 128MB, -- Tamaño inicial mayor previsto para tablas con más movimiento
    MAXSIZE = 10GB, -- Límite máximo de seguridad para evitar que este archivo sature el disco
    FILEGROWTH = 64MB -- Crecimiento fijo de 64 MB al llenarse
)
LOG ON -- Archivo del Transaction Log: registra operaciones para recuperación y consistencia (WAL)
(
    NAME = N'Example_Log', -- Nombre lógico del archivo de log
    FILENAME = N'C:\SQLData\Example_Log.ldf', -- Ruta física del archivo de registro (.ldf)
    SIZE = 64MB, -- Tamaño inicial del log
    MAXSIZE = 5GB, -- Límite máximo para controlar el crecimiento del log
    FILEGROWTH = 32MB -- Crecimiento fijo de 32 MB
);
GO

-- Establece FG_DATOS_TRANSACCIONALES como filegroup predeterminado:
-- las nuevas tablas/índices que no indiquen otro filegroup se crearán aquí por defecto.
ALTER DATABASE Example
MODIFY FILEGROUP FG_DATOS_TRANSACCIONALES DEFAULT;
GO
