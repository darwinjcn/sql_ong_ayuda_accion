-- -----------------------------------------------------
-- Consultas de Ejemplo y Reportes
-- Demuestra capacidades de análisis de datos
-- -----------------------------------------------------

-- 1. LISTADO DE DONANTES ACTIVOS
-- Obtiene un resumen limpio de los donantes registrados.
SELECT 
    numero_donante, 
    nombre, 
    apellidos_razon_social, 
    correo_electronico, 
    tipo_donante 
FROM donante 
ORDER BY tipo_donante, apellidos_razon_social;

-- 2. DONACIONES TOTALES POR DONANTE (USANDO VISTA)
-- Utiliza la vista predefinida 'vw_donaciones_totales_por_donante'
-- para obtener métricas financieras agregadas sin escribir lógica compleja cada vez.
SELECT * FROM vw_donaciones_totales_por_donante;

-- 3. ANÁLISIS DE IMPACTO FINANCIERO POR PROYECTO
-- Muestra el balance entre ingresos (donaciones) y gastos (uso de fondos)
-- para determinar el presupuesto restante de cada iniciativa.
SELECT 
    nombre_proyecto, 
    total_ingresos, 
    total_gastos, 
    saldo_restante,
    CASE 
        WHEN saldo_restante < 0 THEN 'Déficit'
        WHEN saldo_restante > 0 THEN 'Superávit'
        ELSE 'Equilibrado'
    END AS estado_financiero
FROM vw_impacto_proyectos;

-- 4. DETALLE DE DONACIONES CON INFORMACIÓN DEL DONANTE
-- Ejemplo de JOIN para combinar datos transaccionales con datos maestros.
SELECT 
    de.numero_donacion,
    de.fecha_donacion,
    de.importe,
    de.metodo_pago,
    d.nombre || ' ' || d.apellidos_razon_social AS donante,
    de.proyecto_destino
FROM donacioneconomica de
JOIN donante d ON de.numero_donante = d.numero_donante
WHERE de.fecha_donacion >= '2025-01-01'
ORDER BY de.fecha_donacion DESC;

-- 5. COMUNICACIONES PENDIENTES DE GESTIÓN
-- Filtra la vista de comunicaciones para identificar tareas pendientes del equipo.
SELECT 
    nombre_donante, 
    tipo_comunicacion, 
    fecha_envio 
FROM vw_comunicaciones_pendientes
ORDER BY fecha_envio ASC;

-- 6. VOLUNTARIOS ASIGNADOS A PROYECTOS ACTIVOS
-- Relaciona recursos humanos con proyectos operativos.
SELECT 
    v.nombre || ' ' || v.apellidos AS voluntario,
    v.correo_electronico,
    p.nombre_proyecto,
    p.ubicacion
FROM voluntario v
JOIN proyecto p ON v.proyecto_asignado = p.nombre_proyecto
WHERE p.fecha_fin >= CURRENT_DATE;