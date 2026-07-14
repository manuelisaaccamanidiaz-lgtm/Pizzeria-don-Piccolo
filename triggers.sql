USE pizzeria_don_piccolo;

-- Trigger de actualización automática de stock de ingredientes cuando se realiza un pedido.
DELIMITER $$
CREATE TRIGGER descuento_stock
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN 
	UPDATE ingrediente i
	JOIN pizza_ingrediente pi ON i.id_ingrediente = pi.id_ingrediente
	SET i.stock_actual = i.stock_actual - (pi.cantidad * NEW.cantidad)
	WHERE pi.id_pizza = NEW.id_pizza;
END $$
DELIMITER ;

-- Trigger de auditoría que registre en una tabla historial_precios cada vez que se modifique el precio de una pizza.
DELIMITER $$
CREATE TRIGGER auditoria
AFTER UPDATE ON pizza
FOR EACH ROW
BEGIN
	INSERT INTO historial_precio (id_pizza,precio_anterior,precio_nuevo) VALUES
    (NEW.id_pizza,OLD.precio_venta,NEW.precio_venta);
END $$
DELIMITER ;

-- Trigger para marcar repartidor como “disponible” nuevamente cuando termina un domicilio.
DELIMITER $$
CREATE TRIGGER repartidor_disponible
AFTER UPDATE ON domicilio
FOR EACH ROW
BEGIN 
	IF NEW.estado = 'entregado' THEN
		UPDATE repartidor SET disponible = TRUE WHERE id_repartidor = NEW.id_repartidor;
	END IF;
END $$
DELIMITER ;