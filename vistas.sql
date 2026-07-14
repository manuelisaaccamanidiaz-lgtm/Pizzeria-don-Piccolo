USE pizzeria_don_piccolo;

-- Vista de resumen de pedidos por cliente (nombre del cliente, cantidad de pedidos, total gastado).
CREATE VIEW pedido_cliente AS
SELECT cl.id_cliente, cl.nombre, COUNT(pe.id_pedido) AS cantidad_pedidos, SUM(pe.total) AS total_gastado
FROM pedido pe
JOIN cliente cl ON cl.id_cliente = pe.id_cliente
GROUP BY cl.id_cliente, cl.nombre;

-- Vista de desempeño de repartidores (número de entregas, tiempo promedio, zona).
CREATE VIEW desempeño_repartidor AS
SELECT
 r.id_repartidor,
 r.nombre,
 COUNT(d.id_domicilio) AS numero_entregas,
 AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_llegada)) AS tiempo_promedio,
 AVG(d.distancia_km) AS distancia_promedio
FROM repartidor r
LEFT JOIN domicilio d ON r.id_repartidor = d.id_repartidor AND d.hora_llegada IS NOT NULL
GROUP BY r.id_repartidor, r.nombre;

-- Vista de stock de ingredientes por debajo del mínimo permitido.
CREATE VIEW stock_minimo AS
SELECT id_ingrediente, nombre, stock_actual, stock_minimo, (stock_actual - stock_minimo) AS diferencia
FROM ingrediente
WHERE stock_actual < stock_minimo;