-- 20_USV_GetCantons.sql
--
-- Autor		: Roman Inglin, Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 29/12/2022	Roman Inglin, Romano Sabbatella: Erstellung
-- 

DROP VIEW usvGetCanton
GO

CREATE VIEW usvGetCanton
AS
	SELECT Bezeichnung as Kantonname FROM Kanton;