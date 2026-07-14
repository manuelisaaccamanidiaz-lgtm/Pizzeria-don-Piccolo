-- ============================================
-- Pizzería Don Piccolo
-- ============================================

CREATE DATABASE IF NOT EXISTS pizzeria_don_piccolo
 CHARACTER SET utf8mb4
 COLLATE utf8mb4_unicode_ci;

USE pizzeria_don_piccolo;


-- ============================================
-- creacion de estructura
-- ============================================

-- ============================================
-- 1. TABLA: clientes
-- ============================================
CREATE TABLE cliente (
 id_cliente INT AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 telefono VARCHAR(20) NOT NULL,
 direccion TEXT NOT NULL,
 correo_electronico VARCHAR(100) UNIQUE,
 fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 2. TABLA: proveedores
-- ============================================
CREATE TABLE proveedor (
 id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 telefono VARCHAR(20),
 correo VARCHAR(100)
);

-- ============================================
-- 3. TABLA: ingredientes
-- ============================================
CREATE TABLE ingrediente (
 id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 unidad_medida VARCHAR(20) NOT NULL,
 stock_actual DECIMAL(10,2) DEFAULT 0,
 stock_minimo DECIMAL(10,2) DEFAULT 0,
 costo_unitario DECIMAL(10,2) NOT NULL DEFAULT 0,
 id_proveedor INT,
 FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor)
 ON UPDATE CASCADE ON DELETE SET NULL
);

-- ============================================
-- 4. TABLA: pizzas
-- ============================================
CREATE TABLE pizza (
 id_pizza INT AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) UNIQUE NOT NULL,
 descripcion TEXT,
 precio_venta DECIMAL(10,2) NOT NULL,
 tipo ENUM('vegetariana', 'especial', 'clasica') NOT NULL DEFAULT 'clasica',
 activa BOOLEAN DEFAULT TRUE
);

-- ============================================
-- 5. TABLA: pizza_ingredientes (tabla puente)
-- ============================================
CREATE TABLE pizza_ingrediente (
 id_pizza INT NOT NULL,
 id_ingrediente INT NOT NULL,
 cantidad DECIMAL(10,2) NOT NULL,
 PRIMARY KEY (id_pizza, id_ingrediente),
 FOREIGN KEY (id_pizza) REFERENCES pizza(id_pizza)
 ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (id_ingrediente) REFERENCES ingrediente(id_ingrediente)
 ON UPDATE CASCADE ON DELETE CASCADE
);

-- ============================================
-- 6. TABLA: pedidos
-- ============================================
CREATE TABLE pedido (
 id_pedido INT AUTO_INCREMENT PRIMARY KEY,
 id_cliente INT NOT NULL,
 fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
 metodo_pago ENUM('efectivo', 'tarjeta', 'app') NOT NULL,
 estado ENUM('pendiente', 'en_preparacion', 'en_camino', 'entregado', 'cancelado') NOT NULL DEFAULT 'pendiente',
 total DECIMAL(10,2) NOT NULL DEFAULT 0,
 notas TEXT,
 FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
 ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ============================================
-- 7. TABLA: detalle_pedido (tabla puente)
-- ============================================
CREATE TABLE detalle_pedido (
 id_detalle INT AUTO_INCREMENT PRIMARY KEY,
 id_pedido INT NOT NULL,
 id_pizza INT NOT NULL,
 cantidad INT NOT NULL,
 precio_unitario DECIMAL(10,2) NOT NULL,
 FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
 ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (id_pizza) REFERENCES pizza(id_pizza)
 ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ============================================
-- 8. TABLA: repartidores
-- ============================================
CREATE TABLE repartidor (
 id_repartidor INT AUTO_INCREMENT PRIMARY KEY,
 nombre VARCHAR(100) NOT NULL,
 telefono VARCHAR(20) NOT NULL,
 vehiculo VARCHAR(50),
 disponible BOOLEAN DEFAULT TRUE
);

-- ============================================
-- 9. TABLA: domicilios
-- ============================================
CREATE TABLE domicilio (
 id_domicilio INT AUTO_INCREMENT PRIMARY KEY,
 id_pedido INT NOT NULL UNIQUE,
 id_repartidor INT NOT NULL,
 direccion_entrega TEXT NOT NULL,
 distancia_km DECIMAL(5,2),
 hora_salida DATETIME,
 hora_llegada DATETIME,
 estado ENUM('asignado', 'en_ruta', 'entregado') NOT NULL DEFAULT 'asignado',
 FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido)
 ON UPDATE CASCADE ON DELETE CASCADE,
 FOREIGN KEY (id_repartidor) REFERENCES repartidor(id_repartidor)
 ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ============================================
-- 10. TABLA: historial_precios
-- ============================================
CREATE TABLE historial_precio (
 id_historial INT AUTO_INCREMENT PRIMARY KEY,
 id_pizza INT NOT NULL,
 precio_anterior DECIMAL(10,2) NOT NULL,
 precio_nuevo DECIMAL(10,2) NOT NULL,
 fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY (id_pizza) REFERENCES pizza(id_pizza)
 ON UPDATE CASCADE ON DELETE CASCADE
);

-- --------------------------------------------------------------------------------------------------------------------------------------------------

-- ============================================
-- insercion de datos
-- ============================================

-- ============================================
-- PROVEEDORES
-- ============================================
INSERT INTO proveedor (nombre, telefono, correo) VALUES
('Distribuidora La Harina', '3101234567', 'contacto@laharina.com'),
('Quesos del Valle', '3209876543', 'ventas@quesosvalle.com'),
('Cárnicos Santander', '3156789012', 'pedidos@carnicossantander.com'),
('Vegetales Frescos SAS', '3172345678', 'info@vegetalesfrescos.com');

-- ============================================
-- INGREDIENTES
-- ============================================
INSERT INTO ingrediente (nombre, unidad_medida, stock_actual, stock_minimo, costo_unitario, id_proveedor) VALUES
('Harina de trigo', 'kg', 25.00, 5.00, 2000, 1),
('Queso mozzarella', 'kg', 10.00, 2.00, 12000, 2),
('Pepperoni', 'kg', 8.00, 1.50, 15000, 3),
('Salsa de tomate', 'L', 15.00, 3.00, 3000, 4),
('Champiñones', 'kg', 5.00, 1.00, 8000, 4),
('Pimentón', 'kg', 4.00, 1.00, 5000, 4),
('Aceitunas negras', 'kg', 3.00, 0.50, 7000, 4),
('Jamón', 'kg', 7.00, 1.50, 10000, 3),
('Pollo desmenuzado', 'kg', 6.00, 1.00, 9000, 3),
('Cebolla', 'kg', 5.00, 1.00, 3000, 4),
('Piña', 'kg', 4.00, 1.00, 4000, 4),
('Orégano', 'kg', 1.00, 0.25, 15000, 1),
('Sal', 'kg', 3.00, 0.50, 1000, 1),
('Aceite de oliva', 'L', 4.00, 1.00, 10000, 1);

-- ============================================
-- PIZZAS
-- ============================================
INSERT INTO pizza (nombre, descripcion, precio_venta, tipo ,activa) VALUES
('Pizza Pepperoni', 'Pizza clásica con salsa de tomate, queso mozzarella y pepperoni', 18000.00, 'clasica', TRUE),
('Pizza Hawaiana', 'Pizza con salsa de tomate, queso mozzarella, jamón y piña', 19000.00, 'especial', TRUE),
('Pizza Vegetariana', 'Pizza con salsa de tomate, queso mozzarella, champiñones, pimentón, aceitunas y cebolla', 20000.00, 'vegetariana', TRUE),
('Pizza Pollo BBQ', 'Pizza con salsa BBQ, queso mozzarella, pollo desmenuzado y cebolla', 22000.00, 'especial', TRUE),
('Pizza Mixta', 'Pizza con salsa de tomate, queso mozzarella, pepperoni, jamón y champiñones', 21000.00, 'especial', TRUE),
('Pizza Margarita', 'Pizza clásica con salsa de tomate, queso mozzarella fresca, orégano y aceite de oliva', 17000.00, 'clasica', TRUE);

-- ============================================
-- PIZZA_INGREDIENTES
-- ============================================
INSERT INTO pizza_ingrediente (id_pizza, id_ingrediente, cantidad) VALUES
-- Pepperoni
(1, 4, 0.10), -- salsa de tomate
(1, 2, 0.15), -- mozzarella
(1, 3, 0.08), -- pepperoni
-- Hawaiana
(2, 4, 0.10), -- salsa de tomate
(2, 2, 0.15), -- mozzarella
(2, 8, 0.08), -- jamón
(2, 11, 0.06), -- piña
-- Vegetariana
(3, 4, 0.10), -- salsa de tomate
(3, 2, 0.15), -- mozzarella
(3, 5, 0.06), -- champiñones
(3, 6, 0.05), -- pimentón
(3, 7, 0.04), -- aceitunas
(3, 10, 0.04), -- cebolla
-- Pollo BBQ
(4, 2, 0.15), -- mozzarella
(4, 9, 0.10), -- pollo
(4, 10, 0.04), -- cebolla
-- Mixta
(5, 4, 0.10), -- salsa de tomate
(5, 2, 0.15), -- mozzarella
(5, 3, 0.06), -- pepperoni
(5, 8, 0.06), -- jamón
(5, 5, 0.05), -- champiñones
-- Margarita
(6, 4, 0.10), -- salsa de tomate
(6, 2, 0.18), -- mozzarella (más cantidad)
(6, 12, 0.02), -- orégano
(6, 14, 0.03); -- aceite de oliva

-- ============================================
-- CLIENTES
-- ============================================
INSERT INTO cliente (nombre, telefono, direccion, correo_electronico) VALUES
('Carlos Mendoza', '3001112233', 'Calle 45 # 23-12, Bucaramanga', 'carlos.mendoza@email.com'),
('Ana García', '3102223344', 'Carrera 30 # 15-40, Floridablanca', 'ana.garcia@email.com'),
('Luis Fernández', '3203334455', 'Av. Santander # 10-20, Piedecuesta', NULL),
('María Torres', '3154445566', 'Calle 60 # 35-50, Bucaramanga', 'maria.torres@email.com'),
('Pedro Ramírez', '3175556677', 'Carrera 22 # 8-30, Girón', NULL),
('Sofía López', '3016667788', 'Calle 100 # 12-34, Floridablanca', 'sofia.lopez@email.com');

-- ============================================
-- REPARTIDORES
-- ============================================
INSERT INTO repartidor (nombre, telefono, vehiculo, disponible) VALUES
('Jorge Martínez', '3117778899', 'Moto Boxer 150', TRUE),
('Andrés Pérez', '3138889900', 'Moto TVS Rider 125', TRUE),
('Camilo Rueda', '3149990011', 'Bicicleta', TRUE),
('David Silva', '3160001122', 'Moto Suzuki GN 125', FALSE);

-- ============================================
-- PEDIDOS
-- ============================================
INSERT INTO pedido (id_cliente, metodo_pago, estado, notas) VALUES
(1, 'efectivo', 'entregado', 'Llamar antes de llegar'),
(2, 'tarjeta', 'entregado', NULL),
(3, 'efectivo', 'en_camino', 'Tocar el timbre 2 veces'),
(4, 'app', 'en_preparacion', 'Sin cebolla por favor'),
(5, 'efectivo', 'pendiente', NULL),
(6, 'tarjeta', 'entregado', 'Extra de orégano'),
(1, 'efectivo', 'entregado', NULL),
(2, 'tarjeta', 'cancelado', 'Cancelado por el cliente');


-- ============================================
-- DETALLE_PEDIDO
-- ============================================
INSERT INTO detalle_pedido (id_pedido, id_pizza, cantidad, precio_unitario) VALUES
(1, 1, 1, 18000.00), -- Pepperoni
(2, 2, 1, 19000.00), -- Hawaiana
(3, 4, 1, 22000.00), -- Pollo BBQ
(4, 4, 1, 22000.00), -- Pollo BBQ
(5, 5, 1, 21000.00), -- Mixta
(6, 6, 1, 17000.00), -- Margarita
(7, 5, 1, 21000.00); -- Mixta

-- ============================================
-- DOMICILIOS
-- ============================================
INSERT INTO domicilio (id_pedido, id_repartidor, direccion_entrega, distancia_km, hora_salida, hora_llegada, estado) VALUES
(1, 1, 'Calle 45 # 23-12, Bucaramanga', 3.50, '2026-07-10 19:30:00', '2026-07-10 19:55:00', 'entregado'),
(2, 2, 'Carrera 30 # 15-40, Floridablanca', 1.80, '2026-07-10 20:00:00', '2026-07-10 20:20:00', 'entregado'),
(3, 3, 'Av. Santander # 10-20, Piedecuesta', 8.20, '2026-07-10 21:15:00', NULL, 'en_ruta'),
(6, 1, 'Calle 100 # 12-34, Floridablanca', 2.10, '2026-07-10 20:30:00', '2026-07-10 20:50:00', 'entregado'),
(7, 4, 'Calle 45 # 23-12, Bucaramanga', 3.50, '2026-07-10 21:00:00', '2026-07-10 21:25:00', 'entregado');

-- =======================
-- actualizacion del total de pedido
-- ========================
UPDATE pedido SET total = calcular_total_pedido(id_pedido);