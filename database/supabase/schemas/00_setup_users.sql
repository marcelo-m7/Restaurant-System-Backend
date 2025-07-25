-- ============================================
-- [Monynha Softwares] - BotecoPro Database Initialization
-- Database, Login, User and Permissions Setup
-- ============================================

-- 1. Create database (if it doesn't exist)
IF NOT EXISTS (
    SELECT name 
    FROM sys.databases 
    WHERE name = N'botecopro_app_db'
)
BEGIN
    CREATE DATABASE botecopro_app_db;
    PRINT 'Database created: botecopro_app_db';
END
ELSE
BEGIN
    PRINT 'Database already exists.';
END
GO

-- 2. Create server-level login (if it doesn't exist)
IF NOT EXISTS (
    SELECT name 
    FROM sys.sql_logins 
    WHERE name = N'boteco_user'
)
BEGIN
    CREATE LOGIN boteco_user 
    WITH PASSWORD = 'Monynha:BotecoPro!',
         CHECK_POLICY = ON;
    PRINT 'Login created: boteco_user';
END
ELSE
BEGIN
    PRINT 'Login already exists.';
END
GO

-- 3. Access the database to configure the user
USE botecopro_app_db;
GO

-- 4. Create user in the database (linked to login)
IF NOT EXISTS (
    SELECT name 
    FROM sys.database_principals 
    WHERE name = N'boteco_user'
)
BEGIN
    CREATE USER boteco_user FOR LOGIN boteco_user;
    PRINT 'User created in the database: boteco_user';
END
ELSE
BEGIN
    PRINT 'User already exists in the database.';
END
GO

-- 5. Create custom EXECUTE role (optional)
IF NOT EXISTS (
    SELECT * FROM sys.database_principals 
    WHERE name = N'db_executor'
)
BEGIN
    CREATE ROLE db_executor;
    GRANT EXECUTE TO db_executor;
    PRINT 'Role db_executor created with execute permissions.';
END
GO

-- 6. Assign permissions to the user
EXEC sp_addrolemember 'db_datareader', 'boteco_user';  -- Read
EXEC sp_addrolemember 'db_datawriter', 'boteco_user';  -- Write
EXEC sp_addrolemember 'db_executor', 'boteco_user';    -- Execute
GO

PRINT 'Configuration completed successfully!';
