-- ========================================================================
--  UNIVERSIDAD NACIONAL DE LA MATANZA
--  Asignatura: 3641 - Bases de Datos Aplicada
--  Objetivo del Código: Script de Testing 1:1 para Lógica de Concesiones
-- ======================================================================== */
--  INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales;
GO

-- ========================================================================
-- TEST LOGICA NEGOCIO: INTENTO DE PAGO EN CONTRATO COMERCIAL CANCELADO
-- ========================================================================
-- ESCENARIO ESPERADO: Debe rechazar el pago debido a la rescisión lógica previa.

BEGIN TRANSACTION; -- Entorno de contención seguro
BEGIN TRY
    DECLARE @idEmpresa INT, @idActividad INT, @idParque INT, @idConcesion INT;
    DECLARE @idTipoParque INT;

    -- Inyección rápida de datos semilla temporales
    INSERT INTO Parques.TipoParque (nombre) VALUES ('TEST_Negocio');
    SET @idTipoParque = SCOPE_IDENTITY();
    
    INSERT INTO Parques.Parque (idTipoParque, nombre, localidad, provincia, superficie) 
    VALUES (@idTipoParque, 'Parque Comercial Test', 'L1', 'P1', 500);
    SET @idParque = SCOPE_IDENTITY();
    
    INSERT INTO Concesiones.EmpresaConcesionaria (cuit, razonSocial) 
    VALUES ('30777777774', 'Parador Glaciar S.A.');
    SET @idEmpresa = SCOPE_IDENTITY();
    
    INSERT INTO Concesiones.TipoActividadConcesion (nombre) 
    VALUES ('Servicio Gastronómico Premium');
    SET @idActividad = SCOPE_IDENTITY();
    
    INSERT INTO Concesiones.Concesion (idEmpresaConcesionaria, idTipoActividadConcesion, idParque, fechaInicio, fechaFin, montoAlquiler, estado)
    VALUES (@idEmpresa, @idActividad, @idParque, '2026-01-01', '2026-12-31', 95000.00, 'Activa');
    SET @idConcesion = SCOPE_IDENTITY();

    -- 1. Aplicamos la baja lógica de negocio
    EXEC Concesiones.sp_CancelarConcesion @idConcesion = @idConcesion;

    -- 2. Intentamos ingresar un cobro de cuota (Debe saltar al CATCH por la regla de negocio)
    EXEC Concesiones.sp_RegistrarPagoCanonNegocio @idConcesion = @idConcesion, @monto = 95000.00;

END TRY
BEGIN CATCH
    PRINT 'Fallo de Negocio detectado y controlado correctamente en el bloque CATCH:';
    PRINT ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO