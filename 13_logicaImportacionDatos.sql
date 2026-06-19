-- ============================================================
-- Fecha: 2025-06-12
-- Descripción: Creación de la logica para la importacion
--              masiva de datos.
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
CREATE SCHEMA Importacion
GO
-- ============================================================
-- IMPORTACION Parques
-- https://ri.conicet.gov.ar/handle/11336/284755?show=full
-- FORMATO: .txt
-- ============================================================
USE ParquesNacionales
GO

-- ============================================================
-- IMPORTACION Visitas segun tipo visitante
-- https://datos.yvera.gob.ar/dataset/parques-nacionales/archivo/a570af75-ed33-427c-9797-980fc0cd8fd1
-- FORMATO: .csv
-- ============================================================
USE ParquesNacionales
GO

DROP TABLE IF EXISTS Importacion.VisitasParquesNacionales
CREATE TABLE Importacion.VisitasParquesNacionales (
    indiceTiempo     VARCHAR(30),
    origenVisitantes VARCHAR(30),
    visitas          INT,
    observaciones    VARCHAR(300)
    CONSTRAINT PK_Visitas PRIMARY KEY (indiceTiempo, origenVisitantes)
)
GO

DROP TABLE IF EXISTS Importacion.Visitas
CREATE TABLE Importacion.Visitas (
    indiceTiempo     VARCHAR(100),
    origenVisitantes VARCHAR(100),
    visitas          VARCHAR(100),
    observaciones    VARCHAR(300)
)
GO


CREATE OR ALTER PROCEDURE Importacion.sp_ImportarVisitas
    @rutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON

    TRUNCATE TABLE Importacion.Visitas

    DECLARE @sql NVARCHAR(2000) =
        N'BULK INSERT Importacion.Visitas FROM ''' + @rutaArchivo + N'''
            WITH (FIRSTROW = 2,
                  FIELDTERMINATOR = '','',
                  ROWTERMINATOR = ''0x0a'',
                  CODEPAGE = ''RAW'',
                  TABLOCK)'
    BEGIN TRY
        EXEC sp_executesql @sql
    END TRY

    BEGIN CATCH
        DECLARE @errorMessage NVARCHAR(1000) = ERROR_MESSAGE()
        RAISERROR('Error al cargar el archivo de visitas %s : %s', 16, 1, @rutaArchivo, @errorMessage)
        RETURN
    END CATCH

    IF NOT EXISTS (
        SELECT 1 FROM Importacion.Visitas
    )
    BEGIN
        RAISERROR('El archivo no contiene datos o la ruta es incorrecta', 16, 1)
        RETURN
    END


    DECLARE @indiceTiempo  NVARCHAR(20),
            @origen        NVARCHAR(20),
            @visitasStr    NVARCHAR(20),
            @observaciones NVARCHAR(100),
            @visitasInt    INT,
            @errFila       NVARCHAR(500),
            @okCont        INT = 0,
            @errCont       INT = 0,
            @errTxt        NVARCHAR(MAX) = ''

    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT
            TRIM(indiceTiempo),
            TRIM(origenVisitantes),
            TRIM(visitas),
            TRIM(observaciones)
        FROM Importacion.Visitas
    
    OPEN cur
    FETCH NEXT FROM cur INTO @indiceTiempo, @origen, @visitasStr, @observaciones

    WHILE @@FETCH_STATUS = 0
    BEGIN   SET @errFila = ''

    IF ISDATE(@
        SET @errFila += 'indiceTiempo invalido ("' + @indiceTiempo + '"). '
    
    IF @origen NOT IN ('residentes', 'no residentes', 'total')
        SET @errFila += 'origen invalido ("' + @origen + '"). '
    
    SET @visitasInt = TRY_CAST(@visitasStr AS INT)
    IF @visitasStr <> '' AND @visitasInt IS NULL
        SET @errFila += 'visitas no contiene valor ("' + @visitasStr + '"). '

    IF @errFila <> ''
    BEGIN
        SET @errTxt += CHAR(10) +
            ' [' + @indiceTiempo + ' | ' + @origen + ']: ' + @errFila
        SET @errCont += 1
        GOTO SigFila
    END

    IF EXISTS (
        SELECT 1 FROM Importacion.VisitasParquesNacionales
        WHERE indiceTiempo = @indiceTiempo
        AND origenVisitantes = @origen
    )
        UPDATE Importacion.VisitasParquesNacionales
        SET visitas = @visitasInt,
            observaciones = @observaciones
        WHERE indiceTiempo = @indiceTiempo
            AND origenVisitantes = @origen

    ELSE
        INSERT INTO Importacion.VisitasParquesNacionales
            (indiceTiempo, origenVisitantes, visitas, observaciones)
        VALUES
            (@indiceTiempo, @origen, @visitasInt, @observaciones)
    
    SET @okCont += 1

    SigFila:
    FETCH NEXT FROM cur INTO @indiceTiempo, @origen, @visitasStr, @observaciones
END

CLOSE cur
DEALLOCATE cur
        
SELECT
    @rutaArchivo AS archivo,
    @okCont AS filasImportadas,
    @errCont AS filasConError

IF @errCont > 0
    PRINT 'Errores encontrados: ' + @errTxt

END
GO


-- ============================================================
-- IMPORTACION Guias
-- https://data.buenosaires.gob.ar/dataset/registro-guias-turismo/resource/juqdkmgo-1791-resource
-- FORMATO: .csv
-- ============================================================
USE ParquesNacionales
GO

BULK INSERT Importacion.GuiasTurismoRegistrados
FROM 'C:\Datasets\registro-de-guias-de-turismo.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    CODEPAGE = 'ACP'
)
SELECT * FROM Importacion.GuiasTurismoRegistrados

DROP TABLE IF EXISTS Importacion.GuiasTurismoRegistrados
CREATE TABLE Importacion.GuiasTurismoRegistrados (
    periodo    NVARCHAR(100),
    apellido   NVARCHAR(100),
    nombre     NVARCHAR(100),
    tipoDoc    NVARCHAR(100),
    numero     NVARCHAR(100),
    nRegistro  NVARCHAR(100),
    categorias NVARCHAR(100)
)
GO