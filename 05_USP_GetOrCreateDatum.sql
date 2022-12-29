-- 05_USP_GetOrCreateDatum.sql
--
-- Autor		: Roman Inglin, Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 28/12/2022	Romano Sabbatella: Erstellung
-- 

DROP PROCEDURE uspGetOrCreateDatum
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE uspGetOrCreateDatum
	@Date date,
	@DatumID int output
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT @DatumID = DatumID FROM Datum WHERE Datum = @Date;

	IF @DatumID IS NULL
	BEGIN
		INSERT Datum (Datum) VALUES (@Date)
		SET @DatumID = SCOPE_IDENTITY();
	END
END
GO
