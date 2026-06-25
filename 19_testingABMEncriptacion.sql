-- ============================================================
-- Fecha: 2025-06-25
-- Descripción: Testing - Ejecucion de sps para cifrar 
--              datos sensibles
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

-- Para todos los ABM se prueba que: 
-- El dato sensible quedo encriptado
-- Se puede desencriptar correctamente con la frase clave
-- Luego de una modificación, los datos cifrados se actualizaron correctamente.

-- ==========================================================
-- TABLA Visitante
-- ==========================================================

USE ParquesNacionales
GO

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @idVisitante INT;
    DECLARE @FraseClave NVARCHAR(128) = 'FraseSecreta123';

    ------------------------------------------------------------
    -- Alta
    ------------------------------------------------------------
    EXEC Ventas.sp_AltaVisitante
        @nombre = 'TEST_Carlos',
        @apellido = 'Pellegrini',
        @email = 'carlos@test.com',
        @direccion = 'Av. Siempre Viva 123',
        @telefono = '1144332211',
        @FraseClave = @FraseClave;

    
    SELECT @idVisitante = idVisitante
    FROM Ventas.Visitante
    WHERE nombre = 'TEST_Carlos';

    PRINT 'Verificación luego del alta';

    SELECT
        emailCifrado,
        telefonoCifrado,
        CONVERT(VARCHAR(100),
            DecryptByPassPhrase(@FraseClave,emailCifrado,1,CONVERT(VARBINARY,@idVisitante))) AS Email,
        CONVERT(VARCHAR(20),
            DecryptByPassPhrase(@FraseClave,telefonoCifrado,1,CONVERT(VARBINARY,@idVisitante))) AS Telefono
    FROM Ventas.Visitante
    WHERE idVisitante = @idVisitante;

    ------------------------------------------------------------
    -- Modificación
    ------------------------------------------------------------

    EXEC Ventas.sp_ModificacionVisitante
        @idVisitante=@idVisitante,
        @nombre='TEST_Carlos',
        @apellido='Pellegrini',
        @email='nuevo@test.com',
        @direccion='Nueva direccion',
        @telefono='1199998888',
        @FraseClave=@FraseClave;

    PRINT 'Verificación luego de la modificación';

    SELECT
        CONVERT(VARCHAR(100),
            DecryptByPassPhrase(@FraseClave,emailCifrado,1,CONVERT(VARBINARY,@idVisitante))) AS Email,
        CONVERT(VARCHAR(20),
            DecryptByPassPhrase(@FraseClave,telefonoCifrado,1,CONVERT(VARBINARY,@idVisitante))) AS Telefono
    FROM Ventas.Visitante
    WHERE idVisitante = @idVisitante;

END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO

-- ==========================================================
-- TABLA Guardaparque
-- ==========================================================

BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @idGuardaparque INT;
    DECLARE @FraseClave NVARCHAR(125)='FraseSecreta123';

    EXEC Personal.sp_AltaGuardaparque
        @nombre='TEST_Juan',
        @apellido='Perez',
        @fechaNacimiento='1990-05-15',
        @tipoDocumento='DNI',
        @nroDocumento='40111222',
        @email='juan@test.com',
        @fechaIngresoCargo='2023-01-01',
        @FraseClave=@FraseClave;

    SELECT @idGuardaparque = idGuardaparque
    FROM Personal.Guardaparque
    WHERE nombre = 'TEST_Juan';

    PRINT 'Verificación luego del alta';

    SELECT
        CONVERT(VARCHAR(150),
            DecryptByPassPhrase(@FraseClave,emailCifrado,1,CONVERT(VARBINARY,@idGuardaparque))) AS Email,
        CONVERT(VARCHAR(20),
            DecryptByPassPhrase(@FraseClave,nroDocumentoCifrado,1,CONVERT(VARBINARY,@idGuardaparque))) AS Documento
    FROM Personal.Guardaparque
    WHERE idGuardaparque = @idGuardaparque;

    EXEC Personal.sp_ModificacionGuardaparque
        @idGuardaparque=@idGuardaparque,
        @nombre='TEST_Juan',
        @apellido='Perez',
        @fechaNacimiento='1990-05-15',
        @tipoDocumento='DNI',
        @nroDocumento='40999888',
        @email='nuevo@test.com',
        @fechaIngresoCargo='2023-01-01',
        @fechaEgresoCargo=NULL,
        @motivoEgreso=NULL,
        @estaActivo=1,
        @FraseClave=@FraseClave;

    PRINT 'Verificación luego de la modificación';

    SELECT
        CONVERT(VARCHAR(150),
            DecryptByPassPhrase(@FraseClave,emailCifrado,1,CONVERT(VARBINARY,@idGuardaparque))) AS Email,
        CONVERT(VARCHAR(20),
            DecryptByPassPhrase(@FraseClave,nroDocumentoCifrado,1,CONVERT(VARBINARY,@idGuardaparque))) AS Documento
    FROM Personal.Guardaparque
    WHERE idGuardaparque=@idGuardaparque;

END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO

-- ==========================================================
-- TABLA Guia
-- ==========================================================


BEGIN TRANSACTION;
BEGIN TRY

    DECLARE @idGuia INT;
    DECLARE @FraseClave NVARCHAR(125)='FraseSecreta123';

    EXEC Guias.sp_AltaGuia
        @nombre='TEST_Mario',
        @apellido='Lopez',
        @fechaNacimiento='1995-08-10',
        @tipoDocumento='DNI',
        @nroDocumento='38999111',
        @email='mario@test.com',
        @vigenciaAutorizacion='2030-01-01',
        @FraseClave=@FraseClave;

    SELECT @idGuia = idGuia
    FROM Guias.Guia
    WHERE nombre = 'TEST_Mario';

    PRINT 'Verificación luego del alta';

    SELECT
        CONVERT(VARCHAR(150),
            DecryptByPassPhrase(@FraseClave, emailCifrado, 1, CONVERT(VARBINARY,@idGuia))) AS Email,
        CONVERT(VARCHAR(20),
            DecryptByPassPhrase(@FraseClave, nroDocumentoCifrado, 1, CONVERT(VARBINARY,@idGuia))) AS Documento
    FROM Guias.Guia
    WHERE idGuia = @idGuia;

    EXEC Guias.sp_ModificacionGuia
        @idGuia = @idGuia,
        @nombre = 'TEST_Mario',
        @apellido = 'Lopez',
        @fechaNacimiento = '1995-08-10',
        @tipoDocumento = 'DNI',
        @nroDocumento = '38777777',
        @email = 'nuevo@test.com',
        @vigenciaAutorizacion = '2031-01-01',
        @FraseClave = @FraseClave;

    PRINT 'Verificación luego de la modificación';

    SELECT
        CONVERT(VARCHAR(150),
            DecryptByPassPhrase(@FraseClave,emailCifrado,1,CONVERT(VARBINARY,@idGuia))) AS Email,
        CONVERT(VARCHAR(20),
            DecryptByPassPhrase(@FraseClave,nroDocumentoCifrado,1,CONVERT(VARBINARY,@idGuia))) AS Documento
    FROM Guias.Guia
    WHERE idGuia = @idGuia;

END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;

ROLLBACK TRANSACTION;
GO