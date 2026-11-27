#  Seguridad y Control de Acceso en SQL Server

Esta sección documenta las estrategias de autenticación, autorización y protección de datos aplicadas bajo el **Principio de Mínimo Privilegio**.

## Contenido del módulo

1. **`01_logins_y_usuarios.sql`**: Creación de credenciales a nivel de instancia (`LOGIN`) y mapeo a nivel de base de datos (`USER`), aplicando políticas de contraseñas seguras.
2. **`02_roles_y_permisos_dcl.sql`**: Implementación de roles personalizados (`CREATE ROLE`) y control granular mediante `GRANT`, `DENY` y `REVOKE` sobre esquemas, vistas y procedimientos almacenados.
3. **`03_enmascaramiento_ddm.sql`**: Ejemplo de *Dynamic Data Masking* para proteger información sensible (PII) frente a consultas de soporte o análisis.
4. **`04_seguridad_nivel_fila_rls.sql`**: Implementación de *Row-Level Security* mediante funciones predicado y políticas de seguridad.

## Buenas prácticas aplicadas
* **Cero uso de `sa` o `db_owner`** para cadenas de conexión de aplicaciones.
* **Encapsulamiento:** Acceso a escritura controlado exclusivamente mediante *Stored Procedures*.
* **Segregación por esquemas:** Permisos agrupados por dominio de negocio (`Ventas`, `RRHH`, `Auditoria`).
