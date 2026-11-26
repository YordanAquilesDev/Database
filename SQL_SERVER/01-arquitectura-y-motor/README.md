[![Volver al Índice](https://img.shields.io/badge/⬅️_Volver_al_Índice_Principal-1F2937?style=for-the-badge)](../README.md)

# 🏗️ 01. Arquitectura y Motor de SQL Server

SQL Server sigue un modelo cliente-servidor dividido en capas modulares que coordinan la comunicación de red, el procesamiento de consultas, el almacenamiento físico y la gestión de recursos del sistema.

---

## 🧩 Componentes Principales del Motor

* **Capa de Protocolo (SNI — SQL Server Native Client / Network Interface):** Gestiona la conexión y el intercambio de mensajes entre aplicaciones y el motor mediante **TCP/IP**, **Named Pipes**, **Shared Memory** o **VIA**.
* **Motor Relacional (Procesador de Consultas):** Recibe el código T-SQL, valida sintaxis y objetos, genera y optimiza planes de ejecución y coordina su ejecución.
* **Motor de Almacenamiento:** Administra la lectura y escritura física en disco, las estructuras de datos (páginas y extensiones), la caché en memoria (*Buffer Pool*) y la integridad transaccional.
* **SQLOS (SQL Server Operating System):** Coordina hilos de ejecución (*schedulers/workers*), asignación de memoria y operaciones de E/S por encima del sistema operativo.

---

## ⚙️ Subprocesos y Mecanismos Clave

* **Analizador y Optimizador (*Query Optimizer*):** Revisa la consulta, estima costos usando **estadísticas** e índices y selecciona un plan de ejecución eficiente (sin garantizar siempre el "óptimo absoluto", sino uno de bajo costo en tiempo razonable).
* **Administrador de Transacciones (*Lock Manager* y *Log Manager*):** Controla la concurrencia con bloqueos/versionado y aplica el principio **WAL (*Write-Ahead Logging*)**, escribiendo en el *Transaction Log* antes de persistir cambios de datos en disco.
* **Administrador de Búferes (*Buffer Manager*):** Mantiene **páginas de 8 KB** en memoria RAM (*Buffer Pool*) para evitar accesos constantes a disco; las páginas modificadas en memoria se conocen como *dirty pages* hasta que el *Checkpoint* o *Lazy Writer* las escribe en disco.

---

## 💾 Almacenamiento Físico y Bases de Datos del Sistema

* **Archivos físicos:**
  * `.mdf`: Archivo principal de datos.
  * `.ndf`: Archivos secundarios de datos (útiles para distribuir carga o separar *filegroups*).
  * `.ldf`: Archivo de registro de transacciones (*Transaction Log*).
* **Bases de datos del sistema:** `master`, `model`, `msdb` y **`tempdb`** (área compartida para ordenamientos, tablas temporales y *version store*; suele ser cuello de botella si no se dimensiona bien).

---

## 🔍 Implicaciones Prácticas en Producción

* **Si falta memoria en el *Buffer Pool*:** Aumentan las lecturas físicas desde disco y sube la latencia de las consultas.
* **Si las estadísticas están desactualizadas:** El optimizador puede elegir un *scan* en lugar de un *seek* o dimensionar mal un *join*.
* **Si `tempdb` crece sin control:** Puede llenar el disco y afectar a toda la instancia, no solo a una base de datos.

---

## 📂 Contenido de Esta Carpeta

* `01_configuracion_bd_y_filegroups.sql` — Script de creación de base de datos con archivos, *filegroups* y crecimiento controlado.
* `02_inspeccion_motor_y_memoria.sql` — Consultas DMV (*Dynamic Management Views*) básicas para revisar estado de memoria, archivos y `tempdb`.
