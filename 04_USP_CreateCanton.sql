-- 04_USP_CreateCanton.sql
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

DECLARE @Id int
EXEC dbo.CreateCanton 'ZH', @NewID = @Id output
PRINT @Id

*/

DROP PROCEDURE CreateCanton
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE CreateCanton
	@CantonShort varchar(3),
	@NewID int output
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT Kanton (Bezeichnung, Kurzzeichen) VALUES (dbo.ufnGetCantonNameByShortName(@CantonShort), @CantonShort);
	SELECT @NewID = KantonID FROM Kanton WHERE Kurzzeichen = @CantonShort;
END
GO
