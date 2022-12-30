-- 09_USP_ImportCoronaData.sql
--
-- Autor		: Roman Inglin, Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 28/12/2022	Romano Sabbatella: Erstellung
-- 

/*
-- Test

EXEC dbo.uspImportCoronaData @CsvPath = 'D:\Serioese_Projekte\Juventus\SKT-DB-Projektarbeit\file.csv'

SELECT * FROM CoronaDaten
SELECT * FROM AttributTyp
SELECT * FROM Attribut
SELECT * FROM Datum
SELECT * FROM Kanton

DELETE Attribut
DELETE CoronaDaten
DELETE AttributTyp
DELETE Datum
DELETE Kanton

*/

DROP PROCEDURE uspImportCoronaData
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE uspImportCoronaData
	@CsvPath varchar(500)
AS
BEGIN
	SET NOCOUNT ON;

	CREATE TABLE #TmpTable
	(
		date								date not null,
		time								varchar(20)	null,
		abbreviation_canton_and_fl			varchar(20) not null,
		ncumul_tested						int null,
		ncumul_conf							int null,
		new_hosp							int null,
		current_hosp						int null,
		current_icu							int null,
		current_vent						int null,
		ncumul_released						int null,
		ncumul_deceased						int null,
		source								varchar(500) not null,
		current_isolated					int null,
		current_quarantined					int null,
		current_quarantined_riskareatravel	int null
	);
	
	DECLARE @Sql varchar(2000)
	
	-- 0x0a --> lf
	SET @Sql = 'BULK INSERT #TmpTable FROM ''' + @CsvPath + ''' WITH (FIELDTERMINATOR = ' + ''',''' + ', FIRSTROW = 2, ROWTERMINATOR = ' + '''0x0a''' + ', KEEPNULLS)'
	print 'sql:'
	print @Sql
	EXEC (@Sql)

	-- Tansaction
	BEGIN TRANSACTION

	-- Deklarationen
	DECLARE @Date date, @CantonShort varchar(3), @Testet int, @Positiv int, @NeuHospitalisiert int, @Hospitalisiert int, @AufIps int, @MitBeatmung int, @Verstorben int, @Isoliert int, @InQuarantaene int;
	DECLARE curData CURSOR SCROLL LOCAL

	FOR SELECT date, abbreviation_canton_and_fl, ncumul_tested, ncumul_conf, new_hosp, current_hosp, current_icu, current_vent, ncumul_deceased, current_isolated, current_quarantined FROM #TmpTable;
	OPEN curData;
	FETCH NEXT FROM curData INTO @Date, @CantonShort, @Testet, @Positiv, @NeuHospitalisiert, @Hospitalisiert, @AufIps, @MitBeatmung, @Verstorben, @Isoliert, @InQuarantaene;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- Work
		EXEC dbo.uspInsertCoronaData @Date, @CantonShort, @Testet, @Positiv, @NeuHospitalisiert, @Hospitalisiert, @AufIps, @MitBeatmung, @Verstorben, @Isoliert, @InQuarantaene;
		-- Next
		FETCH NEXT FROM curData INTO @Date, @CantonShort, @Testet, @Positiv, @NeuHospitalisiert, @Hospitalisiert, @AufIps, @MitBeatmung, @Verstorben, @Isoliert, @InQuarantaene;
	END
	CLOSE curData;
	DEALLOCATE curData;
	
	/*
	-- Cleanup
	*/
	-- Transaction
	COMMIT
	-- Tmp Table
	DROP TABLE #TmpTable
END
GO
