# 🗄️ Portafolio de Ingeniería y Administración de Bases de Datos (SQL Server)

Repositorio técnico orientado a demostrar competencias prácticas en arquitectura, modelado, programación T-SQL, seguridad, continuidad operativa y optimización en **Microsoft SQL Server**.

---

## 🧭 Navegación Rápida por Módulos

Haz clic en cualquier módulo para ir directamente a sus scripts, diagramas y documentación:

[![01 Arquitectura](https://img.shields.io/badge/01-Arquitectura_y_Motor-0078D4?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)](./01-arquitectura-y-motor)
[![02 Modelado](https://img.shields.io/badge/02-Modelado_y_DDL-2EA44F?style=for-the-badge&logo=databricks&logoColor=white)](./02-modelado-y-ddl)
[![03 T-SQL](https://img.shields.io/badge/03-Consultas_y_T--SQL-D97706?style=for-the-badge&logo=codeforces&logoColor=white)](./03-consultas-y-programacion)
[![04 Seguridad](https://img.shields.io/badge/04-Seguridad_y_Acceso-DC2626?style=for-the-badge&logo=shield&logoColor=white)](./04-seguridad-y-acceso)
[![05 Backups](https://img.shields.io/badge/05-Backups_y_Recuperación-7C3AED?style=for-the-badge&logo=icloud&logoColor=white)](./05-backups-y-recuperacion)
[![06 Rendimiento](https://img.shields.io/badge/06-Rendimiento_y_Monitoreo-0891B2?style=for-the-badge&logo=speedtest&logoColor=white)](./06-rendimiento-y-monitoreo)
[![07 Proyectos](https://img.shields.io/badge/07-Proyectos_Prácticos-111827?style=for-the-badge&logo=github&logoColor=white)](./07-proyectos-practicos)

---

## 📋 Resumen Ejecutivo del Repositorio

| Módulo | Enfoque Técnico | Entregables Clave |
| :--- | :--- | :--- |
| **[01. Arquitectura y Motor](./01-arquitectura-y-motor)** | Funcionamiento interno de SQL Server (`MDF`/`LDF`, páginas, *buffer pool*, `tempdb`). | Diagramas de flujo, configuración de *filegroups* y crecimiento controlado. |
| **[02. Modelado y DDL](./02-modelado-y-ddl)** | Normalización (1FN a 3FN), criterios de desnormalización e integridad referencial. | Diagramas ERD, scripts `CREATE TABLE`, `CHECK`, `UNIQUE` y claves foráneas. |
| **[03. Consultas y T-SQL](./03-consultas-y-programacion)** | Lógica de negocio, analítica y control transaccional. | CTEs, *window functions*, *stored procedures*, vistas y manejo `TRY...CATCH`. |
| **[04. Seguridad y Acceso](./04-seguridad-y-acceso)** | Principio de mínimo privilegio y aislamiento por esquemas. | Creación de logins, usuarios, roles personalizados y matriz de permisos. |
| **[05. Backups y Recuperación](./05-backups-y-recuperacion)** | Continuidad de negocio, RPO/RTO y recuperación ante desastres. | Scripts de respaldo *Full*, *Differential*, *Log* y pruebas de *Restore*. |
| **[06. Rendimiento y Monitoreo](./06-rendimiento-y-monitoreo)** | Diagnóstico de cuellos de botella, índices y concurrencia. | Comparativas de *execution plans*, índices `INCLUDE` y manejo de *deadlocks*. |
| **[07. Proyectos Prácticos](./07-proyectos-practicos)** | Soluciones completas de extremo a extremo con datos de prueba. | Caso de estudio empresarial con esquema, carga de datos y consultas clave. |

---

## ⭐ Por dónde empezar a revisar (Top 3 Archivos)

Si tienes menos de 3 minutos para evaluar este repositorio, te recomiendo revisar directamente estos tres casos:

1. **[Diseño de Base de Datos Normalizada + DDL](./02-modelado-y-ddl/README.md)** — Decisiones de modelado y restricciones reales.
2. **[Estrategia de Backups y Simulación de Restore](./05-backups-y-recuperacion/README.md)** — Cómo garantizar cero pérdida de datos ante fallos.
3. **[Optimización de Consulta Lenta con Índices](./06-rendimiento-y-monitoreo/README.md)** — Reducción de lecturas lógicas mediante planes de ejecución.

---

## 🛠️ Stack y Herramientas Utilizadas

* **Motor:** Microsoft SQL Server (2019 / 2022)
* **Clientes:** SQL Server Management Studio (SSMS) / Azure Data Studio
* **Modelado:** dbdiagram.io / Draw.io / SSMS Database Diagrams

