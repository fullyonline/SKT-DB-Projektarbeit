-- 02_UFN_GetAttributeTypeName.sql
--
-- Autor		: Roman Inglin, Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 29/12/2022	Romano Sabbatella: Erstellung
-- 

DROP FUNCTION dbo.GetAttributeTypeName
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION GetAttributeTypeName(@Attribute VARCHAR(20))
RETURNS VARCHAR(100)
AS 
BEGIN
	RETURN CASE
		WHEN @Attribute = 'ncumul_tested' THEN 'Getestet'
		WHEN @Attribute = 'new_hosp' THEN 'Neu Hospitalisiert'
		WHEN @Attribute = 'current_hosp' THEN 'Aktuell Hospitalisiert'
		WHEN @Attribute = 'current_icu' THEN 'Aktuell auf der Intensivstation'
		WHEN @Attribute = 'current_vent' THEN 'Aktuell mit Beatmungsgerät'
	END
END
GO



