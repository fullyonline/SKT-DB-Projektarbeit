-- 07_USP_CreateOrUpdateAttribute.sql
--
-- Autor		: Roman Inglin, Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 28/12/2022	Romano Sabbatella: Erstellung
-- 

DROP PROCEDURE uspCreateOrUpdateAttribute
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE uspCreateOrUpdateAttribute
	@DatumID int,
	@AttributTypID int,
	@Wert int
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @AttributID int, @NeuerWert int;

	SET @NeuerWert = ISNULL(@Wert, 0);

	SELECT @AttributID = AttributID FROM Attribut WHERE AttributTypID = @AttributTypID AND DatumID = @DatumID;

	IF @AttributID IS NULL
		BEGIN
			INSERT Attribut (AttributTypID, DatumID, Wert) VALUES (@AttributTypID, @DatumID, @NeuerWert);
		END
	ELSE
		BEGIN
			UPDATE Attribut SET Wert = Wert + @NeuerWert WHERE AttributID = @AttributID;
		END
END
GO
