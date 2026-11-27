-- ============================================================================
-- 02_modelos_de_recuperacion.sql
-- Modelos de recuperación (SIMPLE, FULL, BULK_LOGGED) y su impacto en backups
-- ============================================================================

-- 1. Consultar el modelo de recuperación actual de las bases de datos
SELECT
    name AS base_datos,
    recovery_model_desc AS modelo_recuperacion,
    state_desc AS estado_bd
FROM sys.databases
WHERE name IN (N'master', N'model', N'msdb', N'tempdb', N'DB_Textil');


-- 2. Cambiar el modelo de recuperación a FULL (necesario para BACKUP LOG y Point-in-Time Restore)
ALTER DATABASE DB_Textil
SET RECOVERY FULL;


-- Opcional: cambiar a SIMPLE (trunca/reutiliza el log automáticamente tras checkpoint;
-- no permite BACKUP LOG ni restauración a un punto intermedio en el tiempo)
-- ALTER DATABASE DB_Textil
-- SET RECOVERY SIMPLE;
-- GO

-- Opcional: cambiar a BULK_LOGGED (para ventanas de cargas masivas específicas)
-- ALTER DATABASE DB_Textil
-- SET RECOVERY BULK_LOGGED;
-- GO

-- 3. Ejemplo de cadena de restauración en modelo FULL:
-- (Verifica los nombres lógicos reales con RESTORE FILELISTONLY antes de ejecutar)

-- Paso 1: FULL con NORECOVERY
RESTORE DATABASE DB_Textil_Restaurada
FROM DISK = N'C:\SQLBackups\DB_Textil_Full.bak'
WITH
    MOVE N'DB_Textil_Data' TO N'C:\SQLData\DB_Textil_Restaurada.mdf',
    MOVE N'DB_Textil_Log'  TO N'C:\SQLData\DB_Textil_Restaurada.ldf',
    NORECOVERY,
    STATS = 10;


-- Paso 2: DIFFERENTIAL con NORECOVERY (si existe uno posterior al FULL)
RESTORE DATABASE DB_Textil_Restaurada
FROM DISK = N'C:\SQLBackups\DB_Textil_Diff.bak'
WITH
    NORECOVERY,
    STATS = 10;


-- Paso 3: LOG final con RECOVERY (deja la BD lista para usar)
RESTORE LOG DB_Textil_Restaurada
FROM DISK = N'C:\SQLBackups\DB_Textil_Log.trn'
WITH
    RECOVERY,
    STATS = 10;
