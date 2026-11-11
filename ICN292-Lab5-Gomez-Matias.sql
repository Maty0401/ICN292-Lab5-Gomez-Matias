DROP DATABASE IF EXISTS andesbike;
CREATE DATABASE andesbike
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;
USE andesbike;

CREATE TABLE tiendas (
    id_tienda  INT          NOT NULL AUTO_INCREMENT,
    nombre     VARCHAR(60)  NOT NULL,
    comuna     VARCHAR(50)  NOT NULL,
    CONSTRAINT pk_tiendas        PRIMARY KEY (id_tienda),
    CONSTRAINT uq_tiendas_nombre UNIQUE (nombre)
) ENGINE = InnoDB;

CREATE TABLE bicicletas (
    id_bicicleta INT            NOT NULL AUTO_INCREMENT,
    modelo       VARCHAR(60)    NOT NULL,
    categoria    ENUM('Eléctrica','Infantil','Montaña','Ruta','Urbana') NOT NULL,
    precio       DECIMAL(10,2)  NOT NULL,
    CONSTRAINT pk_bicicletas         PRIMARY KEY (id_bicicleta),
    CONSTRAINT uq_bicicletas_modelo  UNIQUE (modelo),
    CONSTRAINT ck_bicicletas_precio  CHECK (precio > 0)
) ENGINE = InnoDB;


CREATE TABLE vendedores (
    id_vendedor   INT          NOT NULL AUTO_INCREMENT,
    nombre        VARCHAR(80)  NOT NULL,
    id_tienda     INT          NULL,
    fecha_ingreso DATE         NOT NULL,
    CONSTRAINT pk_vendedores  PRIMARY KEY (id_vendedor),
    CONSTRAINT fk_vendedores_tienda
        FOREIGN KEY (id_tienda) REFERENCES tiendas (id_tienda)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE = InnoDB;

CREATE TABLE ventas (
    id_venta     INT   NOT NULL AUTO_INCREMENT,
    id_vendedor  INT   NOT NULL,
    id_bicicleta INT   NOT NULL,
    fecha        DATE  NOT NULL,
    unidades     INT   NOT NULL,
    CONSTRAINT pk_ventas           PRIMARY KEY (id_venta),
    CONSTRAINT ck_ventas_unidades  CHECK (unidades > 0),
    CONSTRAINT fk_ventas_vendedor
        FOREIGN KEY (id_vendedor) REFERENCES vendedores (id_vendedor)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT fk_ventas_bicicleta
        FOREIGN KEY (id_bicicleta) REFERENCES bicicletas (id_bicicleta)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;

INSERT INTO tiendas (id_tienda, nombre, comuna) VALUES
    (1, 'Andes Providencia', 'Providencia'),
    (2, 'Andes Maipú',       'Maipú'),
    (3, 'Andes Concepción',  'Concepción'),
    (4, 'Andes La Serena',   'La Serena');

INSERT INTO bicicletas (id_bicicleta, modelo, categoria, precio) VALUES
    (1, 'Cordillera 29',  'Montaña',   549990.00),
    (2, 'Ruta Austral',   'Ruta',      899990.00),
    (3, 'Urbana Pro',     'Urbana',    329990.00),
    (4, 'Pequeño Andes',  'Infantil',  149990.00),
    (5, 'Volt City',      'Eléctrica', 1249990.00),
    (6, 'Trail Master',   'Montaña',   749990.00),
    (7, 'Urbana Lite',    'Urbana',    229990.00),
    (8, 'Sprint R7',      'Ruta',      1099990.00);

INSERT INTO vendedores (id_vendedor, nombre, id_tienda, fecha_ingreso) VALUES
    (1, 'Camila Ortiz',    1,    '2024-06-20'),
    (2, 'Diego Fuentes',   1,    '2024-01-15'),
    (3, 'Javiera Soto',    2,    '2023-07-24'),
    (4, 'Matías Herrera',  2,    '2024-01-15'),
    (5, 'Paula Riquelme',  3,    '2022-11-02'),
    (6, 'Ignacio Vera',    3,    '2024-08-19'),
    (7, 'Fernanda Lillo',  1,    '2025-02-03'),
    (8, 'Rubén Castro',    NULL, '2025-06-10');

INSERT INTO ventas (id_vendedor, id_bicicleta, fecha, unidades) VALUES
    (1, 1, '2025-03-04', 2),
    (1, 3, '2025-03-18', 1),
    (1, 5, '2025-04-02', 1),
    (2, 2, '2025-03-04', 1),
    (2, 1, '2025-04-11', 3),
    (2, 7, '2025-05-06', 2),
    (3, 4, '2025-03-21', 4),
    (3, 3, '2025-04-15', 2),
    (3, 6, '2025-05-20', 1),
    (4, 1, '2025-03-27', 1),
    (4, 5, '2025-05-09', 2),
    (5, 2, '2025-04-08', 1),
    (5, 6, '2025-04-23', 2),
    (5, 4, '2025-06-02', 5),
    (6, 3, '2025-05-13', 3),
    (6, 7, '2025-06-17', 1),
    (6, 1, '2025-06-24', 2),
    (1, 6, '2025-06-30', 1);


---- CONSULTAS

SELECT  v.nombre                AS vendedor,
        COUNT(ve.id_venta)      AS cantidad_ventas
FROM       vendedores v
LEFT JOIN  ventas     ve  ON ve.id_vendedor = v.id_vendedor
GROUP BY   v.id_vendedor, v.nombre
ORDER BY   cantidad_ventas DESC, v.nombre ASC;



SELECT  t.nombre                          AS tienda,
        COUNT(ve.id_venta)                AS ventas_registradas,
        COALESCE(SUM(ve.unidades), 0)     AS unidades_vendidas
FROM       tiendas    t
LEFT JOIN  vendedores v   ON v.id_tienda    = t.id_tienda
LEFT JOIN  ventas     ve  ON ve.id_vendedor = v.id_vendedor
GROUP BY   t.id_tienda, t.nombre
ORDER BY   unidades_vendidas DESC;


SELECT  t.id_tienda,
        t.nombre   AS tienda,
        t.comuna
FROM       tiendas    t
LEFT JOIN  vendedores v  ON v.id_tienda = t.id_tienda
WHERE      v.id_vendedor IS NULL
ORDER BY   t.nombre;


SELECT  b.modelo,
        b.categoria,
        b.precio
FROM       bicicletas b
LEFT JOIN  ventas     ve
       ON  ve.id_bicicleta = b.id_bicicleta
      AND  ve.fecha >= '2025-06-01'
      AND  ve.fecha  < '2025-07-01'
WHERE      ve.id_venta IS NULL
ORDER BY   b.modelo;


SELECT  v.nombre                                      AS vendedor,
        COALESCE(t.nombre, '(sin tienda asignada)')   AS tienda,
        v.fecha_ingreso
FROM       vendedores v
LEFT JOIN  tiendas    t   ON t.id_tienda    = v.id_tienda
LEFT JOIN  ventas     ve  ON ve.id_vendedor = v.id_vendedor
WHERE      ve.id_venta IS NULL
ORDER BY   v.nombre;


SELECT  t.nombre          AS tienda,
        a.nombre          AS vendedor_mas_antiguo,
        a.fecha_ingreso   AS ingreso_mas_antiguo,
        b.nombre          AS vendedor_mas_nuevo,
        b.fecha_ingreso   AS ingreso_mas_nuevo
FROM  vendedores a
JOIN  vendedores b
   ON  a.id_tienda = b.id_tienda
  AND (a.fecha_ingreso <  b.fecha_ingreso
   OR (a.fecha_ingreso =  b.fecha_ingreso AND a.id_vendedor < b.id_vendedor))
JOIN  tiendas t ON t.id_tienda = a.id_tienda
ORDER BY t.nombre, a.fecha_ingreso, b.fecha_ingreso;


SELECT  t.nombre                          AS tienda,
        SUM(ve.unidades * b.precio)       AS monto_total
FROM  tiendas    t
JOIN  vendedores v   ON v.id_tienda     = t.id_tienda
JOIN  ventas     ve  ON ve.id_vendedor  = v.id_vendedor
JOIN  bicicletas b   ON b.id_bicicleta  = ve.id_bicicleta
WHERE     b.categoria IN ('Montaña', 'Ruta')
GROUP BY  t.id_tienda, t.nombre
HAVING    monto_total > 2000000
ORDER BY  monto_total DESC;


SELECT  b.modelo,
        b.precio
FROM    bicicletas b
WHERE   b.precio > (SELECT AVG(precio) FROM bicicletas)
ORDER BY b.precio DESC;


SELECT  v.nombre            AS vendedor,
        AVG(ve.unidades)    AS promedio_unidades
FROM  vendedores v
JOIN  ventas     ve  ON ve.id_vendedor = v.id_vendedor
GROUP BY  v.id_vendedor, v.nombre
HAVING    AVG(ve.unidades) > (SELECT AVG(unidades) FROM ventas)
ORDER BY  promedio_unidades DESC, v.nombre ASC;


SELECT  v.nombre                       AS vendedor,
        SUM(ve.unidades * b.precio)    AS monto_total
FROM       vendedores v
LEFT JOIN  ventas     ve  ON ve.id_vendedor  = v.id_vendedor
LEFT JOIN  bicicletas b   ON b.id_bicicleta  = ve.id_bicicleta
GROUP BY   v.id_vendedor, v.nombre
ORDER BY   monto_total DESC;