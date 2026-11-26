# Las consultas SQL más importantes para el análisis de negocio

Consultas analíticas en T-SQL para `DB_Textil` enfocadas en **ventas**, **inventario**, **producción** y **compras**.

---

## 1. Ventas y desempeño comercial

### Ventas totales y tickets por tienda y medio de pago
Permite comparar la facturación, cantidad de ventas y ticket promedio por sucursal y método de pago.

```sql
USE DB_Textil;
GO

SELECT 
    t.nombre_tienda,
    v.tipo_pago,
    COUNT(DISTINCT v.id_venta) AS total_ventas,
    SUM(dv.cantidad) AS unidades_vendidas,
    SUM(dv.subtotal) AS ingresos_totales,
    CAST(SUM(dv.subtotal) * 1.0 / NULLIF(COUNT(DISTINCT v.id_venta), 0) AS DECIMAL(10,2)) AS ticket_promedio
FROM Venta v
INNER JOIN Tienda t ON v.id_tienda = t.id_tienda
INNER JOIN Detalle_Venta dv ON v.id_venta = dv.id_venta
GROUP BY t.nombre_tienda, v.tipo_pago
ORDER BY ingresos_totales DESC;
```
Top de productos y tallas más vendidos
Identifica las variantes (Producto + Talla / SKU) que generan mayor ingreso y rotación.
```sql
SQL
SELECT TOP 10
    p.nombre_producto,
    c.nombre_categoria,
    ta.nombre_talla,
    pt.codigo_sku,
    SUM(dv.cantidad) AS unidades_vendidas,
    SUM(dv.subtotal) AS monto_generado
FROM Detalle_Venta dv
INNER JOIN Producto_Talla pt ON dv.id_producto_talla = pt.id_producto_talla
INNER JOIN Producto p ON pt.id_producto = p.id_producto
INNER JOIN Categoria c ON p.id_categoria = c.id_categoria
INNER JOIN Talla ta ON pt.id_talla = ta.id_talla
GROUP BY p.nombre_producto, c.nombre_categoria, ta.nombre_talla, pt.codigo_sku
ORDER BY unidades_vendidas DESC, monto_generado DESC;
Rendimiento de ventas por vendedor (empleado)
Muestra cuánto ha vendido cada empleado y en qué tienda opera.

SQL
SELECT 
    e.id_empleado,
    CONCAT(e.nombre, ' ', e.apellido) AS empleado,
    ISNULL(t.nombre_tienda, 'Sin tienda asignada') AS tienda,
    COUNT(DISTINCT v.id_venta) AS num_ventas,
    SUM(dv.subtotal) AS total_vendido
FROM Venta v
INNER JOIN Empleado e ON v.id_empleado = e.id_empleado
LEFT JOIN Tienda t ON v.id_tienda = t.id_tienda
INNER JOIN Detalle_Venta dv ON v.id_venta = dv.id_venta
GROUP BY e.id_empleado, e.nombre, e.apellido, t.nombre_tienda
ORDER BY total_vendido DESC;
```
2. Inventario por tienda
Stock crítico o agotado por tienda y variante
Ayuda a detectar qué prendas y tallas necesitan reposición inmediata en cada sucursal.
```sql
SQL
SELECT 
    t.nombre_tienda,
    p.nombre_producto,
    ta.nombre_talla,
    pt.codigo_sku,
    it.stock,
    CASE 
        WHEN it.stock = 0 THEN 'Agotado'
        WHEN it.stock <= 10 THEN 'Stock Bajo'
        ELSE 'Disponible'
    END AS estado_stock
FROM Inventario_Tienda it
INNER JOIN Tienda t ON it.id_tienda = t.id_tienda
INNER JOIN Producto_Talla pt ON it.id_producto_talla = pt.id_producto_talla
INNER JOIN Producto p ON pt.id_producto = p.id_producto
INNER JOIN Talla ta ON pt.id_talla = ta.id_talla
WHERE it.stock <= 10
ORDER BY it.stock ASC, t.nombre_tienda, p.nombre_producto;
```
Valorización del inventario por tienda
Calcula el valor comercial del stock actual en cada tienda usando el precio_venta del producto.
```sql
SQL
SELECT 
    t.nombre_tienda,
    SUM(it.stock) AS total_unidades,
    SUM(it.stock * p.precio_venta) AS valor_inventario_venta
FROM Inventario_Tienda it
INNER JOIN Tienda t ON it.id_tienda = t.id_tienda
INNER JOIN Producto_Talla pt ON it.id_producto_talla = pt.id_producto_talla
INNER JOIN Producto p ON pt.id_producto = p.id_producto
GROUP BY t.nombre_tienda
ORDER BY valor_inventario_venta DESC;
```
3. Producción y consumo de materia prima
Órdenes de producción por estado y prenda
Permite hacer seguimiento de lotes en proceso, finalizados o cancelados, junto con su supervisor y duración.
```sql
SQL
SELECT 
    op.id_orden,
    d.nombre AS departamento,
    CONCAT(e.nombre, ' ', e.apellido) AS supervisor,
    p.nombre_producto,
    ta.nombre_talla,
    op.cantidad_producida,
    op.estado,
    op.fecha_inicio,
    op.fecha_fin,
    DATEDIFF(HOUR, op.fecha_inicio, ISNULL(op.fecha_fin, GETDATE())) AS horas_transcurridas
FROM Orden_Produccion op
INNER JOIN Departamento d ON op.id_departamento = d.id_departamento
INNER JOIN Empleado e ON op.id_empleado_supervisor = e.id_empleado
INNER JOIN Producto_Talla pt ON op.id_producto_talla = pt.id_producto_talla
INNER JOIN Producto p ON pt.id_producto = p.id_producto
INNER JOIN Talla ta ON pt.id_talla = ta.id_talla
ORDER BY op.fecha_inicio DESC;
```
Consumo total de materia prima por insumo y unidad de medida
Resume cuánta tela o avío se ha asignado/consumido en las órdenes de producción y su costo estimado según Materia_Prima.precio_unidad.
```sql
SQL
SELECT 
    mp.id_materia_prima,
    mp.nombre AS materia_prima,
    mp.unidad_medida,
    SUM(dom.cantidad_materia) AS cantidad_consumida,
    SUM(dom.cantidad_materia * mp.precio_unidad) AS costo_estimado_insumos
FROM Detalle_Orden_Material dom
INNER JOIN Materia_Prima mp ON dom.id_materia_prima = mp.id_materia_prima
INNER JOIN Orden_Produccion op ON dom.id_orden = op.id_orden
WHERE op.estado <> 'Cancelado'
GROUP BY mp.id_materia_prima, mp.nombre, mp.unidad_medida
ORDER BY costo_estimado_insumos DESC;
```
4. Compras vs. ventas
Resumen mensual de compras vs. ventas
Ofrece una vista ejecutiva rápida del flujo de compras de insumos frente a los ingresos por ventas.
```sql
SQL
WITH ComprasMes AS (
    SELECT 
        YEAR(c.fecha_compra) AS anio,
        MONTH(c.fecha_compra) AS mes,
        SUM(dc.subtotal) AS total_compras
    FROM Compra c
    INNER JOIN Detalle_Compra dc ON c.id_compra = dc.id_compra
    GROUP BY YEAR(c.fecha_compra), MONTH(c.fecha_compra)
),
VentasMes AS (
    SELECT 
        YEAR(v.fecha_venta) AS anio,
        MONTH(v.fecha_venta) AS mes,
        SUM(dv.subtotal) AS total_ventas
    FROM Venta v
    INNER JOIN Detalle_Venta dv ON v.id_venta = dv.id_venta
    GROUP BY YEAR(v.fecha_venta), MONTH(v.fecha_venta)
)
SELECT 
    COALESCE(cm.anio, vm.anio) AS anio,
    COALESCE(cm.mes, vm.mes) AS mes,
    ISNULL(cm.total_compras, 0) AS total_compras,
    ISNULL(vm.total_ventas, 0) AS total_ventas,
    ISNULL(vm.total_ventas, 0) - ISNULL(cm.total_compras, 0) AS diferencia_bruta_caja
FROM ComprasMes cm
FULL OUTER JOIN VentasMes vm
    ON cm.anio = vm.anio AND cm.mes = vm.mes
ORDER BY anio DESC, mes DESC;
```
