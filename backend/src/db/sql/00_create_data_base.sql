-- Criação do banco de dados
IF DB_ID(N'botecopro_db') IS NULL
BEGIN
    CREATE DATABASE botecopro_db;
END;
GO

USE botecopro_db;
GO

-- 1. Criar login de servidor (login)
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'botecopro_user')
BEGIN
    CREATE LOGIN botecopro_user  
        WITH PASSWORD = 'senhaSegura123';
END;
GO

-- 2. Criar usuário de banco de dados
USE botecopro_db;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'botecopro_user')
BEGIN
    CREATE USER botecopro_user  
        FOR LOGIN botecopro_user;
END;
GO

-- 3. Conceder privilégios no banco (pode ajustar conforme escopo necessário)
ALTER ROLE db_owner  
    ADD MEMBER botecopro_user;
GO

SELECT '✅ Utilizador botecopro_user configurado' AS info;
