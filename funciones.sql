USE pizzeria_don_piccolo;

DELIMITER $$
CREATE FUNCTION calcular_total_pedido(p_id_pedido INT)
RETURNS DECIMAL(10,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE subtotal_pizza DECIMAL(10,2) DEFAULT 0;
    DECLARE costo_envio DECIMAL(10,2) DEFAULT 0;
    DECLARE iva DECIMAL(10,2) DEFAULT 0;
    DECLARE total DECIMAL(10,2) DEFAULT 0;
    
    -- 1. Sumar pizzas
    SELECT IFNULL(SUM(cantidad * precio_unitario), 0) INTO subtotal_pizza
    FROM detalle_pedido
    WHERE id_pedido = p_id_pedido;
    
    -- 2. Calcular costo de envío (ej: $1000 por km)
    SELECT IFNULL(distancia_km * 1000, 0) INTO costo_envio
    FROM domicilio
    WHERE id_pedido = p_id_pedido;
    
    -- 3. Calcular IVA (19%)
    SET iva = (subtotal_pizza + costo_envio) * 0.19;
    
    -- 4. Total
    SET total = subtotal_pizza + costo_envio + iva;
    
    RETURN total;
END$$
DELIMITER ;


DELIMITER $$
CREATE FUNCTION calcular_ganancia_diaria(p_fecha DATE)
RETURNS DECIMAL(10,2)
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total_ventas DECIMAL(10,2) DEFAULT 0;
    DECLARE total_costos DECIMAL(10,2) DEFAULT 0;
    DECLARE ganancia DECIMAL(10,2) DEFAULT 0;
    
    -- Total de ventas del día (pedidos entregados)
    SELECT IFNULL(SUM(total), 0) INTO total_ventas
    FROM pedido
    WHERE DATE(fecha) = p_fecha
      AND estado = 'entregado';
    
    -- Total de costos de ingredientes del día
    SELECT IFNULL(SUM(dp.cantidad * pi.cantidad * i.costo_unitario), 0) INTO total_costos
    FROM detalle_pedido dp
    JOIN pizza_ingrediente pi ON dp.id_pizza = pi.id_pizza
    JOIN ingrediente i ON pi.id_ingrediente = i.id_ingrediente
    JOIN pedido p ON dp.id_pedido = p.id_pedido
    WHERE DATE(p.fecha) = p_fecha
      AND p.estado = 'entregado';
    
    SET ganancia = total_ventas - total_costos;
    
    RETURN ganancia;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE cambiar_estado (IN p_id_pedido INT, IN p_hora_llegada DATETIME)
BEGIN
    -- 1. Actualizar hora_llegada en domicilio y Actualizar estado del domicilio a 'entregado'
    UPDATE domicilio d SET d.hora_llegada = p_hora_llegada , d.estado = 'entregado' WHERE id_pedido = p_id_pedido;

    -- 2. Actualizar estado del pedido a 'entregado'
	UPDATE pedido p SET p.estado = 'entregado' WHERE id_pedido = p_id_pedido;

END$$
DELIMITER ;