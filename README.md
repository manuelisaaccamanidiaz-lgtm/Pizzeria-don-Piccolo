<h1 align="center">🍕 Pizzería Don Piccolo</h1>

<p align="center">
Sistema de base de datos relacional en MySQL 8.0 para la gestión de pedidos, domicilios, inventario y clientes de una pizzería.
</p>

<p align="center">
    <img src="https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white">
    <img src="https://img.shields.io/badge/Estado-En%20desarrollo-yellow">
    <img src="https://img.shields.io/badge/Licencia-Académica-lightgrey">
</p>

---

## 📑 Tabla de contenido

- [Descripción del proyecto](#-descripción-del-proyecto)
- [Objetivos](#-objetivos)
- [Tecnologías utilizadas](#-tecnologías-utilizadas)
- [Arquitectura del proyecto](#-arquitectura-del-proyecto)
- [Modelo de base de datos](#-modelo-de-base-de-datos)
- [Relaciones principales](#-relaciones-principales)
- [Normalización](#-normalización)
- [Scripts incluidos](#-scripts-incluidos)
- [Funciones](#-funciones)
- [Procedimientos almacenados](#-procedimientos-almacenados)
- [Triggers](#-triggers)
- [Vistas](#-vistas)
- [Consultas importantes](#-consultas-importantes)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [Instalación](#-instalación)
- [Pruebas de funciones, procedimientos y vistas](#-pruebas-de-funciones-procedimientos-y-vistas)
- [Capturas](#-capturas)
- [Ejemplos de uso](#-ejemplos-de-uso)
- [Buenas prácticas implementadas](#-buenas-prácticas-implementadas)
- [Trabajo futuro](#-trabajo-futuro)
- [Conclusiones](#-conclusiones)
- [Autor](#-autor)

---

## 📖 Descripción del proyecto

**Problema:** Pizzería Don Piccolo gestiona sus pedidos y domicilios de forma manual, lo que provoca retrasos en la atención al cliente y errores en el registro de información.

**Contexto:** El negocio necesita controlar, en un solo sistema, el ciclo completo de una venta: desde que el cliente hace el pedido hasta que el repartidor lo entrega y se recibe el pago.

**Solución propuesta:** Una base de datos relacional en MySQL 8.0 que centraliza clientes, catálogo de pizzas e ingredientes, pedidos, domicilios, repartidores y pagos, apoyada en funciones, procedimientos almacenados, triggers y vistas que automatizan cálculos y consultas frecuentes del negocio.

**Alcance:** El proyecto cubre el diseño del esquema, la carga de datos de prueba y la lógica de negocio a nivel de motor de base de datos (MySQL). No incluye una aplicación cliente (web, móvil o de escritorio); esta puede construirse sobre el esquema aquí definido.

> 💡 **Nota:** Este README documenta el proyecto **tal como está implementado actualmente** en los scripts `.sql`. Las funcionalidades del enunciado que aún no están en el código se listan en la sección [Trabajo futuro](#-trabajo-futuro).

---

## 🎯 Objetivos

**Objetivo general**

Diseñar e implementar un sistema de base de datos relacional en MySQL que permita gestionar el proceso completo de venta de pizzas y domicilios, desde el registro del pedido hasta su entrega y pago.

**Objetivos específicos**

- Modelar entidades del negocio (clientes, pizzas, ingredientes, pedidos, repartidores, domicilios) respetando las reglas de integridad referencial.
- Automatizar el descuento de inventario y el registro de auditoría mediante triggers.
- Encapsular cálculos recurrentes (total del pedido, ganancia diaria) en funciones reutilizables.
- Facilitar reportes de negocio mediante vistas y consultas SQL optimizadas.

---

## 🛠 Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| **MySQL 8.0** | Motor de base de datos relacional donde se implementa todo el esquema y la lógica de negocio. |
| **SQL (DDL / DML / DCL)** | Definición de tablas, inserción de datos de prueba y consultas. |
| **Funciones y procedimientos almacenados (MySQL)** | Lógica de negocio ejecutada del lado del servidor. |
| **Triggers (MySQL)** | Automatización de eventos (stock, auditoría, disponibilidad). |
| **Git / GitHub** | Control de versiones y publicación del repositorio. |
| **Markdown** | Documentación del proyecto (este README). |

---

## 🏗 Arquitectura del proyecto

El proyecto sigue una arquitectura **100% del lado de la base de datos** (no incluye backend ni frontend). Los scripts están organizados por responsabilidad, no por entidad:

```
database.sql    → estructura (DDL) + datos de prueba (DML)
funciones.sql   → funciones y el procedimiento almacenado
triggers.sql    → automatizaciones sobre INSERT/UPDATE
vistas.sql      → reportes reutilizables
consultas.sql   → consultas de negocio (SELECT puros)
```

Las tablas se agrupan conceptualmente en cuatro capas:

- **Catálogo:** `proveedor`, `ingrediente`, `pizza`, `pizza_ingrediente`.
- **Clientes y ventas:** `cliente`, `pedido`, `detalle_pedido`.
- **Logística:** `repartidor`, `domicilio`.
- **Auditoría:** `historial_precio`.

---

## 🗄 Modelo de base de datos

| Tabla | Descripción |
|---|---|
| `cliente` | Almacena los datos de contacto de cada cliente (nombre, teléfono, dirección, correo) y su fecha de registro. |
| `proveedor` | Catálogo de proveedores que abastecen los ingredientes. |
| `ingrediente` | Insumos usados en las pizzas, con stock actual, stock mínimo y costo unitario. |
| `pizza` | Catálogo de pizzas disponibles, con precio de venta y estado (activa/inactiva).El proyecto maneja un único tamaño de pizza por decisión de alcance; por eso no se modeló un atributo tamaño, ya que sería constante en todas las filas y no aportaría valor analítico. |
| `pizza_ingrediente` | Tabla puente que define la receta de cada pizza: qué ingredientes lleva y en qué cantidad. |
| `pedido` | Cabecera de cada pedido: cliente, fecha, método de pago, estado y total. |
| `detalle_pedido` | Líneas del pedido: qué pizzas y en qué cantidad se pidieron, con su precio unitario. |
| `repartidor` | Datos del repartidor: nombre, teléfono, vehículo y disponibilidad,se optó por agrupar el desempeño por rango de distancia en lugar de una zona fija, ya que refleja mejor el esfuerzo real de entrega. |
| `domicilio` | Información logística del envío: repartidor asignado, dirección, distancia, horas de salida/llegada y estado. |
| `historial_precio` | Registro de auditoría con el precio anterior y nuevo cada vez que cambia el precio de una pizza. |

---

## 🔗 Relaciones principales

- Un **cliente** puede tener muchos **pedidos** (1:N), pero un pedido pertenece a un único cliente.
- Un **pedido** se descompone en varias líneas dentro de `detalle_pedido` (1:N), y cada línea apunta a una **pizza** del catálogo.
- Cada **pizza** tiene su receta definida en `pizza_ingrediente`, una relación N:M con `ingrediente` (una pizza usa varios ingredientes, y un ingrediente se usa en varias pizzas).
- Cada **ingrediente** pertenece a un **proveedor** (N:1).
- Un **pedido** genera como máximo un **domicilio**, y viceversa: la columna `id_pedido` en `domicilio` es `UNIQUE`, por lo que la relación es estrictamente **1:1**.
- Un **domicilio** es atendido por un **repartidor** (N:1): un repartidor puede tener muchos domicilios asignados a lo largo del tiempo.
- Cada vez que cambia el precio de una **pizza**, se genera un registro en `historial_precio` (1:N), sin intervención manual.

En términos de flujo: el cliente genera un `pedido` → el pedido se detalla en `detalle_pedido` (con sus pizzas) → al insertar el detalle, se descuenta automáticamente el `stock` de los ingredientes → se crea un `domicilio` asociado y se le asigna un `repartidor` → cuando el repartidor entrega el pedido, se actualiza el estado del `domicilio` y del `pedido`, y el repartidor vuelve a quedar disponible.

---

## 🧩 Normalización

| Forma normal | ¿Se cumple? | Justificación |
|---|---|---|
| **1FN** | ✅ Sí | Todos los atributos son atómicos; no existen listas ni grupos repetitivos dentro de una misma columna (por ejemplo, las pizzas de un pedido se separan en filas de `detalle_pedido`, no en una sola celda). |
| **2FN** | ✅ Sí | La mayoría de tablas usan una clave primaria simple (`id_x`), por lo que la 2FN se cumple de forma trivial. En la tabla con clave compuesta (`pizza_ingrediente`), el atributo `cantidad` depende de ambas columnas de la clave (`id_pizza` + `id_ingrediente`), no de una sola. |
| **3FN** | ✅ Sí (con una excepción intencional) | No hay dependencias transitivas relevantes. La única excepción es `pedido.total`, que es un valor calculado y almacenado (redundante respecto a `detalle_pedido` + `domicilio`). Es una decisión de diseño habitual para evitar recalcular el total en cada consulta, no un error de modelado. |
| **BCNF** | ✅ Sí | Todo determinante de una dependencia funcional es una clave candidata; no hay atributos no clave que determinen a otros atributos clave. |
| **4FN** | ➖ No aplica | No existen dependencias multivaluadas independientes en el modelo actual. |

---

## 📂 Scripts incluidos

| Archivo | Descripción |
|---|---|
| `database.sql` | Creación de la base de datos, las 10 tablas y sus llaves foráneas, más los datos de prueba (proveedores, ingredientes, pizzas, clientes, repartidores, pedidos y domicilios). |
| `funciones.sql` | Contiene las dos funciones de negocio (`calcular_total_pedido`, `calcular_ganancia_diaria`) y el procedimiento almacenado `cambiar_estado`. |
| `triggers.sql` | Los tres triggers de automatización: descuento de stock, auditoría de precios y liberación de repartidores. |
| `vistas.sql` | Las tres vistas de reporte: resumen por cliente, desempeño de repartidores y stock bajo mínimo. |
| `consultas.sql` | Las siete consultas de negocio solicitadas (BETWEEN, GROUP BY, JOIN, AVG, HAVING, LIKE y subconsulta). |

---

## ⚙ Funciones

### `calcular_total_pedido(p_id_pedido INT)`

- **Propósito:** calcula el total real de un pedido sumando el valor de las pizzas, el costo de envío y el IVA.
- **Parámetros:** `p_id_pedido` — identificador del pedido.
- **Retorno:** `DECIMAL(10,2)` con el total final.
- **Lógica:** suma `cantidad * precio_unitario` de `detalle_pedido`, agrega `distancia_km * 1000` como costo de envío, y aplica un IVA del 19 % sobre ese subtotal.
- **Ejemplo de uso:**
  ```sql
  SELECT calcular_total_pedido(1);
  ```

### `calcular_ganancia_diaria(p_fecha DATE)`

- **Propósito:** obtiene la ganancia neta de un día específico (ventas entregadas menos costo de los ingredientes usados).
- **Parámetros:** `p_fecha` — fecha a evaluar.
- **Retorno:** `DECIMAL(10,2)` con la ganancia del día.
- **Lógica:** suma el `total` de los pedidos con estado `entregado` en esa fecha, y le resta el costo de los ingredientes consumidos (`cantidad × costo_unitario`) en esos mismos pedidos.
- **Ejemplo de uso:**
  ```sql
  SELECT calcular_ganancia_diaria('2026-07-10');
  ```

---

## 🧮 Procedimientos almacenados

### `cambiar_estado(IN p_id_pedido INT, IN p_hora_llegada DATETIME)`

- **Qué hace:** registra la hora de llegada del domicilio, marca el `domicilio` como `entregado` y actualiza el `pedido` correspondiente al mismo estado.
- **Cuándo se usa:** se invoca cuando el repartidor confirma que hizo la entrega (por ejemplo, desde una futura app o directamente por un operador).
- **Parámetros:** `p_id_pedido` (pedido a actualizar), `p_hora_llegada` (hora exacta de entrega).
- **Ejemplo de uso:**
  ```sql
  CALL cambiar_estado(3, '2026-07-13 20:15:00');
  ```

> ⚠️ **Nota:** en el enunciado se describe como un cambio *automático*, pero solicita un procedimiento que debe **llamarse explícitamente**; no se dispara solo. Si se quiere automatizar por completo, se podría reemplazar por un trigger `BEFORE UPDATE` sobre `domicilio`.

---

## ⚡ Triggers

### `descuento_stock`

- **Se ejecuta:** `AFTER INSERT` sobre `detalle_pedido`.
- **Evento que escucha:** la creación de una nueva línea de pedido (se pidió una pizza).
- **Qué modifica:** resta de `ingrediente.stock_actual` la cantidad de cada insumo que usa esa pizza, multiplicada por la cantidad pedida.
- **Por qué es útil:** mantiene el inventario sincronizado sin depender de que alguien lo actualice manualmente.

### `auditoria`

- **Se ejecuta:** `AFTER UPDATE` sobre `pizza`.
- **Evento que escucha:** cualquier actualización sobre una fila de `pizza`.
- **Qué modifica:** inserta un registro en `historial_precio` con el precio anterior y el nuevo.
- **Por qué es útil:** deja trazabilidad de cambios de precio para auditorías o análisis histórico.

### `repartidor_disponible`

- **Se ejecuta:** `AFTER UPDATE` sobre `domicilio`.
- **Evento que escucha:** cambios de estado en un domicilio.
- **Qué modifica:** si el nuevo estado es `entregado`, intenta actualizar al repartidor asociado para dejarlo disponible de nuevo.
- **Por qué es útil:** evita que un repartidor quede "atascado" como ocupado después de terminar una entrega.

---

## 👁 Vistas

### `pedido_cliente`

Resume, por cada cliente, cuántos pedidos ha hecho y cuánto ha gastado en total. Útil para identificar clientes frecuentes o de alto valor.

### `desempeño_repartidor`

Muestra, por repartidor, el número de entregas completadas, el tiempo promedio de entrega (en minutos) y la distancia promedio recorrida.

### `stock_minimo`

Lista los ingredientes cuyo `stock_actual` está por debajo del `stock_minimo`, junto con la diferencia. Pensada para alertar sobre reabastecimiento.

---

## 🔍 Consultas importantes

| Consulta | Propósito |
|---|---|
| Clientes con pedidos entre dos fechas | Filtra pedidos realizados dentro de un rango de fechas usando `BETWEEN`. |
| Pizzas más vendidas | Cuenta cuántas veces se ha vendido cada pizza y las ordena de mayor a menor. |
| Pedidos por repartidor | Cuenta cuántos domicilios ha atendido cada repartidor. |
| Promedio de entrega por rango de distancia | Agrupa los domicilios en rangos de distancia (0-3 km, 3-5 km, 5-10 km, +10 km) y calcula el tiempo promedio de entrega en cada rango. |
| Clientes que gastaron más de un monto | Filtra clientes cuyo gasto total supera un valor usando `HAVING`. |
| Búsqueda parcial de nombre de pizza | Busca pizzas cuyo nombre coincide parcialmente con un texto, usando `LIKE`. |
| Clientes frecuentes del mes | Subconsulta que identifica clientes con más de 5 pedidos en el mes actual. |

---

## 🌳 Estructura del proyecto

```
Pizzeria_Don_Piccolo
│
├── database.sql
├── funciones.sql
├── triggers.sql
├── vistas.sql
├── consultas.sql
├── README.md
└── assets/
    └── banner.png
```

---

## 🚀 Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/manuelisaaccamanidiaz-lgtm/Pizzer-a_don_Piccolo.git
   cd Pizzer-a_don_Piccolo
   ```

2. **Abrir una consola de MySQL** (versión 8.0 o superior)
   ```bash
   mysql -u root -p
   ```

3. **Ejecutar los scripts en este orden exacto** (el orden importa por las dependencias entre tablas y objetos):
   ```sql
   SOURCE database.sql;
   SOURCE funciones.sql;
   SOURCE triggers.sql;
   SOURCE vistas.sql;
   SOURCE consultas.sql;
   ```

4. **Verificar que todo se creó correctamente**
   ```sql
   USE pizzeria_don_piccolo;
   SHOW TABLES;
   SHOW FUNCTION STATUS WHERE Db = 'pizzeria_don_piccolo';
   SHOW PROCEDURE STATUS WHERE Db = 'pizzeria_don_piccolo';
   SHOW TRIGGERS;
   ```

---

## 🧪 Pruebas de funciones, procedimientos y vistas

Con la base de datos y los datos de prueba ya cargados, estas sentencias permiten comprobar que cada objeto funciona correctamente:

```sql
USE pizzeria_don_piccolo;

-- 1. Función: calcular_total_pedido
SELECT calcular_total_pedido(1) AS total_pedido_1;

-- 2. Función: calcular_ganancia_diaria
SELECT calcular_ganancia_diaria('2026-07-14') AS ganancia_14_julio;

-- 3. Procedimiento: cambiar_estado
CALL cambiar_estado(3, NOW());
SELECT id_pedido, estado FROM pedido WHERE id_pedido = 3;
SELECT id_domicilio, estado, hora_llegada FROM domicilio WHERE id_pedido = 3;

-- 4. Vista: pedido_cliente
SELECT * FROM pedido_cliente;

-- 5. Vista: desempeño_repartidor
SELECT * FROM desempeño_repartidor;

-- 6. Vista: stock_minimo
SELECT * FROM stock_minimo;
```

> 💡 **Tip:** el pedido 3 es el único que está `en_ruta` (no entregado todavía) en los datos de prueba, así que es el candidato ideal para probar `cambiar_estado` y ver cómo cambian tanto `domicilio` como `pedido` sin tocar registros que ya estaban `entregado`.

---

## 📸 Capturas

### modelo logico

<a href="https://ibb.co/TD2d74Rj"><img src="https://i.ibb.co/SDyGMt0Y/imagen-2026-07-13-194453504.png" alt="imagen-2026-07-13-194453504" border="0"></a>

### creacion de tablas e inserción de datos

<a href="https://ibb.co/HDb4mRQW"><img src="https://i.ibb.co/ccZ3zRdG/imagen-2026-07-13-194740835.png" alt="imagen-2026-07-13-194740835" border="0"></a>

### consultas
> Clientes con pedidos entre dos fechas (BETWEEN).

<a href="https://ibb.co/RkjSX5sv"><img src="https://i.ibb.co/0RsX0w6D/imagen-2026-07-13-195027478.png" alt="imagen-2026-07-13-195027478" border="0"></a>

> Pizzas más vendidas (GROUP BY y COUNT).

<a href="https://imgbb.com/"><img src="https://i.ibb.co/3mGDf03W/imagen-2026-07-13-195140822.png" alt="imagen 2026 07 13 195140822" border="0"></a>

> Pedidos por repartidor (JOIN).

<a href="https://imgbb.com/"><img src="https://i.ibb.co/jvw0CjKX/imagen-2026-07-13-195214230.png" alt="imagen 2026 07 13 195214230" border="0"></a>

> Promedio de entrega por zona (AVG y JOIN).

<a href="https://imgbb.com/"><img src="https://i.ibb.co/yFj8Htkp/imagen-2026-07-13-195253167.png" alt="imagen 2026 07 13 195253167" border="0"></a>

> Clientes que gastaron más de un monto (HAVING).

<a href="https://imgbb.com/"><img src="https://i.ibb.co/G44TM7gq/imagen-2026-07-13-195326919.png" alt="imagen 2026 07 13 195326919" border="0"></a>

> Búsqueda por coincidencia parcial de nombre de pizza (LIKE).

<a href="https://imgbb.com/"><img src="https://i.ibb.co/ZzMT0LRk/imagen-2026-07-13-195535778.png" alt="imagen 2026 07 13 195535778" border="0"></a>

> Subconsulta para obtener los clientes frecuentes (más de 5 pedidos mensuales).

<a href="https://imgbb.com/"><img src="https://i.ibb.co/fzh922bc/imagen-2026-07-13-195436776.png" alt="imagen 2026 07 13 195436776" border="0"></a>

### ejecución de funciones
> 1. Función: calcular_total_pedido

<a href="https://imgbb.com/"><img src="https://i.ibb.co/60c0kFDk/imagen-2026-07-14-070932123.png" alt="imagen 2026 07 14 070932123" border="0"></a>

> 2. Función: calcular_ganancia_diaria

<a href="https://imgbb.com/"><img src="https://i.ibb.co/vx7hpyGh/imagen-2026-07-14-071025845.png" alt="imagen 2026 07 14 071025845" border="0"></a>

### ejecución de procedimientos
> 3. Procedimiento: cambiar_estado

<a href="https://imgbb.com/"><img src="https://i.ibb.co/S4mwbcZv/imagen-2026-07-14-071233808.png" alt="imagen 2026 07 14 071233808" border="0"></a>

<a href="https://imgbb.com/"><img src="https://i.ibb.co/5gJJN0vh/imagen-2026-07-14-071259562.png" alt="imagen 2026 07 14 071259562" border="0"></a>

### disparo de triggers

<a href="https://ibb.co/bgJP7MN4"><img src="https://i.ibb.co/tMX43TY0/imagen-2026-07-14-071429242.png" alt="imagen-2026-07-14-071429242" border="0"></a>

### resultado de vistas
> 4. Vista: pedido_cliente

<a href="https://imgbb.com/"><img src="https://i.ibb.co/1fc0pbWw/Captura-de-pantalla-2026-07-14-071513.png" alt="Captura de pantalla 2026 07 14 071513" border="0"></a>

> 5. Vista: desempeño_repartidor

<a href="https://imgbb.com/"><img src="https://i.ibb.co/HDvcsX2N/imagen-2026-07-14-071650140.png" alt="imagen 2026 07 14 071650140" border="0"></a>

> 6. Vista: stock_minimo

<a href="https://imgbb.com/"><img src="https://i.ibb.co/RkmnwZs7/imagen-2026-07-14-071730513.png" alt="imagen 2026 07 14 071730513" border="0"></a>


---

## 💻 Ejemplos de uso

```sql
-- Calcular el total de un pedido puntual
SELECT calcular_total_pedido(3);

-- Ver la ganancia neta de un día
SELECT calcular_ganancia_diaria('2026-07-10');

-- Consultar el resumen de gasto por cliente
SELECT * FROM pedido_cliente;

-- Revisar ingredientes que necesitan reabastecimiento
SELECT * FROM stock_minimo;
```

---

## ✅ Buenas prácticas implementadas

- **Normalización:** el esquema evita redundancia innecesaria, salvo el campo `total` en `pedido`, que es una decisión consciente de diseño (ver [Normalización](#-normalización)).
- **Integridad referencial:** todas las relaciones usan `FOREIGN KEY` con políticas explícitas de `ON UPDATE` / `ON DELETE` (`CASCADE`, `RESTRICT`, `SET NULL`) según el nivel de dependencia de cada entidad.
- **Modularización:** cada tipo de objeto de base de datos vive en su propio archivo (`database.sql`, `funciones.sql`, `triggers.sql`, `vistas.sql`, `consultas.sql`).
- **Nombres consistentes:** convención singular en español para tablas (`cliente`, `pedido`, `pizza`) y prefijo `id_` para todas las llaves.
- **Separación de scripts:** estructura, lógica de negocio y consultas están desacopladas, lo que facilita mantenimiento y control de versiones.
- **Uso de restricciones:** `UNIQUE` en correos electrónicos y en la relación pedido-domicilio; `ENUM` para campos de dominio cerrado (estado, método de pago).

---

## 🔮 Trabajo futuro

Estas funcionalidades aparecen en el enunciado del proyecto pero **aún no están implementadas** en el código actual:

- **Zona asignada al repartidor:** el enunciado pide registrar la zona de cada repartidor; la tabla `repartidor` actual no tiene esa columna (las consultas y vistas actuales aproximan "zona" agrupando por rango de distancia, no por una zona real).
- **Tipo de pizza:** el enunciado pide clasificar cada pizza como vegetariana, especial o clásica; la tabla `pizza` no incluye ese campo todavía.
- **Método de pago "app":** el enunciado menciona pagos por app como opción; el `ENUM` de `pedido.metodo_pago` solo contempla `efectivo`, `tarjeta` y `transferencia`.
- **Automatización completa del cambio de estado por entrega:** actualmente requiere llamar manualmente a `cambiar_estado`; podría convertirse en un trigger disparado directamente por la actualización de `hora_llegada`.

---

## 🏁 Conclusiones

El proyecto cubre de forma sólida el núcleo del enunciado: un esquema normalizado con integridad referencial completa, funciones que encapsulan cálculos de negocio, triggers que automatizan inventario y auditoría, y vistas y consultas que responden a las preguntas reales del negocio. Los puntos pendientes son puntuales y bien delimitados, lo que deja una base clara para una siguiente iteración del proyecto.

---

## 👤 Autor

**Manuel Isaac Camaño Díaz**
GitHub: [@manuelisaaccamanidiaz-lgtm](https://github.com/manuelisaaccamanidiaz-lgtm)
