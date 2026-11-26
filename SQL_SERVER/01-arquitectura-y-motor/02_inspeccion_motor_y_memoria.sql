-- ============================================================================
-- 02_inspeccion_motor_y_memoria.sql
-- Propósito: Inspeccionar archivos físicos de la BD activa, recursos de CPU/RAM
-- del servidor y el tamaño de los archivos de tempdb.
-- ============================================================================

USE Example;
GO

-- 1. Archivos físicos y tamaño actual de la base de datos activa
SELECT
    name AS nombre_logico,
    type_desc AS tipo_archivo,
    physical_name AS ruta_fisica,
    CAST(size * 8.0 / 1024 AS DECIMAL(10,2)) AS tamano_mb,
    CASE
        WHEN is_percent_growth = 1 THEN CONCAT(growth, '%')
        ELSE CONCAT(CAST(growth * 8.0 / 1024 AS DECIMAL(10,2)), ' MB')
    END AS crecimiento_configurado
FROM sys.database_files;

-- 2. Información general de memoria y CPU del servidor
SELECT
    cpu_count,
    physical_memory_kb / 1024 AS memoria_fisica_mb,
    committed_kb / 1024 AS memoria_comprometida_sql_mb,
    committed_target_kb / 1024 AS memoria_objetivo_sql_mb
FROM sys.dm_os_sys_info;

-- 3. Archivos de tempdb (útil para revisar si creció de más o si está equilibrada)
-- mdf , .ldf , .ndf,  que fueron configurados anteriormente
SELECT
    name AS archivo_tempdb,
    type_desc AS tipo,
    physical_name AS ruta_fisica,
    CAST(size * 8.0 / 1024 AS DECIMAL(10,2)) AS tamano_mb
FROM tempdb.sys.database_files;
