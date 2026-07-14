USE pizzeria_don_piccolo;

-- Clientes con pedidos entre dos fechas (BETWEEN).
SELECT *
FROM cliente c
JOIN pedido p
ON c.id_cliente = p.id_cliente
WHERE p.fecha BETWEEN '2026-07-12' AND '2026-07-13';

-- Pizzas más vendidas (GROUP BY y COUNT).
SELECT pi.nombre, COUNT(*) AS total_vendidas
FROM pedido pe
JOIN detalle_pedido dp
ON pe.id_pedido = dp.id_pedido
JOIN pizza pi
ON pi.id_pizza = dp.id_pizza
GROUP BY pi.nombre
ORDER BY total_vendidas DESC;

-- Pedidos por repartidor (JOIN).
SELECT r.nombre, COUNT(d.id_domicilio) AS total_domicilios
FROM repartidor r
LEFT JOIN domicilio d ON r.id_repartidor = d.id_repartidor
GROUP BY r.id_repartidor, r.nombre;

-- Promedio de entrega por zona (AVG y JOIN).
SELECT
 CASE
 WHEN distancia_km BETWEEN 0 AND 3 THEN '0-3 km'
 WHEN distancia_km BETWEEN 3.01 AND 5 THEN '3-5 km'
 WHEN distancia_km BETWEEN 5.01 AND 10 THEN '5-10 km'
 ELSE 'Más de 10 km'
 END AS rango,
 AVG(TIMESTAMPDIFF(MINUTE, hora_salida, hora_llegada)) AS promedio_minutos
FROM domicilio
WHERE hora_llegada IS NOT NULL
GROUP BY rango;

-- Clientes que gastaron más de un monto (HAVING).
SELECT cl.nombre, SUM(pe.total) AS monto
FROM pedido pe
JOIN cliente cl ON pe.id_cliente = cl.id_cliente
GROUP BY cl.id_cliente, cl.nombre
HAVING monto > 50000;

-- Búsqueda por coincidencia parcial de nombre de pizza (LIKE).
SELECT id_pizza, nombre, precio_venta
FROM pizza
WHERE nombre LIKE '%mexicana%' OR nombre LIKE '%hawaiana%';

-- Subconsulta para obtener los clientes frecuentes (más de 5 pedidos mensuales).
SELECT c.nombre, c.id_cliente, sub.pedidos
FROM (
 SELECT id_cliente, COUNT(*) AS pedidos
 FROM pedido
 WHERE MONTH(fecha) = MONTH(CURRENT_DATE())
 AND YEAR(fecha) = YEAR(CURRENT_DATE())
 GROUP BY id_cliente
 HAVING pedidos > 5
) AS sub
JOIN cliente c ON sub.id_cliente = c.id_cliente;