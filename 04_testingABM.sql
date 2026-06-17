-- ============================================================
-- Fecha: 2025-06-16
-- Descripción: Scripts de Testing
-- ============================================================
-- ============================================================
-- INTEGRANTES
--  Ayala Bustos, Gustavo Gabriel
--  Bonfigli, Leonardo
--  Casale Benavente, Pedro Santino
--  Martinez Souto, Joaquin
-- ============================================================

USE ParquesNacionales
GO

-- ==========================================================
-- TESTING Parque
-- ==========================================================
-- idTipoParque no existente, nombre vacio, localidad vacia, provincia vacia, superficie invalida
BEGIN TRY
	EXEC Parques.sp_AltaParque @idTipoParque = 54, @nombre = '',
		@localidad = '', @provincia = '', @superficie = '0'
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idParque no existe, idTipoParque no existe, superficie invalida
BEGIN TRY
	EXEC Parques.sp_ModificacionParque  @idParque = 1, @idTipoParque = 54, @nombre = '',
		@localidad = '', @provincia = '', @superficie = '0'
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idParque no existe
BEGIN TRY
	EXEC Parques.sp_BajaParque  @idParque = 1
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- ==========================================================
-- TESTING TipoParque
-- ==========================================================
-- idTipoParque no ingresado
BEGIN TRY
	EXEC Parques.sp_AltaTipoParque @nombre = '', @descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idTipoParque no ingresado, nombre no ingresado
BEGIN TRY
	EXEC Parques.sp_ModificacionTipoParque @idTipoParque = 1, @nombre = '', @descripcion = ''
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH


-- idTipoParque no existe
BEGIN TRY
	EXEC Parques.sp_BajaTipoParque  @idTipoParque = 1
END TRY
BEGIN CATCH
	PRINT 'ERROR ESPERADO: ' + ERROR_MESSAGE()
END CATCH









-- ===========================================================
-- CASOS EXITOSOS - TipoActividadTuristica';
-- ============================================================

USE ParquesNacionales;
GO

BEGIN TRANSACTION

    DECLARE @idTipoActTest INT;

    -- Alta exitosa
    EXEC Actividades.sp_AltaTipoActividadTuristica
        @descripcion = 'TEST_Actividades acuáticas';

    SELECT @idTipoActTest = idTipoActividadTuristica
    FROM Actividades.TipoActividadTuristica
    WHERE descripcion = 'TEST_Actividades acuáticas';

    SELECT *
    FROM Actividades.TipoActividadTuristica
    WHERE idTipoActividadTuristica = @idTipoActTest;

    -- Modificación exitosa
    EXEC Actividades.sp_ModificacionTipoActividadTuristica
        @idTipoActividadTuristica = @idTipoActTest,
        @descripcion = 'TEST_Actividades acuáticas y de río';

    SELECT *
    FROM Actividades.TipoActividadTuristica
    WHERE idTipoActividadTuristica = @idTipoActTest;


    -- Baja exitosa
    EXEC Actividades.sp_BajaTipoActividadTuristica
        @idTipoActividadTuristica = @idTipoActTest;

    SELECT *
    FROM Actividades.TipoActividadTuristica
    WHERE idTipoActividadTuristica = @idTipoActTest;
    -- Debería devolver 0 filas

ROLLBACK TRANSACTION;

-- ============================================================
-- CASOS DE ERROR - TipoActividadTuristica
-- ============================================================

-- ********************** Alta *******************************

-- descripcion vacia
USE ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_AltaTipoActividadTuristica
        @descripcion = '     ';

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10));

END CATCH;
ROLLBACK TRANSACTION;

-- ***************** Modificacion ***************************

-- id no encontrado, descripcion vacia
USE ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_ModificacionTipoActividadTuristica
        @idTipoActividadTuristica = -1,
        @descripcion = '';

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10));

END CATCH;
ROLLBACK TRANSACTION;

-- ********************** Baja *******************************

-- id no encontrado
USE ParquesNacionales;
GO

BEGIN TRANSACTION;
BEGIN TRY

    EXEC Actividades.sp_BajaTipoActividadTuristica
        @idTipoActividadTuristica = -1;

END TRY
BEGIN CATCH

    SELECT value AS Error
    FROM STRING_SPLIT(ERROR_MESSAGE(), CHAR(10));

END CATCH;
ROLLBACK TRANSACTION;