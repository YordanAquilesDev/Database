# ARQUTECTURA DE SQL SERVER Y MOTOR

La arquitectura de Microsoft SQL Server sigue un modelo cliente-servidor dividido en capas modulares que gestionan la comunicación, el procesamiento de consultas, el almacenamiento físico y los recursos del sistema.

## Componentes principales del motor
 ###  Capa de protocolo (SNI): Gestiona la conexión y el intercambio de mensajes entre las aplicaciones cliente y el servidor mediante protocolos de red (como TCP/IP, Named Pipes o memoria compartida).
 ### Motor relacional (procesador de consultas): Interpreta las sentencias T-SQL, valida la sintaxis, genera y optimiza los planes de ejecución y coordina la ejecución de las consultas.
### Motor de almacenamiento: Administra la lectura y escritura física en disco, las estructuras de datos (páginas, extensiones, índices), la Buffer Cache en memoria y la integridad transaccional.
### SQLOS (SQL Server Operating System): Coordina los hilos de ejecución, la programación de tareas, la memoria y la entrada/salida a bajo nivel por encima del sistema operativo anfitrión.

## Subprocesos clave del motor

### Analizador y optimizador: Revisa las consultas, estima costos según estadísticas e índices y elige el plan de ejecución más eficiente.
### Administrador de transacciones (Lock y Log Manager): Controla la concurrencia mediante bloqueos para mantener la coherencia y registra los cambios en el registro de transacciones para garantizar durabilidad y recuperación ante fallos.
### Administrador de búferes (Buffer Manager): Carga páginas de datos desde el disco hacia la memoria RAM para acelerar lecturas y escrituras, escribiendo los cambios persistentes en disco de forma controlada
