# 📐 DDL (Data Definition Language) en SQL Server

El **DDL** agrupa las sentencias SQL que **definen, modifican o eliminan la estructura** de los objetos y restricciones dentro de SQL Server (a diferencia del DML, que manipula los datos dentro de las filas).

---

## 1. Verbos y Operaciones DDL Principales

* **`CREATE`:** Crea nuevos objetos en la instancia o en la base de datos.
* **`ALTER`:** Modifica la estructura, definición o propiedades de un objeto existente sin destruirlo.
* **`DROP`:** Elimina objetos de forma permanente.
* **`TRUNCATE`:** Vacía por completo los registros de una tabla y reinicia su `IDENTITY` (no admite tablas referenciadas por `FOREIGN KEY` activas).
* **Renombrado (`sp_rename`):** En SQL Server no existe `RENAME`; los cambios de nombre de objetos o columnas se realizan con `EXEC sp_rename 'ObjetoActual', 'NuevoNombre';`.

---

## 2. Objetos Creables con `CREATE` (y su ciclo con `ALTER` / `DROP`)

### Estructurales y de organización
* **`DATABASE`:** Crea, modifica (`ALTER DATABASE`) o elimina (`DROP DATABASE`) una base de datos, sus archivos y *filegroups*.
* **`SCHEMA`:** Crea un espacio de nombres lógico (`CREATE SCHEMA Ventas;`) para agrupar objetos, aislar responsabilidades y asignar permisos por área.
* **`TABLE`:** Define columnas, tipos de datos, nulabilidad y restricciones (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `DEFAULT`). Se ajusta con `ALTER TABLE` (`ADD`, `ALTER COLUMN`, `DROP COLUMN`, `ADD CONSTRAINT`, `DROP CONSTRAINT`).

### Programables y de consulta
* **`VIEW`:** Define o actualiza (`CREATE OR ALTER VIEW`) una consulta guardada como objeto de esquema.
* **`PROCEDURE`:** Crea o modifica (`CREATE OR ALTER PROCEDURE`) un procedimiento almacenado.
* **`FUNCTION`:** Crea o modifica (`CREATE OR ALTER FUNCTION`) funciones escalares o con valor de tabla.
* **`TRIGGER`:** Crea o modifica (`CREATE OR ALTER TRIGGER`) disparadores asociados a tablas (`AFTER` / `INSTEAD OF`) o a eventos DDL (`ON DATABASE` / `ON ALL SERVER`).

### Rendimiento, numeración y alias
* **`INDEX`:** Crea (`CREATE INDEX` / `CREATE CLUSTERED INDEX` / `CREATE NONCLUSTERED INDEX`), modifica/reconstruye (`ALTER INDEX`) o elimina (`DROP INDEX`) estructuras de acceso a datos.
* **`SEQUENCE`:** Genera valores numéricos secuenciales independientes de una tabla (`CREATE SEQUENCE`, `ALTER SEQUENCE`, `DROP SEQUENCE`).
* **`SYNONYM`:** Crea un alias para referenciar otro objeto local o remoto (`CREATE SYNONYM`, `DROP SYNONYM`).

### Identidad, acceso y roles
* **`LOGIN`:** Crea, modifica o elimina (`CREATE LOGIN`, `ALTER LOGIN`, `DROP LOGIN`) la identidad de autenticación a nivel de instancia/servidor (en entornos que soporten *logins* de instancia).
* **`USER`:** Crea, modifica o elimina (`CREATE USER`, `ALTER USER`, `DROP USER`) la identidad de acceso dentro de una base de datos específica.
* **`ROLE`:** Crea, modifica o elimina (`CREATE ROLE`, `ALTER ROLE`, `DROP ROLE`) roles de base de datos para agrupar membresías y permisos.

---

## 3. Restricciones (`CONSTRAINTS`) en DDL

Las restricciones garantizan la integridad de la estructura y de las reglas de negocio directamente en el motor:

* **`PRIMARY KEY`:** Identifica unívocamente cada fila y prohíbe valores `NULL`.
* **`FOREIGN KEY`:** Exige integridad referencial entre tablas (y permite configurar reglas de borrado/actualización como `NO ACTION` o `CASCADE`).
* **`UNIQUE`:** Impide valores duplicados en una columna o combinación de columnas.
* **`CHECK`:** Valida una condición booleana al insertar o modificar filas (por ejemplo, rangos, estados permitidos o fechas coherentes).
* **`DEFAULT`:** Asigna un valor predeterminado cuando no se envía uno explícitamente.
* **`NOT NULL`:** Obliga a que una columna siempre tenga un valor informado.

---

## 4. Plantilla Base de Referencia DDL

```sql
-- Esquema y tabla con restricciones nombradas
CREATE SCHEMA Operaciones;
GO

CREATE TABLE Operaciones.Lote (
    IdLote INT IDENTITY(1,1) CONSTRAINT PK_Lote PRIMARY KEY,
    CodigoLote VARCHAR(30) NOT NULL CONSTRAINT UQ_Lote_Codigo UNIQUE,
    Cantidad INT NOT NULL CONSTRAINT DF_Lote_Cantidad DEFAULT (1),
    Estado VARCHAR(20) NOT NULL CONSTRAINT DF_Lote_Estado DEFAULT ('Activo'),
    FechaAlta DATETIME2 NOT NULL CONSTRAINT DF_Lote_Fecha DEFAULT (SYSDATETIME()),
    CONSTRAINT CHK_Lote_Cantidad CHECK (Cantidad > 0),
    CONSTRAINT CHK_Lote_Estado CHECK (Estado IN ('Activo', 'Cerrado', 'Anulado'))
);
GO

-- Modificación estructural con ALTER
ALTER TABLE Operaciones.Lote
    ADD CodigoExterno VARCHAR(40) NULL;
GO

ALTER TABLE Operaciones.Lote
    ADD CONSTRAINT UQ_Lote_CodigoExterno UNIQUE (CodigoExterno);
GO

ALTER TABLE Operaciones.Lote
    DROP CONSTRAINT UQ_Lote_CodigoExterno;
GO

ALTER TABLE Operaciones.Lote
    DROP COLUMN CodigoExterno;
GO
