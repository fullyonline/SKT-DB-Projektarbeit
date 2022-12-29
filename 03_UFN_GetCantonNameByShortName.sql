-- 03_UFN_GetCantonNameByShortName.sql
--
-- Autor		: Roman Inglin, Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 28/12/2022	Romano Sabbatella: Erstellung
-- 

DROP FUNCTION dbo.ufnGetCantonNameByShortName
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION ufnGetCantonNameByShortName(@ShortName VARCHAR(3))
RETURNS VARCHAR(100)
AS 
BEGIN
	RETURN CASE
		WHEN @ShortName = 'ZH' THEN 'Zürich'
		WHEN @ShortName = 'BE' THEN 'Bern'
		WHEN @ShortName = 'LU' THEN 'Luzern'
		WHEN @ShortName = 'UR' THEN 'Uri'
		WHEN @ShortName = 'SZ' THEN 'Schwyz'
		WHEN @ShortName = 'OW' THEN 'Obwalden'
		WHEN @ShortName = 'NW' THEN 'Nidwalden'
		WHEN @ShortName = 'GL' THEN 'Glarus'
		WHEN @ShortName = 'ZG' THEN 'Zug'
		WHEN @ShortName = 'FR' THEN 'Freiburg'
		WHEN @ShortName = 'SO' THEN 'Solothurn'
		WHEN @ShortName = 'BS' THEN 'Basel-Stadt'
		WHEN @ShortName = 'BL' THEN 'Basel-Landschaft'
		WHEN @ShortName = 'SH' THEN 'Schaffhausen'
		WHEN @ShortName = 'AR' THEN 'Appenzell Ausserrhoden'
		WHEN @ShortName = 'AI' THEN 'Appenzell Innerrhoden'
		WHEN @ShortName = 'SG' THEN 'St. Gallen'
		WHEN @ShortName = 'GR' THEN 'Graubünden'
		WHEN @ShortName = 'AG' THEN 'Aargau'
		WHEN @ShortName = 'TG' THEN 'Thurgau'
		WHEN @ShortName = 'TI' THEN 'Tessin'
		WHEN @ShortName = 'VD' THEN 'Waadt'
		WHEN @ShortName = 'VS' THEN 'Wallis'
		WHEN @ShortName = 'NE' THEN 'Neuenburg'
		WHEN @ShortName = 'GE' THEN 'Genf'
		WHEN @ShortName = 'JU' THEN 'Jura'
		WHEN @ShortName = 'FL' THEN 'Fürstentum Liechtenstein'
	END
END
GO



