-- -----------------------------------------------------
-- Esquema de la Base de Datos: ONG Ayuda en Acción
-- Autor: Darwin Colmenares
-- Versión: 1.0
-- DBMS: PostgreSQL 17+
-- Descripción: Definición de estructura, restricciones, vistas e índices.
-- -----------------------------------------------------

-- -----------------------------------------------------
-- 1. LIMPIEZA DE ESQUEMA (DROP)
-- Se eliminan las tablas en orden inverso para respetar claves foráneas.
-- -----------------------------------------------------
DROP TABLE IF EXISTS comunicacion CASCADE;
DROP TABLE IF EXISTS donacioneconomica CASCADE;
DROP TABLE IF EXISTS donacionespecie CASCADE;
DROP TABLE IF EXISTS usofondos CASCADE;
DROP TABLE IF EXISTS voluntario CASCADE;
DROP TABLE IF EXISTS informe CASCADE;
DROP TABLE IF EXISTS donante CASCADE;
DROP TABLE IF EXISTS proyecto CASCADE;

-- -----------------------------------------------------
-- 2. CREACIÓN DE TABLAS (DDL)
-- -----------------------------------------------------

-- Tabla: Donante
-- Almacena la información maestra de los donantes (Personas y Empresas)
CREATE TABLE donante (
    numero_donante SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos_razon_social VARCHAR(200) NOT NULL,
    direccion VARCHAR(255),
    telefono VARCHAR(20),
    correo_electronico VARCHAR(100) UNIQUE NOT NULL,
    tipo_donante VARCHAR(20) NOT NULL CHECK (tipo_donante IN ('individual', 'empresa', 'fundacion')),
    historial_donaciones TEXT,
    preferencias_comunicacion TEXT
);

-- Tabla: Proyecto
-- Registro de los proyectos humanitarios gestionados por la ONG
CREATE TABLE proyecto (
    nombre_proyecto VARCHAR(200) PRIMARY KEY,
    descripcion TEXT,
    ubicacion VARCHAR(255),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    presupuesto NUMERIC(15, 2),
    objetivos TEXT,
    beneficiarios TEXT
);

-- Tabla: DonacionEconomica
-- Registro de donaciones monetarias
CREATE TABLE donacioneconomica (
    numero_donacion SERIAL PRIMARY KEY,
    fecha_donacion DATE NOT NULL,
    importe NUMERIC(15, 2) NOT NULL,
    metodo_pago VARCHAR(30) NOT NULL CHECK (metodo_pago IN ('tarjeta_credito', 'tarjeta_debito', 'transferencia_bancaria', 'pago_movil', 'efectivo')),
    estado_donacion VARCHAR(20) NOT NULL CHECK (estado_donacion IN ('recibida', 'confirmada', 'procesada')),
    proyecto_destino VARCHAR(200),
    numero_donante INTEGER,
    CONSTRAINT fk_donacion_eco_proyecto FOREIGN KEY (proyecto_destino) REFERENCES proyecto(nombre_proyecto),
    CONSTRAINT fk_donacion_eco_donante FOREIGN KEY (numero_donante) REFERENCES donante(numero_donante)
);

-- Tabla: DonacionEspecie
-- Registro de donaciones en bienes materiales
CREATE TABLE donacionespecie (
    numero_donacion SERIAL PRIMARY KEY,
    fecha_donacion DATE NOT NULL,
    descripcion_articulos TEXT NOT NULL,
    cantidad INTEGER NOT NULL,
    unidad_medida VARCHAR(50),
    valor_estimado NUMERIC(15, 2),
    estado_donacion VARCHAR(20) NOT NULL CHECK (estado_donacion IN ('recibida', 'clasificada', 'distribuida')),
    proyecto_destino VARCHAR(200),
    numero_donante INTEGER,
    CONSTRAINT fk_donacion_especie_proyecto FOREIGN KEY (proyecto_destino) REFERENCES proyecto(nombre_proyecto),
    CONSTRAINT fk_donacion_especie_donante FOREIGN KEY (numero_donante) REFERENCES donante(numero_donante)
);

-- Tabla: UsoFondos
-- Trazabilidad de gastos y partidas presupuestarias por proyecto
CREATE TABLE usofondos (
    id_uso_fondos SERIAL PRIMARY KEY,
    proyecto VARCHAR(200),
    partida_presupuestaria VARCHAR(200),
    importe_asignado NUMERIC(15, 2) NOT NULL,
    importe_gastado NUMERIC(15, 2),
    fecha_gasto DATE,
    descripcion_gasto TEXT,
    CONSTRAINT fk_usofondos_proyecto FOREIGN KEY (proyecto) REFERENCES proyecto(nombre_proyecto)
);

-- Tabla: Comunicacion
-- Historial de interacciones CRM con donantes
CREATE TABLE comunicacion (
    id_comunicacion SERIAL PRIMARY KEY,
    numero_donante INTEGER,
    fecha_envio DATE NOT NULL,
    tipo_comunicacion VARCHAR(20) NOT NULL CHECK (tipo_comunicacion IN ('correo_electronico', 'carta')),
    contenido TEXT,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('enviada', 'pendiente')),
    CONSTRAINT fk_comunicacion_donante FOREIGN KEY (numero_donante) REFERENCES donante(numero_donante)
);

-- Tabla: Voluntario
-- Gestión de recursos humanos voluntarios
CREATE TABLE voluntario (
    id_voluntario SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo_electronico VARCHAR(100) UNIQUE NOT NULL,
    proyecto_asignado VARCHAR(200),
    CONSTRAINT fk_voluntario_proyecto FOREIGN KEY (proyecto_asignado) REFERENCES proyecto(nombre_proyecto)
);

-- Tabla: Informe
-- Almacén de reportes generados para auditoría y transparencia
CREATE TABLE informe (
    id_informe SERIAL PRIMARY KEY,
    tipo_informe VARCHAR(50) NOT NULL CHECK (tipo_informe IN ('donaciones_por_donante', 'ingresos_y_gastos', 'impacto_proyectos', 'auditoria_cumplimiento')),
    fecha_generacion DATE NOT NULL,
    descripcion TEXT,
    donante_relacionado INTEGER,
    proyecto_relacionado VARCHAR(200),
    total_ingresos NUMERIC(15, 2),
    total_gastos NUMERIC(15, 2),
    impacto_proyecto TEXT,
    observaciones_auditoria TEXT,
    CONSTRAINT fk_informe_donante FOREIGN KEY (donante_relacionado) REFERENCES donante(numero_donante),
    CONSTRAINT fk_informe_proyecto FOREIGN KEY (proyecto_relacionado) REFERENCES proyecto(nombre_proyecto)
);

-- -----------------------------------------------------
-- 3. CREACIÓN DE VISTAS (VIEWS)
-- Objeto de base de datos para simplificar consultas complejas recurrentes.
-- -----------------------------------------------------

-- Vista: Resumen financiero por donante
CREATE VIEW vw_donaciones_totales_por_donante AS
SELECT 
    d.numero_donante, 
    (d.nombre || ' ' || d.apellidos_razon_social) AS nombre_completo, 
    COALESCE(SUM(de.importe), 0) AS total_donado
FROM donante d
LEFT JOIN donacioneconomica de ON d.numero_donante = de.numero_donante
GROUP BY d.numero_donante, d.nombre, d.apellidos_razon_social;

-- Vista: Impacto financiero por proyecto (Balance Ingresos - Gastos)
CREATE VIEW vw_impacto_proyectos AS
SELECT 
    p.nombre_proyecto, 
    p.objetivos, 
    COALESCE(SUM(de.importe), 0) AS total_ingresos, 
    COALESCE(SUM(uf.importe_gastado), 0) AS total_gastos, 
    (COALESCE(SUM(de.importe), 0) - COALESCE(SUM(uf.importe_gastado), 0)) AS saldo_restante
FROM proyecto p
LEFT JOIN donacioneconomica de ON p.nombre_proyecto = de.proyecto_destino
LEFT JOIN usofondos uf ON p.nombre_proyecto = uf.proyecto
GROUP BY p.nombre_proyecto, p.objetivos;

-- Vista: Tareas pendientes de comunicación
CREATE VIEW vw_comunicaciones_pendientes AS
SELECT 
    c.id_comunicacion, 
    (d.nombre || ' ' || d.apellidos_razon_social) AS nombre_donante, 
    c.tipo_comunicacion, 
    c.fecha_envio, 
    c.estado
FROM comunicacion c
JOIN donante d ON c.numero_donante = d.numero_donante
WHERE c.estado = 'pendiente';

-- Vista: Asignación de voluntarios
CREATE VIEW vw_voluntarios_por_proyecto AS
SELECT 
    v.id_voluntario,
    (v.nombre || ' ' || v.apellidos) AS nombre_voluntario,
    v.correo_electronico,
    p.nombre_proyecto,
    p.descripcion
FROM voluntario v
JOIN proyecto p ON v.proyecto_asignado = p.nombre_proyecto;

-- Vista: Gastos totales por proyecto
CREATE VIEW vw_gastos_totales_por_proyecto AS
SELECT 
    p.nombre_proyecto,
    p.descripcion,
    COALESCE(SUM(uf.importe_gastado), 0) AS total_gastado
FROM proyecto p
LEFT JOIN usofondos uf ON p.nombre_proyecto = uf.proyecto
GROUP BY p.nombre_proyecto, p.descripcion;

-- Vista: Donaciones en especie por proyecto
CREATE VIEW vw_donaciones_especie_por_proyecto AS
SELECT 
    p.nombre_proyecto,
    p.descripcion,
    COUNT(ds.numero_donacion) AS cantidad_donaciones,
    COALESCE(SUM(ds.cantidad * ds.valor_estimado), 0) AS valor_total_estimado
FROM proyecto p
LEFT JOIN donacionespecie ds ON p.nombre_proyecto = ds.proyecto_destino
GROUP BY p.nombre_proyecto, p.descripcion;

-- Vista: Informes generados con contexto
CREATE VIEW vw_informes_generados AS
SELECT 
    i.id_informe,
    i.tipo_informe,
    i.fecha_generacion,
    d.nombre || ' ' || d.apellidos_razon_social AS nombre_donante,
    p.nombre_proyecto,
    i.total_ingresos,
    i.total_gastos,
    i.impacto_proyecto
FROM informe i
LEFT JOIN donante d ON i.donante_relacionado = d.numero_donante
LEFT JOIN proyecto p ON i.proyecto_relacionado = p.nombre_proyecto;

-- -----------------------------------------------------
-- 4. CREACIÓN DE ÍNDICES (INDEXES)
-- Optimización de rendimiento para columnas frecuentemente consultadas.
-- -----------------------------------------------------

CREATE INDEX idx_donante_correo ON donante(correo_electronico);
CREATE INDEX idx_donacion_fecha ON donacioneconomica(fecha_donacion);
CREATE INDEX idx_donacion_estado ON donacioneconomica(estado_donacion);
CREATE INDEX idx_donacion_proyecto_destino ON donacioneconomica(proyecto_destino);
CREATE INDEX idx_donacionespecie_proyecto_destino ON donacionespecie(proyecto_destino);
CREATE INDEX idx_comunicacion_estado ON comunicacion(estado);
CREATE INDEX idx_informe_fecha ON informe(fecha_generacion);