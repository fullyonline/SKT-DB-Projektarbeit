/*
DROP USER ScriptingUser;
go

select * from sys.server_principals
DELETE sys.server_principals WHERE principal_id = 271;


*/

use master
go

CREATE LOGIN ScriptingUser WITH PASSWORD = 'S1cheresPassw0rt', DEFAULT_LANGUAGE = German;
go

CREATE USER ScriptingUser WITH DEFAULT_SCHEMA = Corona;
go