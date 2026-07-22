USE pizzeria_don_piccolo;


-- Consulta de entregas realizadas por cada repartidor
SELECT r.nombre , COUNT(d.id_domicilio) AS entregas_realizadas, SUM(pe.total) AS total_acumulado
FROM repartidor r
JOIN domicilio d
ON r.id_repartidor = d.id_repartidor
JOIN pedido pe
ON d.id_pedido = pe.id_pedido
WHERE pe.estado = 'entregado'
GROUP BY r.nombre , r.id_repartidor;


-- Consulta de pedidos demorados
SELECT *
FROM pedido pe
JOIN domicilio d
ON pe.id_pedido = d.id_pedido
WHERE TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_llegada) > 40;


-- Consulta de repartidores activos sin entregas
SELECT r.*
FROM repartidor r
LEFT JOIN domicilio d 
ON r.id_repartidor = d.id_repartidor
WHERE d.id_domicilio IS NULL;


-- Vista resumen de desempeño
CREATE VIEW vista_desempeno_repartidor AS 
SELECT r.nombre AS nombre_repartidor, COUNT(d.id_domicilio) AS entregas_totales, AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_llegada)) AS promedio_minutos_entrega
FROM repartidor r
JOIN domicilio d
ON r.id_repartidor = d.id_repartidor
WHERE d.hora_llegada IS NOT NULL
GROUP BY r.nombre;

SELECT *
FROM vista_desempeno_repartidor