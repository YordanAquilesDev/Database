-- ============================================================================
-- 01_backup_y_restore_local.sql
-- Respaldo completo (FULL) y restauración en SQL Server local / VM
-- ============================================================================

-- 1. Backup COMPLETO (FULL) a una ruta física
-- Asegúrate de que la carpeta exista y la cuenta del servicio de SQL Server
-- tenga permisos de escritura en esa ruta.
BACKUP DATABASE DB_Textil
TO DISK = N'C:\SQLBackups\DB_Textil_Full.bak'
WITH
    FORMAT,                 -- Sobrescribe el medio y crea un nuevo conjunto de medios
    INIT,                   -- Sobrescribe cualquier backup previo en ese archivo
    NAME = N'DB_Textil - Full Database Backup',
    COMPRESSION,            -- Comprime el archivo (en ediciones que soporten compresión)
    STATS = 10;             -- Muestra progreso cada 10%
GO

-- 2. Verificar la integridad del archivo de respaldo antes de confiar en él
RESTORE VERIFYONLY
FROM DISK = N'C:\SQLBackups\DB_Textil_Full.bak';
GO

-- 3. Restaurar la base de datos (ejemplo restaurando con otro nombre para probar)
-- Si restauras sobre la misma BD, asegúrate de que no haya conexiones bloqueando
-- o usa WITH REPLACE según corresponda.
RESTORE DATABASE DB_Textil_Restaurada
FROM DISK = N'C:\SQLBackups\DB_Textil_Full.bak'
WITH
    MOVE N'DB_Textil_Data' TO N'C:\SQLData\DB_Textil_Restaurada.mdf',
    MOVE N'DB_Textil_Log'  TO N'C:\SQLData\DB_Textil_Restaurada.ldf',
    STATS = 10;
GO
