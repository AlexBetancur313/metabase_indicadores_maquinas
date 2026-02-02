-- ============================================
-- SISTEMA DE PRODUCCIÓN MULTINACIONAL
-- Base de Datos: PostgreSQL
-- ============================================

-- Limpiar base de datos anterior
DROP TABLE IF EXISTS produccion_global CASCADE;
DROP TABLE IF EXISTS maquinas CASCADE;
DROP TABLE IF EXISTS plantas CASCADE;
DROP TABLE IF EXISTS productos CASCADE;
DROP TABLE IF EXISTS paises CASCADE;
DROP TABLE IF EXISTS turnos CASCADE;

-- ============================================
-- 1. TABLA DE PAÍSES
-- ============================================
CREATE TABLE paises (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    codigo_iso CHAR(2) NOT NULL,
    region VARCHAR(30) NOT NULL
);

INSERT INTO paises (nombre, codigo_iso, region) VALUES
('Colombia', 'CO', 'América Latina'),
('México', 'MX', 'América Latina'),
('Brasil', 'BR', 'América Latina'),
('Estados Unidos', 'US', 'América del Norte'),
('España', 'ES', 'Europa');

-- ============================================
-- 2. TABLA DE PLANTAS/SEDES
-- ============================================
CREATE TABLE plantas (
    id SERIAL PRIMARY KEY,
    id_pais INTEGER REFERENCES paises(id),
    nombre VARCHAR(100) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    capacidad_diaria INTEGER NOT NULL,
    fecha_apertura DATE NOT NULL
);

INSERT INTO plantas (id_pais, nombre, ciudad, capacidad_diaria, fecha_apertura) VALUES
-- COLOMBIA (2 sedes)
(1, 'Planta Norte Colombia', 'Cúcuta', 5000, '2018-03-15'),
(1, 'Planta Occidente Colombia', 'Palmira', 8000, '2015-06-20'),

-- MÉXICO (2 sedes)
(2, 'Planta Centro México', 'Guadalajara', 7000, '2017-01-10'),
(2, 'Planta Norte México', 'Monterrey', 6500, '2019-08-05'),

-- BRASIL (2 sedes)
(3, 'Planta São Paulo', 'São Paulo', 10000, '2014-11-30'),
(3, 'Planta Sur Brasil', 'Porto Alegre', 5500, '2020-02-14'),

-- ESTADOS UNIDOS (1 sede)
(4, 'Planta Texas', 'Houston', 12000, '2012-09-22'),

-- ESPAÑA (1 sede)
(5, 'Planta Ibérica', 'Valencia', 6000, '2016-05-18');

-- ============================================
-- 3. TABLA DE MÁQUINAS
-- ============================================
CREATE TABLE maquinas (
    id SERIAL PRIMARY KEY,
    id_planta INTEGER REFERENCES plantas(id),
    codigo VARCHAR(20) NOT NULL UNIQUE,
    modelo VARCHAR(50) NOT NULL,
    anio_instalacion INTEGER NOT NULL,
    estado_actual VARCHAR(20) DEFAULT 'OPERATIVA'
);

INSERT INTO maquinas (id_planta, codigo, modelo, anio_instalacion, estado_actual) VALUES
-- Planta Norte Colombia (Cúcuta) - 1 máquina
(1, 'COL-CUC-M01', 'FlexPack Pro 3000', 2018, 'OPERATIVA'),

-- Planta Occidente Colombia (Palmira) - 2 máquinas
(2, 'COL-PAL-M01', 'FlexPack Pro 3000', 2015, 'OPERATIVA'),
(2, 'COL-PAL-M02', 'AgroPress Elite 5000', 2020, 'OPERATIVA'),

-- Planta Centro México (Guadalajara) - 3 máquinas
(3, 'MEX-GDL-M01', 'FlexPack Pro 3000', 2017, 'OPERATIVA'),
(3, 'MEX-GDL-M02', 'AgroPress Elite 5000', 2019, 'OPERATIVA'),
(3, 'MEX-GDL-M03', 'CompactLine 2500', 2021, 'OPERATIVA'),

-- Planta Norte México (Monterrey) - 2 máquinas
(4, 'MEX-MTY-M01', 'AgroPress Elite 5000', 2019, 'OPERATIVA'),
(4, 'MEX-MTY-M02', 'FlexPack Pro 3000', 2020, 'OPERATIVA'),

-- Planta São Paulo - 3 máquinas
(5, 'BRA-SAO-M01', 'AgroPress Elite 5000', 2014, 'OPERATIVA'),
(5, 'BRA-SAO-M02', 'FlexPack Pro 3000', 2018, 'OPERATIVA'),
(5, 'BRA-SAO-M03', 'CompactLine 2500', 2022, 'OPERATIVA'),

-- Planta Sur Brasil (Porto Alegre) - 2 máquinas
(6, 'BRA-POA-M01', 'FlexPack Pro 3000', 2020, 'OPERATIVA'),
(6, 'BRA-POA-M02', 'AgroPress Elite 5000', 2021, 'OPERATIVA'),

-- Planta Texas (Houston) - 3 máquinas
(7, 'USA-HOU-M01', 'AgroPress Elite 5000', 2012, 'OPERATIVA'),
(7, 'USA-HOU-M02', 'FlexPack Pro 3000', 2016, 'OPERATIVA'),
(7, 'USA-HOU-M03', 'CompactLine 2500', 2020, 'OPERATIVA'),

-- Planta Ibérica (Valencia) - 2 máquinas
(8, 'ESP-VAL-M01', 'FlexPack Pro 3000', 2016, 'OPERATIVA'),
(8, 'ESP-VAL-M02', 'AgroPress Elite 5000', 2019, 'OPERATIVA');

-- ============================================
-- 4. TABLA DE PRODUCTOS
-- ============================================
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    categoria VARCHAR(30) NOT NULL,
    peso_objetivo DECIMAL(6,2) NOT NULL,
    tolerancia DECIMAL(4,2) NOT NULL,
    unidad VARCHAR(10) DEFAULT 'kg'
);

INSERT INTO productos (codigo, nombre, categoria, peso_objetivo, tolerancia, unidad) VALUES
-- Concentrados para Aves
('CONC-POL-20', 'NutriAves Pro 20kg', 'Concentrado Aves', 20.00, 0.30, 'kg'),
('CONC-POL-40', 'NutriAves Premium 40kg', 'Concentrado Aves', 40.00, 0.50, 'kg'),

-- Concentrados para Bovinos
('CONC-BOV-25', 'BoviMax Elite 25kg', 'Concentrado Bovinos', 25.00, 0.40, 'kg'),
('CONC-BOV-50', 'BoviMax Ultra 50kg', 'Concentrado Bovinos', 50.00, 0.60, 'kg'),

-- Cuido para Perros
('CUID-PER-15', 'CaninePlus Adulto 15kg', 'Cuido Canino', 15.00, 0.25, 'kg'),
('CUID-PER-22', 'CaninePlus Premium 22kg', 'Cuido Canino', 22.00, 0.35, 'kg'),

-- Cuido para Gatos
('CUID-GAT-08', 'FelineGourmet 8kg', 'Cuido Felino', 8.00, 0.15, 'kg'),
('CUID-GAT-12', 'FelineGourmet Deluxe 12kg', 'Cuido Felino', 12.00, 0.20, 'kg'),

-- Concentrados para Porcinos
('CONC-POR-30', 'PorkGrow Master 30kg', 'Concentrado Porcinos', 30.00, 0.45, 'kg'),
('CONC-POR-45', 'PorkGrow Ultra 45kg', 'Concentrado Porcinos', 45.00, 0.55, 'kg');

-- ============================================
-- 5. TABLA DE TURNOS
-- ============================================
CREATE TABLE turnos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL
);

INSERT INTO turnos (nombre, hora_inicio, hora_fin) VALUES
('Mañana', '06:00:00', '14:00:00'),
('Tarde', '14:00:00', '22:00:00'),
('Noche', '22:00:00', '06:00:00');

-- ============================================
-- 6. TABLA DE PRODUCCIÓN (Transaccional)
-- ============================================
CREATE TABLE produccion_global (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    id_maquina INTEGER REFERENCES maquinas(id),
    id_producto INTEGER REFERENCES productos(id),
    id_turno INTEGER REFERENCES turnos(id),
    peso_real DECIMAL(6,2) NOT NULL,
    estado VARCHAR(10) NOT NULL CHECK (estado IN ('OK', 'DEFECTO')),
    codigo_operador VARCHAR(10),
    temperatura_maquina DECIMAL(4,1),
    humedad_ambiente DECIMAL(4,1),
    velocidad_linea INTEGER
);

-- Índices para mejorar performance en consultas
CREATE INDEX idx_produccion_timestamp ON produccion_global(timestamp);
CREATE INDEX idx_produccion_maquina ON produccion_global(id_maquina);
CREATE INDEX idx_produccion_producto ON produccion_global(id_producto);
CREATE INDEX idx_produccion_estado ON produccion_global(estado);

-- ============================================
-- 7. VISTAS PARA METABASE (Facilitadores)
-- ============================================

-- Vista completa para análisis
CREATE VIEW vista_produccion_completa AS
SELECT 
    pg.id,
    pg.timestamp,
    pg.peso_real,
    pg.estado,
    pg.codigo_operador,
    pg.temperatura_maquina,
    pg.humedad_ambiente,
    pg.velocidad_linea,
    m.codigo AS codigo_maquina,
    m.modelo AS modelo_maquina,
    pl.nombre AS planta,
    pl.ciudad,
    p.nombre AS pais,
    p.region,
    pr.codigo AS codigo_producto,
    pr.nombre AS producto,
    pr.categoria,
    pr.peso_objetivo,
    t.nombre AS turno
FROM produccion_global pg
JOIN maquinas m ON pg.id_maquina = m.id
JOIN plantas pl ON m.id_planta = pl.id
JOIN paises p ON pl.id_pais = p.id
JOIN productos pr ON pg.id_producto = pr.id
JOIN turnos t ON pg.id_turno = t.id;

-- Vista de KPIs por planta
CREATE VIEW kpi_por_planta AS
SELECT 
    pl.nombre AS planta,
    p.nombre AS pais,
    COUNT(*) AS total_bultos,
    SUM(CASE WHEN pg.estado = 'OK' THEN 1 ELSE 0 END) AS bultos_ok,
    SUM(CASE WHEN pg.estado = 'DEFECTO' THEN 1 ELSE 0 END) AS bultos_defecto,
    ROUND(100.0 * SUM(CASE WHEN pg.estado = 'OK' THEN 1 ELSE 0 END) / COUNT(*), 2) AS porcentaje_calidad,
    ROUND(AVG(pg.peso_real), 2) AS peso_promedio
FROM produccion_global pg
JOIN maquinas m ON pg.id_maquina = m.id
JOIN plantas pl ON m.id_planta = pl.id
JOIN paises p ON pl.id_pais = p.id
GROUP BY pl.nombre, p.nombre;

-- ============================================
-- 8. DATOS DE CONFIGURACIÓN DE PRODUCTOS POR PLANTA
-- ============================================
-- Tabla para definir qué productos produce cada planta
CREATE TABLE planta_productos (
    id SERIAL PRIMARY KEY,
    id_planta INTEGER REFERENCES plantas(id),
    id_producto INTEGER REFERENCES productos(id),
    probabilidad DECIMAL(4,2) DEFAULT 10.00
);

-- Colombia - Cúcuta (enfocada en aves y bovinos)
INSERT INTO planta_productos (id_planta, id_producto, probabilidad) VALUES
(1, 1, 40), -- NutriAves Pro 20kg
(1, 3, 35), -- BoviMax Elite 25kg
(1, 5, 25); -- CaninePlus Adulto 15kg

-- Colombia - Palmira (diversificada)
INSERT INTO planta_productos (id_planta, id_producto, probabilidad) VALUES
(2, 1, 20), -- NutriAves Pro 20kg
(2, 2, 15), -- NutriAves Premium 40kg
(2, 3, 25), -- BoviMax Elite 25kg
(2, 5, 20), -- CaninePlus Adulto 15kg
(2, 9, 20); -- PorkGrow Master 30kg

-- México - Guadalajara (enfocada en mascotas)
INSERT INTO planta_productos (id_planta, id_producto, probabilidad) VALUES
(3, 5, 30), -- CaninePlus Adulto 15kg
(3, 6, 25), -- CaninePlus Premium 22kg
(3, 7, 25), -- FelineGourmet 8kg
(3, 8, 20); -- FelineGourmet Deluxe 12kg

-- México - Monterrey (bovinos y porcinos)
INSERT INTO planta_productos (id_planta, id_producto, probabilidad) VALUES
(4, 3, 35), -- BoviMax Elite 25kg
(4, 4, 30), -- BoviMax Ultra 50kg
(4, 9, 35); -- PorkGrow Master 30kg

-- Brasil - São Paulo (alta diversificación)
INSERT INTO planta_productos (id_planta, id_producto, probabilidad) VALUES
(5, 1, 15),
(5, 2, 10),
(5, 3, 15),
(5, 4, 15),
(5, 5, 15),
(5, 6, 10),
(5, 9, 10),
(5, 10, 10);

-- Brasil - Porto Alegre (aves y bovinos)
INSERT INTO planta_productos (id_planta, id_producto, probabilidad) VALUES
(6, 1, 30),
(6, 2, 25),
(6, 3, 25),
(6, 4, 20);

-- USA - Houston (todas las líneas, planta más grande)
INSERT INTO planta_productos (id_planta, id_producto, probabilidad) VALUES
(7, 1, 10),
(7, 2, 10),
(7, 3, 10),
(7, 4, 10),
(7, 5, 10),
(7, 6, 10),
(7, 7, 10),
(7, 8, 10),
(7, 9, 10),
(7, 10, 10);

-- España - Valencia (mascotas premium)
INSERT INTO planta_productos (id_planta, id_producto, probabilidad) VALUES
(8, 5, 25),
(8, 6, 30),
(8, 7, 20),
(8, 8, 25);

-- ============================================
-- CONFIRMACIÓN
-- ============================================
SELECT 'Base de datos creada exitosamente' AS mensaje;
SELECT COUNT(*) AS total_paises FROM paises;
SELECT COUNT(*) AS total_plantas FROM plantas;
SELECT COUNT(*) AS total_maquinas FROM maquinas;
SELECT COUNT(*) AS total_productos FROM productos;