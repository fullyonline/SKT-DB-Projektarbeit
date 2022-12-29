-- 06_USP_GetOrCreateAttributeType.sql
--
-- Autor		: Roman Inglin, Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 28/12/2022	Romano Sabbatella: Erstellung
-- 

DROP PROCEDURE GetOrCreateAttributeType
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GetOrCreateAttributeType
	@AttributeTyp varchar(100),
	@AttributeTypID int output
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT @AttributeTypID = AttributTypID FROM AttributTyp WHERE AttributTyp = @AttributeTyp;

	IF @AttributeTypID IS NULL
	BEGIN
		INSERT AttributTyp (AttributTyp, Bezeichnung) VALUES (@AttributeTyp, dbo.GetAttributeTypeName(@AttributeTyp))
		SET @AttributeTypID = SCOPE_IDENTITY();
	END
END
GO
