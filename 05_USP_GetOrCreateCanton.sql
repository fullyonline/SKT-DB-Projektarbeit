-- 05_USP_GetOrCreateCanton.sql
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

DECLARE 
EXEC dbo.uspGetOrCreateCanton 


*/

DROP PROCEDURE uspGetOrCreateCanton
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE uspGetOrCreateCanton
	@CantonShort varchar(3),
	@CantonID int output
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @CantonID = KantonID FROM Kanton WHERE Kurzzeichen = @CantonShort;
	IF @CantonID is null
	BEGIN
		EXEC dbo.CreateCanton @CantonShort, @NewID = @CantonID output
	END


END
GO
