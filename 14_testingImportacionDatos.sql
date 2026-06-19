-- ============================================================
-- TESTING Visitas segun tipo visitante
-- ============================================================
USE ParquesNacionales
GO

EXEC Importacion.sp_ImportarVisitas
    @rutaArchivo = 'C:\Datasets\visitas-residentes-y-no-residentes.csv'

SELECT * FROM Importacion.VisitasParquesNacionales