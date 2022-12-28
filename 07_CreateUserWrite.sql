-- 07_CreateUserWrite.sql
--
-- Autor		: Romano Sabbatella
-- Projekt		: Projektarbeit Datenbank 2 - Juventus
-- Version		: 1.0
-- 
-- Change log
-- 28/12/2022	Romano Sabbatella: Erstellung
-- 

USE [master]
GO

-- create login

-- Password: 1234s
CREATE LOGIN [TTRead] WITH PASSWORD=N'YKAGd35qXY2XG0BBKHTXH/rJj0C4fn7GqMoYPwbkWE4=', DEFAULT_DATABASE=[Tontraeger], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER LOGIN [TTRead] ENABLE
GO

-- create user

USE [Tontraeger]
GO

CREATE USER [TTRead] FOR LOGIN [TTRead] WITH DEFAULT_SCHEMA=[dbo]
GO

-- grants

-- Select Privileg erteilen
GRANT select ON Album TO [TTRead];
GRANT select ON Ort TO [TTRead];
GRANT select ON AlbumInhalt TO [TTRead];
GRANT select ON Interpret TO [TTRead];
GRANT select ON InterpretList TO [TTRead];
GRANT select ON Musikstueck TO [TTRead];
GRANT select ON Stil TO [TTRead];
GRANT select ON Traeger TO [TTRead];
GRANT select ON TraegerList TO [TTRead];
