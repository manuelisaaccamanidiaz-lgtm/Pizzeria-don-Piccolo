DELIMITER $$
CREATE PROCEDURE verificar_disponibilidad(IN p_id_pizza INT, OUT p_disponible BOOLEAN)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pizza_ingrediente pi
        JOIN ingrediente i ON i.id_ingrediente = pi.id_ingrediente
        WHERE pi.id_pizza = p_id_pizza
        AND i.stock_actual < pi.cantidad
    ) THEN
        SET p_disponible = TRUE;
    ELSE
        SET p_disponible = FALSE;
    END IF;
END $$
DELIMITER ;