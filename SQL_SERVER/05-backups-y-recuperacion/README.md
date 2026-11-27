# 💾 Backups y Recuperación

En esta sección se documentan las estrategias de respaldo y recuperación ante fallos en SQL Server, contrastando la gestión manual/automatizada en entornos locales o máquinas virtuales frente a los respaldos gestionados en Azure.

## Contenido sugerido

* `01_backup_y_restore_local.sql` — Comandos `BACKUP DATABASE`, `RESTORE VERIFYONLY` y `RESTORE DATABASE` en rutas de disco.
* `02_modelos_recuperacion_y_log.sql` — Uso de `RECOVERY MODEL` (`SIMPLE` vs. `FULL`) y respaldos de *Transaction Log*.

## Local / VM vs. Azure SQL
* **Local / VM:** Control directo de rutas de disco (`.bak`), modelos de recuperación y programación de tareas.
* **Azure SQL Database:** Respaldos automáticos gestionados por Azure con **Point-in-Time Restore (PITR)** y **Long-Term Retention (LTR)**, con costos asociados al almacenamiento de respaldos y periodos de retención.
