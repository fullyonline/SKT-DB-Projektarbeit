-- 22_USV_GetSwissData.sql
--
-- Autor		: Roman Inglin, Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 30/12/2022	Roman Inglin, Romano Sabbatella: Erstellung
--

DROP VIEW usvGetSwissData
GO

CREATE VIEW usvGetSwissData
AS

SELECT 
	SUM(CoronaDaten.Positiv) as Positiv, SUM(CoronaDaten.Verstorben) as Verstorben,
	SUM(CoronaDaten.Isoliert) as Isoliert , SUM(CoronaDaten.InQuarantaene) as InQuarantaene,
	Datum.Datum, Datum.DatumID,
	(SELECT Attribut.Wert FROM Attribut JOIN AttributTyp ON Attribut.AttributTypID = AttributTyp.AttributTypID WHERE AttributTyp.AttributTyp = 'current_icu' AND Attribut.DatumID = Datum.DatumID) as AktuellAufIntensivstation,
	(SELECT Attribut.Wert FROM Attribut JOIN AttributTyp ON Attribut.AttributTypID = AttributTyp.AttributTypID WHERE AttributTyp.AttributTyp = 'new_hosp' AND Attribut.DatumID = Datum.DatumID) as NeuHospitalisiert,
	(SELECT Attribut.Wert FROM Attribut JOIN AttributTyp ON Attribut.AttributTypID = AttributTyp.AttributTypID WHERE AttributTyp.AttributTyp = 'current_hosp' AND Attribut.DatumID = Datum.DatumID) as AktuellHospitalisiert,
	(SELECT Attribut.Wert FROM Attribut JOIN AttributTyp ON Attribut.AttributTypID = AttributTyp.AttributTypID WHERE AttributTyp.AttributTyp = 'ncumul_tested' AND Attribut.DatumID = Datum.DatumID) as Getestet,
	(SELECT Attribut.Wert FROM Attribut JOIN AttributTyp ON Attribut.AttributTypID = AttributTyp.AttributTypID WHERE AttributTyp.AttributTyp = 'current_vent' AND Attribut.DatumID = Datum.DatumID) as AktuellMitBeatmungsgeraet
FROM CoronaDaten
JOIN Datum ON CoronaDaten.DatumID = Datum.DatumID
GROUP BY Datum.Datum, Datum.DatumID
