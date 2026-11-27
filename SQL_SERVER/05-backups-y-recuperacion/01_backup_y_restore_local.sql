-- ============================================================================
-- 01_backup_y_restore_local.sql
-- Respaldos (FULL, DIFFERENTIAL, LOG) y restauración en SQL Server local / VM
-- ============================================================================

-- 1. Backup COMPLETO (FULL) a una ruta física
-- Asegúrate de que la carpeta exista y la cuenta del servicio de SQL Server
-- tenga permisos de escritura en esa ruta.
BACKUP DATABASE DB_Textil
TO DISK = N'C:\SQLBackups\DB_Textil_Full.bak'
WITH
    FORMAT,                                         -- Sobrescribe el medio y crea un nuevo conjunto de medios
    INIT,                                           -- Sobrescribe cualquier backup previo en ese archivo
    NAME = N'DB_Textil - Full Database Backup',     -- Etiqueta descriptiva del backup dentro del medio
    COMPRESSION,                                    -- Comprime el archivo (en ediciones compatibles)
    STATS = 10;                                     -- Muestra progreso cada 10%
GO

-- 2. Backup DIFERENCIAL (cambios desde el último FULL) en local / VM
BACKUP DATABASE DB_Textil
TO DISK = N'C:\SQLBackups\DB_Textil_Diff.bak'
WITH
    DIFFERENTIAL,
    INIT,
    COMPRESSION,
    STATS = 10;
GO

-- 3. Backup del TRANSACTION LOG (requiere modelo de recuperación FULL)
BACKUP LOG DB_Textil
TO DISK = N'C:\SQLBackups\DB_Textil_Log.trn'
WITH
    INIT,
    COMPRESSION,
    STATS = 10;
GO

-- 4. Verificar la integridad del archivo de respaldo antes de confiar en él
RESTORE VERIFYONLY
FROM DISK = N'C:\SQLBackups\DB_Textil_Full.bak';
GO

-- 5. Restaurar la base de datos (ejemplo restaurando con otro nombre para probar)
-- Revisa los nombres lógicos reales de los archivos con RESTORE FILELISTONLY.
RESTORE DATABASE DB_Textil_Restaurada
FROM DISK = N'C:\SQLBackups\DB_Textil_Full.bak'
WITH
    MOVE N'DB_Textil_Data' TO N'C:\SQLData\DB_Textil_Restaurada.mdf',
    MOVE N'DB_Textil_Log'  TO N'C:\SQLData\DB_Textil_Restaurada.ldf',
    STATS = 10;
GO
