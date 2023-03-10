/*
DROP USER ScriptingUser;
go

DROP LOGIN ScriptingUser;
go

DROP USER ReadingUser;
go

DROP LOGIN ReadingUser;
go

select * from sys.server_principals
DELETE sys.server_principals WHERE principal_id = 271;

-- TO KILL a Logged in user:

SELECT conn.session_id, host_name, program_name,
    nt_domain, login_name, connect_time, last_request_end_time 
FROM sys.dm_exec_sessions AS sess
JOIN sys.dm_exec_connections AS conn
   ON sess.session_id = conn.session_id;

KILL 60
*/

use master
go

-- create login

CREATE LOGIN ScriptingUser WITH PASSWORD = 'S1cheresPassw0rt', DEFAULT_DATABASE=Corona, DEFAULT_LANGUAGE = German, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
GO

ALTER LOGIN ScriptingUser ENABLE;
GO

ALTER SERVER ROLE bulkadmin ADD MEMBER ScriptingUser

-- create user

USE Corona;
GO

CREATE USER ScriptingUser FOR LOGIN ScriptingUser WITH DEFAULT_SCHEMA = Corona;
GO

-- grants

-- Privilegien erteilen
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON Attribut TO ScriptingUser;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON AttributTyp TO ScriptingUser;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON CoronaDaten TO ScriptingUser;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON Datum TO ScriptingUser;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE ON Kanton TO ScriptingUser;

GRANT EXEC ON GetOrCreateAttributeType TO ScriptingUser;
GRANT EXEC ON uspCreateOrUpdateAttribute TO ScriptingUser;
GRANT EXEC ON uspGetOrCreateCanton TO ScriptingUser;
GRANT EXEC ON uspGetOrCreateDatum TO ScriptingUser;
GRANT EXEC ON uspImportCoronaData TO ScriptingUser;
GRANT EXEC ON uspInsertCoronaData TO ScriptingUser;


use master
go

-- create login

CREATE LOGIN ReadingUser WITH PASSWORD = 'S1cheresJuventusPassw0rt', DEFAULT_DATABASE=Corona, DEFAULT_LANGUAGE = German, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;
GO

ALTER LOGIN ReadingUser ENABLE;
GO


-- create user

USE Corona;
GO

CREATE USER ReadingUser FOR LOGIN ReadingUser WITH DEFAULT_SCHEMA = Corona;
GO

-- grants

-- Select Privileg erteilen
GRANT SELECT ON usvGetCanton TO ReadingUser;
GRANT SELECT ON usvGetCantonData TO ReadingUser;
GRANT SELECT ON usvGetSwissData TO ReadingUser;