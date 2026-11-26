CREATE DATABASE DB_Textil;
GO

USE DB_Textil;
GO

-- 1. DEPARTAMENTO (Ventas, Producción, Administración, etc.)
CREATE TABLE Departamento (
    id_departamento INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(150) NULL
);

-- 2. TIENDA / SUCURSAL
CREATE TABLE Tienda (
    id_tienda INT IDENTITY(1,1) PRIMARY KEY,
    nombre_tienda VARCHAR(100) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    telefono VARCHAR(20) NULL,
    estado BIT NOT NULL DEFAULT 1 -- 1: Activa, 0: Inactiva
);

-- 3. EMPLEADO
-- Nota: la regla de negocio sobre si un empleado de área distinta a Ventas puede
-- o no tener tienda asignada se gestiona vía lógica de aplicación / procedimiento
-- (una restricción CHECK en SQL Server no puede consultar la tabla Departamento).
CREATE TABLE Empleado (
    id_empleado INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    dni VARCHAR(15) NOT NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(100) NULL UNIQUE,
    id_departamento INT NOT NULL,
    id_tienda INT NULL,
    fecha_ingreso DATE NOT NULL DEFAULT GETDATE(),
    estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Empleado_Departamento FOREIGN KEY (id_departamento)
        REFERENCES Departamento(id_departamento),
    CONSTRAINT FK_Empleado_Tienda FOREIGN KEY (id_tienda)
        REFERENCES Tienda(id_tienda)
);

-- 4. CLIENTE
CREATE TABLE Cliente (
    id_cliente INT IDENTITY(1,1) PRIMARY KEY,
    nombre_razon_social VARCHAR(100) NOT NULL,
    documento_identidad VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    correo VARCHAR(100) NULL
);

-- 5. PROVEEDOR
CREATE TABLE Proveedor (
    id_proveedor INT IDENTITY(1,1) PRIMARY KEY,
    razon_social VARCHAR(100) NOT NULL,
    ruc VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20) NULL,
    direccion VARCHAR(150) NULL
);

-- 6. MATERIA PRIMA (Telas, rollos, avíos/insumos)
CREATE TABLE Materia_Prima (
    id_materia_prima INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(20) NOT NULL
        CHECK (unidad_medida IN ('Metros', 'Kilos', 'Rollos', 'Unidades')),
    precio_unidad DECIMAL(10,2) NOT NULL CHECK (precio_unidad >= 0)
);

-- 7. CATEGORIA Y TALLA
CREATE TABLE Categoria (
    id_categoria INT IDENTITY(1,1) PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Talla (
    id_talla INT IDENTITY(1,1) PRIMARY KEY,
    nombre_talla VARCHAR(10) NOT NULL UNIQUE -- S, M, L, XL, etc.
);

-- 8. PRODUCTO TERMINADO
CREATE TABLE Producto (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    descripcion VARCHAR(200) NULL,
    id_categoria INT NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL CHECK (precio_venta > 0),
    CONSTRAINT FK_Producto_Categoria FOREIGN KEY (id_categoria)
        REFERENCES Categoria(id_categoria)
);

-- 9. VARIANTES DE PRODUCTO (Producto + Talla)
CREATE TABLE Producto_Talla (
    id_producto_talla INT IDENTITY(1,1) PRIMARY KEY,
    id_producto INT NOT NULL,
    id_talla INT NOT NULL,
    codigo_sku VARCHAR(50) NULL UNIQUE,
    CONSTRAINT FK_PT_Producto FOREIGN KEY (id_producto)
        REFERENCES Producto(id_producto),
    CONSTRAINT FK_PT_Talla FOREIGN KEY (id_talla)
        REFERENCES Talla(id_talla),
    CONSTRAINT UQ_Producto_Talla UNIQUE (id_producto, id_talla)
);

-- 10. INVENTARIO POR TIENDA
CREATE TABLE Inventario_Tienda (
    id_inventario INT IDENTITY(1,1) PRIMARY KEY,
    id_tienda INT NOT NULL,
    id_producto_talla INT NOT NULL,
    stock INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    CONSTRAINT FK_Inv_Tienda FOREIGN KEY (id_tienda)
        REFERENCES Tienda(id_tienda),
    CONSTRAINT FK_Inv_ProductoTalla FOREIGN KEY (id_producto_talla)
        REFERENCES Producto_Talla(id_producto_talla),
    CONSTRAINT UQ_Tienda_Producto UNIQUE (id_tienda, id_producto_talla)
);

-- 11. COMPRA DE MATERIA PRIMA
CREATE TABLE Compra (
    id_compra INT IDENTITY(1,1) PRIMARY KEY,
    id_proveedor INT NOT NULL,
    id_empleado INT NOT NULL,
    fecha_compra DATETIME NOT NULL DEFAULT GETDATE(),
    monto_total DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (monto_total >= 0),
    CONSTRAINT FK_Compra_Proveedor FOREIGN KEY (id_proveedor)
        REFERENCES Proveedor(id_proveedor),
    CONSTRAINT FK_Compra_Empleado FOREIGN KEY (id_empleado)
        REFERENCES Empleado(id_empleado)
);

CREATE TABLE Detalle_Compra (
    id_detalle_compra INT IDENTITY(1,1) PRIMARY KEY,
    id_compra INT NOT NULL,
    id_materia_prima INT NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal AS (cantidad * precio_unitario) PERSISTED,
    CONSTRAINT FK_DC_Compra FOREIGN KEY (id_compra)
        REFERENCES Compra(id_compra),
    CONSTRAINT FK_DC_MateriaPrima FOREIGN KEY (id_materia_prima)
        REFERENCES Materia_Prima(id_materia_prima)
);

-- 12. ORDEN DE PRODUCCIÓN (Cabecera: lote y prenda a fabricar)
CREATE TABLE Orden_Produccion (
    id_orden INT IDENTITY(1,1) PRIMARY KEY,
    id_departamento INT NOT NULL,
    id_empleado_supervisor INT NOT NULL,
    id_producto_talla INT NOT NULL,
    cantidad_producida INT NOT NULL CHECK (cantidad_producida > 0),
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'En Proceso'
        CHECK (estado IN ('En Proceso', 'Finalizado', 'Cancelado')),
    CONSTRAINT FK_OP_Departamento FOREIGN KEY (id_departamento)
        REFERENCES Departamento(id_departamento),
    CONSTRAINT FK_OP_EmpleadoSupervisor FOREIGN KEY (id_empleado_supervisor)
        REFERENCES Empleado(id_empleado),
    CONSTRAINT FK_OP_ProductoTalla FOREIGN KEY (id_producto_talla)
        REFERENCES Producto_Talla(id_producto_talla),
    CONSTRAINT CHK_OP_Fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

-- 13. DETALLE DE ORDEN DE PRODUCCIÓN (Insumos/telas consumidos)
CREATE TABLE Detalle_Orden_Material (
    id_detalle_orden INT IDENTITY(1,1) PRIMARY KEY,
    id_orden INT NOT NULL,
    id_materia_prima INT NOT NULL,
    cantidad_materia DECIMAL(10,2) NOT NULL CHECK (cantidad_materia > 0),
    CONSTRAINT FK_DOM_Orden FOREIGN KEY (id_orden)
        REFERENCES Orden_Produccion(id_orden),
    CONSTRAINT FK_DOM_MateriaPrima FOREIGN KEY (id_materia_prima)
        REFERENCES Materia_Prima(id_materia_prima)
);

-- 14. VENTAS EN TIENDA
CREATE TABLE Venta (
    id_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_tienda INT NOT NULL,
    id_empleado INT NOT NULL,
    id_cliente INT NOT NULL,
    fecha_venta DATETIME NOT NULL DEFAULT GETDATE(),
    tipo_pago VARCHAR(20) NOT NULL
        CHECK (tipo_pago IN ('Efectivo', 'Tarjeta', 'Transferencia')),
    monto_total DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (monto_total >= 0),
    CONSTRAINT FK_Venta_Tienda FOREIGN KEY (id_tienda)
        REFERENCES Tienda(id_tienda),
    CONSTRAINT FK_Venta_Empleado FOREIGN KEY (id_empleado)
        REFERENCES Empleado(id_empleado),
    CONSTRAINT FK_Venta_Cliente FOREIGN KEY (id_cliente)
        REFERENCES Cliente(id_cliente)
);

CREATE TABLE Detalle_Venta (
    id_detalle_venta INT IDENTITY(1,1) PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto_talla INT NOT NULL,
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL CHECK (precio_unitario > 0),
    subtotal AS (cantidad * precio_unitario) PERSISTED,
    CONSTRAINT FK_DV_Venta FOREIGN KEY (id_venta)
        REFERENCES Venta(id_venta),
    CONSTRAINT FK_DV_ProductoTalla FOREIGN KEY (id_producto_talla)
        REFERENCES Producto_Talla(id_producto_talla)
);
GO
