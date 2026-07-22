ALTER TABLE cliente ADD COLUMN cupones_usados INT DEFAULT 0;

DELIMITER $$
CREATE FUNCTION es_cliente_frecuente(p_id_cliente INT)
RETURNS BOOLEAN
NOT DETERMINISTIC
READS SQL DATA
BEGIN
DECLARE es_frecuente BOOLEAN DEFAULT FALSE;
DECLARE pedidos INT DEFAULT 0;

SELECT COUNT(id_cliente) INTO pedidos
FROM pedido
WHERE id_cliente = p_id_cliente
AND MONTH(fecha) = MONTH(CURRENT_DATE) 
AND YEAR(fecha) = YEAR(CURRENT_DATE);

IF pedidos >= 5 THEN 
SET es_frecuente = TRUE;
END IF;

RETURN es_frecuente;
END $$
DELIMITER ;


DELIMITER $$
CREATE TRIGGER descuento_aplicado
BEFORE UPDATE ON pedido
FOR EACH ROW
BEGIN
    IF es_cliente_frecuente(NEW.id_cliente) THEN
        SET NEW.total = NEW.total * 0.9;
        UPDATE cliente SET cupones_usados = cupones_usados + 1 WHERE id_cliente = NEW.id_cliente;
    END IF;
END $$
DELIMITER ;