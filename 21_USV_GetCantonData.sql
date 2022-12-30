-- 21_USV_GetCantonData.sql
--
-- Autor		: Roman Inglin, Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 29/12/2022	Roman Inglin, Romano Sabbatella: Erstellung
--

DROP VIEW usvGetCantonData
GO

CREATE VIEW usvGetCantonData
AS
	SELECT
		Kanton.Bezeichnung as Kantonname, Kanton.Kurzzeichen as Kantonkuerzel,
		Positiv, Verstorben, Isoliert, InQuarantaene, Datum.Datum
	FROM CoronaDaten 
	JOIN Kanton ON CoronaDaten.KantonID = Kanton.KantonID
	JOIN Datum ON CoronaDaten.DatumID = Datum.DatumID
	-- ORDER BY Kantonname ASC, Datum