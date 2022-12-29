-- 08_USP_InsertCoronaData.sql
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
	-- Kanton
	DECLARE @CantonID int, @DatumID int
	EXEC dbo.uspGetOrCreateCanton @CantonShort, @CantonID = @CantonID output;

	-- Datum
	EXEC dbo.uspGetOrCreateDatum @Date,	@DatumID = @DatumID output

	INSERT CoronaDaten 
		(DatumID, KantonID, Positiv, Verstorben, Isoliert, InQuarantaene)
	VALUES
		(@DatumID, @CantonID, @Positiv, @Verstorben, @Isoliert, @InQuarantaene)
	
	/*
	-- Attribut Typen
	*/
	DECLARE @TestetTypID int, @NeuHospitalisiertTypID int, @HospitalisiertTypID int, @AufIpsTypID int, @MitBeatmungTypID int;
	-- Getestet
	EXEC dbo.GetOrCreateAttributeType @AttributeTyp = 'ncumul_tested', @AttributeTypID = @TestetTypID output
	-- neu Hospitalisiert
	EXEC dbo.GetOrCreateAttributeType @AttributeTyp = 'new_hosp', @AttributeTypID = @NeuHospitalisiertTypID output
	-- Hospitalisiert
	EXEC dbo.GetOrCreateAttributeType @AttributeTyp = 'current_hosp', @AttributeTypID = @HospitalisiertTypID output
	-- AufIps
	EXEC dbo.GetOrCreateAttributeType @AttributeTyp = 'current_icu', @AttributeTypID = @AufIpsTypID output
	-- MitBeatmung
	EXEC dbo.GetOrCreateAttributeType @AttributeTyp = 'current_vent', @AttributeTypID = @MitBeatmungTypID output

	/*
	-- Attribute
	*/
	-- Getestet
	EXEC dbo.uspCreateOrUpdateAttribute	@DatumID = @DatumID, @AttributTypID = @TestetTypID, @Wert = @Testet
	-- neu Hospitalisiert
	EXEC dbo.uspCreateOrUpdateAttribute	@DatumID = @DatumID, @AttributTypID = @NeuHospitalisiertTypID, @Wert = @NeuHospitalisiert
	-- Hospitalisiert
	EXEC dbo.uspCreateOrUpdateAttribute	@DatumID = @DatumID, @AttributTypID = @HospitalisiertTypID, @Wert = @Hospitalisiert
	-- AufIps
	EXEC dbo.uspCreateOrUpdateAttribute	@DatumID = @DatumID, @AttributTypID = @AufIpsTypID, @Wert = @AufIps
	-- MitBeatmung
	EXEC dbo.uspCreateOrUpdateAttribute	@DatumID = @DatumID, @AttributTypID = @TestetTypID, @Wert = @MitBeatmung
END
GO
