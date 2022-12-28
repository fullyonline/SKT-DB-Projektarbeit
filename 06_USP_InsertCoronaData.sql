-- 06_USP_InsertCoronaData.sql
--
-- Autor		: Roman Inglin, Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 28/12/2022	Romano Sabbatella: Erstellung
-- 

DROP PROCEDURE uspInsertCoronaData
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE uspInsertCoronaData
	@Date date, 
	@CantonShort varchar(3), 
	@Testet int, 
	@Positiv int, 
	@NeuHospitalisiert int, 
	@Hospitalisiert int, 
	@AufIps int, 
	@MitBeatmung int, 
	@Verstorben int, 
	@Isoliert int, 
	@InQuarantaene int
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @CantonID int
	EXEC dbo.uspGetOrCreateCanton @CantonShort, @CantonID = @CantonID output;

	INSERT CoronaDaten 
		(Datum, KantonID, Getestet, Positiv, NeuHospitalisiert, Hospitalisiert, AufIPS, MitBeatmung, Verstorben, Isoliert, InQuarantaene)
	VALUES
		(@Date, @CantonID, @Testet, @Positiv, @NeuHospitalisiert, @Hospitalisiert, @AufIps, @MitBeatmung, @Verstorben, @Isoliert, @InQuarantaene)
END
GO
