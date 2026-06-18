-- ========================================================================
--  UNIVERSIDAD NACIONAL DE LA MATANZA
--  Departamento de Ingeniería e Investigaciones Tecnológicas
--  Asignatura: 3641 - Bases de Datos Aplicada
--  Objetivo del Código: Lógica de Negocio Transaccional para Concesiones
-- ========================================================================
--  INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales;
GO

-- ========================================================================
-- 1. PROCESO: CANCELACIÓN ANTICIPADA / RESVISIÓN DE CONTRATO
-- ========================================================================
CREATE OR ALTER PROCEDURE Concesiones.sp_CancelarConcesion
    @idConcesion INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM Concesiones.Concesion WHERE idConcesion = @idConcesion)
    BEGIN
        RAISERROR('- Error de Negocio: El contrato de concesión especificado no existe.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE Concesiones.Concesion
        SET estado = 'Cancelada'
        WHERE idConcesion = @idConcesion;

        COMMIT TRANSACTION;
        PRINT 'Contrato de concesión rescindido y cancelado lógicamente con éxito.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- ========================================================================
-- 2. PROCESO: REGISTRO INTELIGENTE DE PAGO DE CÁNONES
-- ========================================================================
CREATE OR ALTER PROCEDURE Concesiones.sp_RegistrarPagoCanonNegocio
    @idConcesion INT,
    @monto       DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @estadoContrato VARCHAR(20);
    SELECT @estadoContrato = estado FROM Concesiones.Concesion WHERE idConcesion = @idConcesion;

    -- Regla de Negocio: No se puede cobrar canon a un contrato dado de baja o cancelado
    IF @estadoContrato = 'Cancelada'
    BEGIN
        RAISERROR('- Error de Negocio: Operación rechazada. No se pueden registrar pagos de cánones en un contrato comercial que se encuentra Cancelado.', 16, 1);
        RETURN;
    END

    BEGIN TRANSACTION;
    BEGIN TRY
        EXEC Concesiones.sp_AltaPagoCanon
            @idConcesion = @idConcesion,
            @fechaPago = '2026-06-18', -- Fecha del día del coloquio (2026)
            @monto = @monto,
            @fechaVencimiento = '2026-07-10',
            @fechaEmision = '2026-06-18';

        COMMIT TRANSACTION;
        PRINT 'Pago de canon registrado y asociado al contrato correctamente.';
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO