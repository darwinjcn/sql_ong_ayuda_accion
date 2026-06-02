-- -----------------------------------------------------
-- Datos de Prueba: ONG Ayuda en Acción
-- Este script pobla las tablas con datos demostrativos.
-- -----------------------------------------------------

-- NOTA: Se especifican los IDs explícitamente para mantener
-- la integridad referencial tal como en el backup original.

-- 1. Donantes
INSERT INTO donante (numero_donante, nombre, apellidos_razon_social, direccion, telefono, correo_electronico, tipo_donante, historial_donaciones, preferencias_comunicacion)
VALUES 
(2, 'Juan', 'Pérez López', 'Calle 123, caracas', '0412-1238080', 'juan.perez@gmail.com', 'individual', 'Frecuente', 'Correo electrónico'),
(3, 'María', 'García Fernández', 'Avenida 456, Pueblo', '0416-7990000', 'fernandezmaria@gmail.com', 'individual', 'Esporádico', 'Teléfono'),
(4, 'Empresa Solidaria', 'S.A.', 'Oficina 789, caracas', '0212-9001500', 'contacto@solidaria.com.ve', 'empresa', 'Anual', 'Correo electrónico'),
(5, 'Ana', 'Martínez Torres', 'Calle 321, caracas', '0424-1230000', 'ana.martinez@gmail.com', 'individual', 'Primera vez', 'Correo electrónico');

-- 2. Proyectos
INSERT INTO proyecto (nombre_proyecto, descripcion, ubicacion, fecha_inicio, fecha_fin, presupuesto, objetivos, beneficiarios)
VALUES 
('Educación para Todos', 'Proyecto educativo en zonas rurales', 'Región Norte', '2025-01-01', '2025-12-31', 500000.00, 'Mejorar acceso a educación', 'Niños y jóvenes'),
('Agua Limpia', 'Proyecto de acceso a agua potable', 'Región Sur', '2025-03-01', '2025-06-30', 7500000.00, 'Instalar sistemas de agua', 'Comunidades rurales'),
('Vivienda Digna', 'Construcción de viviendas', 'Región Central', '2025-05-01', '2025-11-30', 10000000.00, 'Proporcionar vivienda segura', 'Familias vulnerables');

-- 3. Donaciones Económicas
INSERT INTO donacioneconomica (numero_donacion, fecha_donacion, importe, metodo_pago, estado_donacion, proyecto_destino, numero_donante)
VALUES 
(2, '2025-01-15', 5000.00, 'tarjeta_credito', 'confirmada', 'Educación para Todos', 2),
(4, '2025-03-10', 10000.00, 'pago_movil', 'recibida', 'Vivienda Digna', 4),
(5, '2025-10-05', 2000.00, 'tarjeta_debito', 'procesada', 'Educación para Todos', 5);

-- 4. Donaciones en Especie
INSERT INTO donacionespecie (numero_donacion, fecha_donacion, descripcion_articulos, cantidad, unidad_medida, valor_estimado, estado_donacion, proyecto_destino, numero_donante)
VALUES 
(2, '2025-01-20', 'Libros escolares', 50, 'unidades', 250.00, 'clasificada', 'Educación para Todos', 2),
(3, '2025-02-25', 'Ropa de invierno', 100, 'kilogramos', 500.00, 'distribuida', 'Agua Limpia', 3),
(4, '2025-03-15', 'Materiales de construcción', 200, 'metros', 1000.00, 'recibida', 'Vivienda Digna', 4),
(5, '2025-10-10', 'Juguetes educativos', 30, 'unidades', 150.00, 'clasificada', 'Educación para Todos', 5);

-- 5. Uso de Fondos
INSERT INTO usofondos (id_uso_fondos, proyecto, partida_presupuestaria, importe_asignado, importe_gastado, fecha_gasto, descripcion_gasto)
VALUES 
(2, 'Educación para Todos', 'Material didáctico', 100000.00, 80000.00, '2025-02-01', 'Compra de libros y cuadernos'),
(3, 'Agua Limpia', 'Infraestructura', 500000.00, 450000.00, '2025-03-15', 'Instalación de tuberías'),
(4, 'Vivienda Digna', 'Construcción', 750000.00, 700000.00, '2025-04-10', 'Compra de materiales'),
(5, 'Educación para Todos', 'Capacitación docente', 500000.00, 400000.00, '2025-09-20', 'Talleres para profesores');

-- 6. Comunicaciones
INSERT INTO comunicacion (id_comunicacion, numero_donante, fecha_envio, tipo_comunicacion, contenido, estado)
VALUES 
(10, 2, '2025-01-20', 'correo_electronico', 'Gracias por su donación al proyecto Educación para Todos.', 'enviada'),
(12, 4, '2025-03-10', 'correo_electronico', 'Actualización del proyecto Agua Limpia.', 'enviada'),
(13, 5, '2025-10-05', 'correo_electronico', 'Agradecimiento por su apoyo continuo.', 'enviada');

-- 7. Voluntarios
INSERT INTO voluntario (id_voluntario, nombre, apellidos, telefono, correo_electronico, proyecto_asignado)
VALUES 
(2, 'Carlos', 'Ramírez Pérez', '0414-0021578', 'carlos.ramirez@outlook.com', 'Educación para Todos'),
(3, 'Laura', 'Torres Gómez', '0424-2345678', 'laura.torres@outlook.com', 'Agua Limpia'),
(4, 'Pedro', 'Hernández López', '0426-2587410', 'pedro.hernandez@outlook.com', 'Vivienda Digna'),
(5, 'Sofía', 'Martínez Ruiz', '0412-5697015', 'sofia.martinez@outlook.com', 'Educación para Todos');

-- 8. Informes
INSERT INTO informe (id_informe, tipo_informe, fecha_generacion, descripcion, donante_relacionado, proyecto_relacionado, total_ingresos, total_gastos, impacto_proyecto, observaciones_auditoria)
VALUES 
(2, 'donaciones_por_donante', '2025-01-31', 'Resumen de donaciones realizadas por Juan Pérez.', 2, 'Educación para Todos', 50000.00, 45000.00, 'Alcanzamos a 100 niños.', NULL),
(3, 'ingresos_y_gastos', '2025-02-28', 'Informe financiero del proyecto Agua Limpia.', 3, 'Agua Limpia', 750000.00, 700000.00, 'Beneficiamos a 500 personas.', NULL),
(4, 'impacto_proyectos', '2025-03-31', 'Impacto del proyecto Vivienda Digna.', 4, 'Vivienda Digna', 1000000.00, 950000.00, 'Construidas 20 viviendas.', NULL),
(5, 'auditoria_cumplimiento', '2025-10-31', 'Auditoría de cumplimiento normativo.', NULL, NULL, NULL, NULL, NULL, 'Cumple con todas las regulaciones.');