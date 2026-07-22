ALTER TABLE repartidor ADD COLUMN bono INT DEFAULT 0;

DELIMITER $$
CREATE FUNCTION minutos_entrega(p_id_domicilio INT) RETURNS INT
NOT DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE minutos INT;
    SELECT TIMESTAMPDIFF(MINUTE, hora_salida, hora_llegada) INTO minutos
    FROM domicilio
    WHERE id_domicilio = p_id_domicilio;
    RETURN minutos;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER bono_repartidor
AFTER UPDATE ON domicilio
FOR EACH ROW
BEGIN
    IF OLD.hora_llegada IS NULL AND NEW.hora_llegada IS NOT NULL THEN
        IF minutos_entrega(NEW.id_domicilio) <= 20 THEN
            UPDATE repartidor SET bono = bono + 1 WHERE id_repartidor = NEW.id_repartidor;
        END IF;
    END IF;
END $$
DELIMITER ;