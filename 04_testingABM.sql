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