USE botecopro_db;
GO
-- =========================================================================
-- Script: 09_create_api_crud.sql
-- Objetivo: Criação de Stored Procedures para CRUD (cadastramento e atualizações)
--          a serem consumidos pela API e pelo aplicativo Boteco Pro.
-- =========================================================================

/* =========================================================================
   LEGENDAS DAS CONVENÇÕES
   -----------------------
   - Todos os SPs retornam, em caso de sucesso, o ID da entidade criada ou 
     um código de status (0=sucesso, >0=erro) via SELECT.
   - Em caso de erro, usam RAISERROR para sinalizar falha.
   - As SPs aceitam somente parâmetros necessários ao registro; dados 
     relacionais (FK) devem existir previamente.
   - Mantém padrão de escrita: comentários em português, nomes “sp_” prefixados.
   ========================================================================= */


/* =========================================================================
   1. CRUD Clientes
   ========================================================================= */

/* ------------------------------------------------
   1.1. sp_cadastrar_cliente
   ------------------------------------------------
   Insere novo cliente e retorna o cliente_id.
   Parâmetros:
     @nome, @telefone, @email, @morada, @cidade,
     @codigo_postal, @contribuinte (NULL se não houver).
*/
CREATE PROCEDURE sp_cadastrar_cliente
    @nome           VARCHAR(150),
    @telefone       VARCHAR(20)    = NULL,
    @email          VARCHAR(100)   = NULL,
    @morada         VARCHAR(255)   = NULL,
    @cidade         VARCHAR(100)   = NULL,
    @codigo_postal  VARCHAR(20)    = NULL,
    @contribuinte   VARCHAR(20)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @nome IS NULL OR LTRIM(RTRIM(@nome)) = ''
    BEGIN
        RAISERROR('Nome do cliente é obrigatório.', 16, 1);
        RETURN;
    END

    INSERT INTO Cliente (
        nome, telefone, email, morada, cidade, codigo_postal, contribuinte
    ) VALUES (
        @nome, @telefone, @email, @morada, @cidade, @codigo_postal, @contribuinte
    );

    DECLARE @novo_cliente_id INT = SCOPE_IDENTITY();
    SELECT @novo_cliente_id AS cliente_id;
END;
GO

/* ------------------------------------------------
   1.2. sp_atualizar_cliente
   ------------------------------------------------
   Atualiza dados de um cliente existente.
   Parâmetros:
     @cliente_id, @nome, @telefone, @email, @morada, @cidade,
     @codigo_postal, @contribuinte.
*/
CREATE PROCEDURE sp_atualizar_cliente
    @cliente_id     INT,
    @nome           VARCHAR(150),
    @telefone       VARCHAR(20)    = NULL,
    @email          VARCHAR(100)   = NULL,
    @morada         VARCHAR(255)   = NULL,
    @cidade         VARCHAR(100)   = NULL,
    @codigo_postal  VARCHAR(20)    = NULL,
    @contribuinte   VARCHAR(20)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE cliente_id = @cliente_id)
    BEGIN
        RAISERROR('Cliente não encontrado.', 16, 1);
        RETURN;
    END

    UPDATE Cliente
    SET nome           = @nome,
        telefone       = @telefone,
        email          = @email,
        morada         = @morada,
        cidade         = @cidade,
        codigo_postal  = @codigo_postal,
        contribuinte   = @contribuinte
    WHERE cliente_id = @cliente_id;

    SELECT 0 AS status;  -- 0 indica sucesso
END;
GO

/* =========================================================================
   2. CRUD Mesas
   ========================================================================= */

/* ------------------------------------------------
   2.1. sp_cadastrar_mesa
   ------------------------------------------------
   Insere nova mesa.
   Parâmetros:
     @numero INT, @capacidade INT.
   Retorno: novo mesa_id.
*/
CREATE PROCEDURE sp_cadastrar_mesa
    @numero      INT,
    @capacidade  INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @numero IS NULL OR @capacidade IS NULL
    BEGIN
        RAISERROR('Número e capacidade são obrigatórios.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Mesa WHERE numero = @numero)
    BEGIN
        RAISERROR('Já existe uma mesa com este número.', 16, 1);
        RETURN;
    END

    INSERT INTO Mesa (numero, capacidade, status)
    VALUES (@numero, @capacidade, 'livre');

    DECLARE @novo_mesa_id INT = SCOPE_IDENTITY();
    SELECT @novo_mesa_id AS mesa_id;
END;
GO

/* ------------------------------------------------
   2.2. sp_atualizar_mesa
   ------------------------------------------------
   Atualiza dados de uma mesa existente (capacidade ou status).
   Parâmetros:
     @mesa_id INT, @numero INT, @capacidade INT, @status VARCHAR(20).
*/
CREATE PROCEDURE sp_atualizar_mesa
    @mesa_id     INT,
    @numero      INT        = NULL,
    @capacidade  INT        = NULL,
    @status      VARCHAR(20) = NULL  -- 'livre', 'ocupada', 'reservada'
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Mesa WHERE mesa_id = @mesa_id)
    BEGIN
        RAISERROR('Mesa não encontrada.', 16, 1);
        RETURN;
    END

    UPDATE Mesa
    SET 
        numero     = COALESCE(@numero, numero),
        capacidade = COALESCE(@capacidade, capacidade),
        status     = COALESCE(@status, status)
    WHERE mesa_id = @mesa_id;

    SELECT 0 AS status;
END;
GO

/* =========================================================================
   3. CRUD Funcionários
   ========================================================================= */

/* ------------------------------------------------
   3.1. sp_cadastrar_funcionario
   ------------------------------------------------
   Insere novo funcionário.
   Parâmetros:
     @nome, @data_nascimento, @telefone, @email,
     @cargo, @carreira_id, @data_admissao.
*/
CREATE PROCEDURE sp_cadastrar_funcionario
    @nome             VARCHAR(150),
    @data_nascimento  DATE             = NULL,
    @telefone         VARCHAR(20)      = NULL,
    @email            VARCHAR(100)     = NULL,
    @cargo            VARCHAR(100),
    @carreira_id      INT,
    @data_admissao    DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @nome IS NULL OR @cargo IS NULL OR @carreira_id IS NULL OR @data_admissao IS NULL
    BEGIN
        RAISERROR('Nome, cargo, carreira e data de admissão são obrigatórios.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Carreira WHERE carreira_id = @carreira_id)
    BEGIN
        RAISERROR('Carreira inválida.', 16, 1);
        RETURN;
    END

    INSERT INTO Funcionario (
        nome, data_nascimento, telefone, email, cargo, carreira_id, data_admissao
    )
    VALUES (
        @nome, @data_nascimento, @telefone, @email, @cargo, @carreira_id, @data_admissao
    );

    DECLARE @novo_funcionario_id INT = SCOPE_IDENTITY();
    SELECT @novo_funcionario_id AS funcionario_id;
END;
GO

/* ------------------------------------------------
   3.2. sp_atualizar_funcionario
   ------------------------------------------------
   Atualiza dados de um funcionário.
   Parâmetros:
     @funcionario_id, @nome, @data_nascimento, @telefone, @email,
     @cargo, @carreira_id.
*/
CREATE PROCEDURE sp_atualizar_funcionario
    @funcionario_id   INT,
    @nome             VARCHAR(150)     = NULL,
    @data_nascimento  DATE             = NULL,
    @telefone         VARCHAR(20)      = NULL,
    @email            VARCHAR(100)     = NULL,
    @cargo            VARCHAR(100)     = NULL,
    @carreira_id      INT              = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE funcionario_id = @funcionario_id)
    BEGIN
        RAISERROR('Funcionário não encontrado.', 16, 1);
        RETURN;
    END

    IF @carreira_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Carreira WHERE carreira_id = @carreira_id)
    BEGIN
        RAISERROR('Carreira inválida.', 16, 1);
        RETURN;
    END

    UPDATE Funcionario
    SET 
        nome            = COALESCE(@nome, nome),
        data_nascimento = COALESCE(@data_nascimento, data_nascimento),
        telefone        = COALESCE(@telefone, telefone),
        email           = COALESCE(@email, email),
        cargo           = COALESCE(@cargo, cargo),
        carreira_id     = COALESCE(@carreira_id, carreira_id)
    WHERE funcionario_id = @funcionario_id;

    SELECT 0 AS status;
END;
GO

/* =========================================================================
   4. CRUD Carreiras
   ========================================================================= */

/* ------------------------------------------------
   4.1. sp_cadastrar_carreira
   ------------------------------------------------
   Insere nova carreira (cargo e salário).
   Parâmetros:
     @nome VARCHAR(100), @salario_mensal DECIMAL(12,2).
*/
CREATE PROCEDURE sp_cadastrar_carreira
    @nome             VARCHAR(100),
    @salario_mensal   DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @nome IS NULL OR @salario_mensal IS NULL
    BEGIN
        RAISERROR('Nome e salário mensal são obrigatórios.', 16, 1);
        RETURN;
    END

    INSERT INTO Carreira (nome, salario_mensal)
    VALUES (@nome, @salario_mensal);

    DECLARE @novo_carreira_id INT = SCOPE_IDENTITY();
    SELECT @novo_carreira_id AS carreira_id;
END;
GO

/* ------------------------------------------------
   4.2. sp_atualizar_carreira
   ------------------------------------------------
   Atualiza nome ou salário de uma carreira existente.
   Parâmetros:
     @carreira_id INT, @nome VARCHAR(100), @salario_mensal DECIMAL(12,2).
*/
CREATE PROCEDURE sp_atualizar_carreira
    @carreira_id      INT,
    @nome             VARCHAR(100)      = NULL,
    @salario_mensal   DECIMAL(12,2)     = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Carreira WHERE carreira_id = @carreira_id)
    BEGIN
        RAISERROR('Carreira não encontrada.', 16, 1);
        RETURN;
    END

    UPDATE Carreira
    SET 
        nome            = COALESCE(@nome, nome),
        salario_mensal  = COALESCE(@salario_mensal, salario_mensal)
    WHERE carreira_id = @carreira_id;

    SELECT 0 AS status;
END;
GO

/* =========================================================================
   5. CRUD Produtos e Fornecedores
   ========================================================================= */

/* ------------------------------------------------
   5.1. sp_cadastrar_fornecedor
   ------------------------------------------------
   Insere novo fornecedor.
   Parâmetros:
     @nome, @telefone, @email, @endereco, @cidade, @codigo_postal, @pais.
*/
CREATE PROCEDURE sp_cadastrar_fornecedor
    @nome           VARCHAR(150),
    @telefone       VARCHAR(20)   = NULL,
    @email          VARCHAR(100)  = NULL,
    @endereco       VARCHAR(255)  = NULL,
    @cidade         VARCHAR(100)  = NULL,
    @codigo_postal  VARCHAR(20)   = NULL,
    @pais           VARCHAR(100)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @nome IS NULL OR LTRIM(RTRIM(@nome)) = ''
    BEGIN
        RAISERROR('Nome do fornecedor é obrigatório.', 16, 1);
        RETURN;
    END

    INSERT INTO Fornecedor (
        nome, telefone, email, endereco, cidade, codigo_postal, pais
    ) VALUES (
        @nome, @telefone, @email, @endereco, @cidade, @codigo_postal, @pais
    );

    DECLARE @novo_fornecedor_id INT = SCOPE_IDENTITY();
    SELECT @novo_fornecedor_id AS fornecedor_id;
END;
GO

/* ------------------------------------------------
   5.2. sp_atualizar_fornecedor
   ------------------------------------------------
   Atualiza dados de um fornecedor existente.
   Parâmetros:
     @fornecedor_id, @nome, @telefone, @email, @endereco, @cidade, @codigo_postal, @pais.
*/
CREATE PROCEDURE sp_atualizar_fornecedor
    @fornecedor_id  INT,
    @nome           VARCHAR(150)  = NULL,
    @telefone       VARCHAR(20)   = NULL,
    @email          VARCHAR(100)  = NULL,
    @endereco       VARCHAR(255)  = NULL,
    @cidade         VARCHAR(100)  = NULL,
    @codigo_postal  VARCHAR(20)   = NULL,
    @pais           VARCHAR(100)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Fornecedor WHERE fornecedor_id = @fornecedor_id)
    BEGIN
        RAISERROR('Fornecedor não encontrado.', 16, 1);
        RETURN;
    END

    UPDATE Fornecedor
    SET
        nome          = COALESCE(@nome, nome),
        telefone      = COALESCE(@telefone, telefone),
        email         = COALESCE(@email, email),
        endereco      = COALESCE(@endereco, endereco),
        cidade        = COALESCE(@cidade, cidade),
        codigo_postal = COALESCE(@codigo_postal, codigo_postal),
        pais          = COALESCE(@pais, pais)
    WHERE fornecedor_id = @fornecedor_id;

    SELECT 0 AS status;
END;
GO

/* ------------------------------------------------
   5.3. sp_cadastrar_produto
   ------------------------------------------------
   Insere novo produto (ingrediente, bebida ou sobremesa).
   Parâmetros:
     @nome, @tipo, @custo_unitario, @preco_venda,
     @stock_atual, @stock_minimo, @stock_encomenda, @fornecedor_id.
*/
CREATE PROCEDURE sp_cadastrar_produto
    @nome             VARCHAR(150),
    @tipo             VARCHAR(50),
    @custo_unitario   DECIMAL(10,2),
    @preco_venda      DECIMAL(10,2),
    @stock_atual      INT,
    @stock_minimo     INT,
    @stock_encomenda  INT,
    @fornecedor_id    INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @nome IS NULL OR @tipo IS NULL OR @custo_unitario IS NULL OR 
       @preco_venda IS NULL OR @stock_atual IS NULL OR 
       @stock_minimo IS NULL OR @stock_encomenda IS NULL OR 
       @fornecedor_id IS NULL
    BEGIN
        RAISERROR('Todos os parâmetros são obrigatórios.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Fornecedor WHERE fornecedor_id = @fornecedor_id)
    BEGIN
        RAISERROR('Fornecedor inválido.', 16, 1);
        RETURN;
    END

    INSERT INTO Produto (
        nome, tipo, custo_unitario, preco_venda, 
        stock_atual, stock_minimo, stock_encomenda, fornecedor_id
    ) VALUES (
        @nome, @tipo, @custo_unitario, @preco_venda,
        @stock_atual, @stock_minimo, @stock_encomenda, @fornecedor_id
    );

    DECLARE @novo_produto_id INT = SCOPE_IDENTITY();
    SELECT @novo_produto_id AS produto_id;
END;
GO

/* ------------------------------------------------
   5.4. sp_atualizar_produto
   ------------------------------------------------
   Atualiza dados de um produto existente.
   Parâmetros:
     @produto_id, @nome, @tipo, @custo_unitario, @preco_venda,
     @stock_minimo, @stock_encomenda, @fornecedor_id.
   NOTA: stock_atual é recalculado via trigger; não atualizado manualmente aqui.
*/
CREATE PROCEDURE sp_atualizar_produto
    @produto_id        INT,
    @nome              VARCHAR(150)    = NULL,
    @tipo              VARCHAR(50)     = NULL,
    @custo_unitario    DECIMAL(10,2)   = NULL,
    @preco_venda       DECIMAL(10,2)   = NULL,
    @stock_minimo      INT             = NULL,
    @stock_encomenda   INT             = NULL,
    @fornecedor_id     INT             = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Produto WHERE produto_id = @produto_id)
    BEGIN
        RAISERROR('Produto não encontrado.', 16, 1);
        RETURN;
    END

    IF @fornecedor_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Fornecedor WHERE fornecedor_id = @fornecedor_id)
    BEGIN
        RAISERROR('Fornecedor inválido.', 16, 1);
        RETURN;
    END

    UPDATE Produto
    SET
        nome             = COALESCE(@nome, nome),
        tipo             = COALESCE(@tipo, tipo),
        custo_unitario   = COALESCE(@custo_unitario, custo_unitario),
        preco_venda      = COALESCE(@preco_venda, preco_venda),
        stock_minimo     = COALESCE(@stock_minimo, stock_minimo),
        stock_encomenda  = COALESCE(@stock_encomenda, stock_encomenda),
        fornecedor_id    = COALESCE(@fornecedor_id, fornecedor_id)
    WHERE produto_id = @produto_id;

    SELECT 0 AS status;
END;
GO

/* =========================================================================
   6. CRUD Pratos
   ========================================================================= */

/* ------------------------------------------------
   6.1. sp_cadastrar_prato
   ------------------------------------------------
   Insere novo prato no cardápio.
   Parâmetros:
     @nome, @categoria_id, @descricao, @tempo_preparo, @preco_base.
*/
CREATE PROCEDURE sp_cadastrar_prato
    @nome            VARCHAR(150),
    @categoria_id    INT,
    @descricao        VARCHAR(255)   = NULL,
    @tempo_preparo   INT,
    @preco_base      DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @nome IS NULL OR @categoria_id IS NULL OR @tempo_preparo IS NULL OR @preco_base IS NULL
    BEGIN
        RAISERROR('Nome, categoria, tempo de preparo e preço base são obrigatórios.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Categoria WHERE categoria_id = @categoria_id)
    BEGIN
        RAISERROR('Categoria inválida.', 16, 1);
        RETURN;
    END

    INSERT INTO Prato (
        nome, categoria_id, descricao, tempo_preparo, preco_base
    ) VALUES (
        @nome, @categoria_id, @descricao, @tempo_preparo, @preco_base
    );

    DECLARE @novo_prato_id INT = SCOPE_IDENTITY();
    SELECT @novo_prato_id AS prato_id;
END;
GO

/* ------------------------------------------------
   6.2. sp_atualizar_prato
   ------------------------------------------------
   Atualiza dados de um prato existente.
   Parâmetros:
     @prato_id, @nome, @categoria_id, @descricao, @tempo_preparo, @preco_base.
*/
CREATE PROCEDURE sp_atualizar_prato
    @prato_id        INT,
    @nome            VARCHAR(150)   = NULL,
    @categoria_id    INT            = NULL,
    @descricao        VARCHAR(255)   = NULL,
    @tempo_preparo   INT            = NULL,
    @preco_base      DECIMAL(10,2)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Prato WHERE prato_id = @prato_id)
    BEGIN
        RAISERROR('Prato não encontrado.', 16, 1);
        RETURN;
    END

    IF @categoria_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Categoria WHERE categoria_id = @categoria_id)
    BEGIN
        RAISERROR('Categoria inválida.', 16, 1);
        RETURN;
    END

    UPDATE Prato
    SET
        nome           = COALESCE(@nome, nome),
        categoria_id   = COALESCE(@categoria_id, categoria_id),
        descricao       = COALESCE(@descricao, descricao),
        tempo_preparo  = COALESCE(@tempo_preparo, tempo_preparo),
        preco_base     = COALESCE(@preco_base, preco_base)
    WHERE prato_id = @prato_id;

    SELECT 0 AS status;
END;
GO

/* ------------------------------------------------
   6.3. sp_cadastrar_prato_ingrediente
   ------------------------------------------------
   Vincula ingrediente a um prato (PratoIngrediente).
   Parâmetros:
     @prato_id, @produto_id, @quantidade_necessaria.
   Retorna erro se já existir combinação.
*/
CREATE PROCEDURE sp_cadastrar_prato_ingrediente
    @prato_id               INT,
    @produto_id             INT,
    @quantidade_necessaria  DECIMAL(10,3)
AS
BEGIN
    SET NOCOUNT ON;

    IF @prato_id IS NULL OR @produto_id IS NULL OR @quantidade_necessaria IS NULL
    BEGIN
        RAISERROR('Prato, produto e quantidade são obrigatórios.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Prato WHERE prato_id = @prato_id)
    BEGIN
        RAISERROR('Prato não encontrado.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Produto WHERE produto_id = @produto_id)
    BEGIN
        RAISERROR('Produto não encontrado.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM PratoIngrediente
        WHERE prato_id = @prato_id AND produto_id = @produto_id
    )
    BEGIN
        RAISERROR('Ingrediente já vinculado a este prato.', 16, 1);
        RETURN;
    END

    INSERT INTO PratoIngrediente (
        prato_id, produto_id, quantidade_necessaria
    ) VALUES (
        @prato_id, @produto_id, @quantidade_necessaria
    );

    SELECT 0 AS status;
END;
GO

/* ------------------------------------------------
   6.4. sp_remover_prato_ingrediente
   ------------------------------------------------
   Remove vínculo entre prato e ingrediente.
   Parâmetros:
     @prato_id, @produto_id.
*/
CREATE PROCEDURE sp_remover_prato_ingrediente
    @prato_id    INT,
    @produto_id  INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM PratoIngrediente
        WHERE prato_id = @prato_id AND produto_id = @produto_id
    )
    BEGIN
        RAISERROR('Vínculo Prato-Ingrediente não encontrado.', 16, 1);
        RETURN;
    END

    DELETE FROM PratoIngrediente
    WHERE prato_id = @prato_id AND produto_id = @produto_id;

    SELECT 0 AS status;
END;
GO

/* =========================================================================
   7. CRUD Menus Especiais
   ========================================================================= */

/* ------------------------------------------------
   7.1. sp_cadastrar_menu_especial
   ------------------------------------------------
   Insere novo menu especial.
   Parâmetros:
     @nome, @descricao, @data_inicio, @data_fim, @preco_total.
*/
CREATE PROCEDURE sp_cadastrar_menu_especial
    @nome         VARCHAR(150),
    @descricao    VARCHAR(255)   = NULL,
    @data_inicio  DATE,
    @data_fim     DATE,
    @preco_total  DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @nome IS NULL OR @data_inicio IS NULL OR @data_fim IS NULL OR @preco_total IS NULL
    BEGIN
        RAISERROR('Nome, data de início, data de fim e preço total são obrigatórios.', 16, 1);
        RETURN;
    END

    IF @data_fim < @data_inicio
    BEGIN
        RAISERROR('Data de fim não pode ser anterior à data de início.', 16, 1);
        RETURN;
    END

    INSERT INTO MenuEspecial (
        nome, descricao, data_inicio, data_fim, preco_total
    ) VALUES (
        @nome, @descricao, @data_inicio, @data_fim, @preco_total
    );

    DECLARE @novo_menu_id INT = SCOPE_IDENTITY();
    SELECT @novo_menu_id AS menu_especial_id;
END;
GO

/* ------------------------------------------------
   7.2. sp_atualizar_menu_especial
   ------------------------------------------------
   Atualiza dados de um menu especial.
   Parâmetros:
     @menu_especial_id, @nome, @descricao, @data_inicio, @data_fim, @preco_total.
*/
CREATE PROCEDURE sp_atualizar_menu_especial
    @menu_especial_id INT,
    @nome             VARCHAR(150)   = NULL,
    @descricao        VARCHAR(255)   = NULL,
    @data_inicio      DATE           = NULL,
    @data_fim         DATE           = NULL,
    @preco_total      DECIMAL(12,2)  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM MenuEspecial WHERE menu_especial_id = @menu_especial_id)
    BEGIN
        RAISERROR('MenuEspecial não encontrado.', 16, 1);
        RETURN;
    END

    IF @data_inicio IS NOT NULL AND @data_fim IS NOT NULL AND @data_fim < @data_inicio
    BEGIN
        RAISERROR('Data de fim não pode ser anterior à data de início.', 16, 1);
        RETURN;
    END

    UPDATE MenuEspecial
    SET
        nome         = COALESCE(@nome, nome),
        descricao    = COALESCE(@descricao, descricao),
        data_inicio  = COALESCE(@data_inicio, data_inicio),
        data_fim     = COALESCE(@data_fim, data_fim),
        preco_total  = COALESCE(@preco_total, preco_total)
    WHERE menu_especial_id = @menu_especial_id;

    SELECT 0 AS status;
END;
GO

/* ------------------------------------------------
   7.3. sp_cadastrar_menu_especial_prato
   ------------------------------------------------
   Vincula prato a menu especial (MenuEspecialPrato).
   Parâmetros:
     @menu_especial_id, @prato_id, @ordem.
*/
CREATE PROCEDURE sp_cadastrar_menu_especial_prato
    @menu_especial_id  INT,
    @prato_id          INT,
    @ordem             INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @menu_especial_id IS NULL OR @prato_id IS NULL OR @ordem IS NULL
    BEGIN
        RAISERROR('MenuEspecial, prato e ordem são obrigatórios.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM MenuEspecial WHERE menu_especial_id = @menu_especial_id)
    BEGIN
        RAISERROR('MenuEspecial não encontrado.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Prato WHERE prato_id = @prato_id)
    BEGIN
        RAISERROR('Prato não encontrado.', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 FROM MenuEspecialPrato
        WHERE menu_especial_id = @menu_especial_id AND prato_id = @prato_id
    )
    BEGIN
        RAISERROR('Prato já vinculado a este menu.', 16, 1);
        RETURN;
    END

    INSERT INTO MenuEspecialPrato (
        menu_especial_id, prato_id, ordem
    ) VALUES (
        @menu_especial_id, @prato_id, @ordem
    );

    SELECT 0 AS status;
END;
GO

/* ------------------------------------------------
   7.4. sp_remover_menu_especial_prato
   ------------------------------------------------
   Remove vínculo entre menu especial e prato.
   Parâmetros:
     @menu_especial_id, @prato_id.
*/
CREATE PROCEDURE sp_remover_menu_especial_prato
    @menu_especial_id  INT,
    @prato_id          INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM MenuEspecialPrato
        WHERE menu_especial_id = @menu_especial_id AND prato_id = @prato_id
    )
    BEGIN
        RAISERROR('Vínculo MenuEspecial-Prato não encontrado.', 16, 1);
        RETURN;
    END

    DELETE FROM MenuEspecialPrato
    WHERE menu_especial_id = @menu_especial_id AND prato_id = @prato_id;

    SELECT 0 AS status;
END;
GO

/* =========================================================================
   8. CRUD Reservas
   ========================================================================= */

/* ------------------------------------------------
   8.1. sp_cadastrar_reserva
   ------------------------------------------------
   Insere nova reserva de mesa.
   Parâmetros:
     @cliente_id, @mesa_id, @data_reserva, @hora_reserva, @quantidade_pessoas.
*/
CREATE PROCEDURE sp_cadastrar_reserva
    @cliente_id         INT,
    @mesa_id            INT,
    @data_reserva       DATE,
    @hora_reserva       TIME,
    @quantidade_pessoas INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @cliente_id IS NULL OR @mesa_id IS NULL OR @data_reserva IS NULL OR 
       @hora_reserva IS NULL OR @quantidade_pessoas IS NULL
    BEGIN
        RAISERROR('Todos os parâmetros são obrigatórios.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE cliente_id = @cliente_id)
    BEGIN
        RAISERROR('Cliente não encontrado.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Mesa WHERE mesa_id = @mesa_id)
    BEGIN
        RAISERROR('Mesa não encontrada.', 16, 1);
        RETURN;
    END

    INSERT INTO Reserva (
        cliente_id, mesa_id, data_reserva, hora_reserva, quantidade_pessoas, status
    ) VALUES (
        @cliente_id, @mesa_id, @data_reserva, @hora_reserva, @quantidade_pessoas, 'ativa'
    );

    DECLARE @novo_reserva_id INT = SCOPE_IDENTITY();
    SELECT @novo_reserva_id AS reserva_id;
END;
GO

/* ------------------------------------------------
   8.2. sp_atualizar_reserva
   ------------------------------------------------
   Atualiza dados de uma reserva existente.
   Parâmetros:
     @reserva_id, @mesa_id, @data_reserva, @hora_reserva, @quantidade_pessoas, @status.
*/
CREATE PROCEDURE sp_atualizar_reserva
    @reserva_id         INT,
    @mesa_id            INT          = NULL,
    @data_reserva       DATE         = NULL,
    @hora_reserva       TIME         = NULL,
    @quantidade_pessoas INT          = NULL,
    @status             VARCHAR(20)  = NULL  -- 'ativa','confirmada','cancelada'
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Reserva WHERE reserva_id = @reserva_id)
    BEGIN
        RAISERROR('Reserva não encontrada.', 16, 1);
        RETURN;
    END

    IF @mesa_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Mesa WHERE mesa_id = @mesa_id)
    BEGIN
        RAISERROR('Mesa inválida.', 16, 1);
        RETURN;
    END

    UPDATE Reserva
    SET
        mesa_id            = COALESCE(@mesa_id, mesa_id),
        data_reserva       = COALESCE(@data_reserva, data_reserva),
        hora_reserva       = COALESCE(@hora_reserva, hora_reserva),
        quantidade_pessoas = COALESCE(@quantidade_pessoas, quantidade_pessoas),
        status             = COALESCE(@status, status)
    WHERE reserva_id = @reserva_id;

    SELECT 0 AS status;
END;
GO

/* =========================================================================
   9. CRUD Pedidos e Itens de Pedido
   ========================================================================= */

/* ------------------------------------------------
   9.1. sp_cadastrar_pedido
   ------------------------------------------------
   Insere novo pedido, com registro de mesa, funcionário, cliente opcional.
   Parâmetros:
     @mesa_id, @funcionario_id, @cliente_id (NULL se consumidor final).
   Retorna o novo pedido_id.
*/
CREATE PROCEDURE sp_cadastrar_pedido
    @mesa_id           INT,
    @funcionario_id    INT,
    @cliente_id        INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @mesa_id IS NULL OR @funcionario_id IS NULL
    BEGIN
        RAISERROR('Mesa e funcionário são obrigatórios.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Mesa WHERE mesa_id = @mesa_id)
    BEGIN
        RAISERROR('Mesa não encontrada.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE funcionario_id = @funcionario_id)
    BEGIN
        RAISERROR('Funcionário não encontrado.', 16, 1);
        RETURN;
    END

    IF @cliente_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Cliente WHERE cliente_id = @cliente_id)
    BEGIN
        RAISERROR('Cliente não encontrado.', 16, 1);
        RETURN;
    END

    INSERT INTO Pedido (
        mesa_id, funcionario_id, cliente_id, data_pedido, status
    ) VALUES (
        @mesa_id, @funcionario_id, @cliente_id, GETDATE(), 'pendente'
    );

    DECLARE @novo_pedido_id INT = SCOPE_IDENTITY();
    SELECT @novo_pedido_id AS pedido_id;
END;
GO

/* ------------------------------------------------
   9.2. sp_adicionar_item_pedido
   ------------------------------------------------
   Adiciona item ao pedido existente (prato ou produto).
   Parâmetros:
     @pedido_id, @prato_id (NULL se for produto genérico), 
     @produto_id (NULL se for prato), @quantidade, @preco_unitario, @iva.
   Retorna: 0 em sucesso; trigger cuidará do abatimento de estoque.
*/
CREATE PROCEDURE sp_adicionar_item_pedido
    @pedido_id         INT,
    @prato_id          INT           = NULL,
    @produto_id        INT           = NULL,
    @quantidade        INT,
    @preco_unitario    DECIMAL(10,2),
    @iva               DECIMAL(5,2)    -- 13.00 ou 23.00
AS
BEGIN
    SET NOCOUNT ON;

    IF @pedido_id IS NULL OR @quantidade IS NULL OR @preco_unitario IS NULL OR @iva IS NULL
    BEGIN
        RAISERROR('Pedido, quantidade, preço unitário e IVA são obrigatórios.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Pedido WHERE pedido_id = @pedido_id AND status NOT IN ('finalizado','cancelado'))
    BEGIN
        RAISERROR('Pedido não existe ou já finalizado/cancelado.', 16, 1);
        RETURN;
    END

    IF @prato_id IS NULL AND @produto_id IS NULL
    BEGIN
        RAISERROR('Deve especificar prato_id ou produto_id.', 16, 1);
        RETURN;
    END

    IF @prato_id IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Prato WHERE prato_id = @prato_id)
        BEGIN
            RAISERROR('Prato não encontrado.', 16, 1);
            RETURN;
        END
    END
    ELSE
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Produto WHERE produto_id = @produto_id)
        BEGIN
            RAISERROR('Produto não encontrado.', 16, 1);
            RETURN;
        END
    END

    INSERT INTO PedidoItem (
        pedido_id, prato_id, produto_id, quantidade, preco_unitario, iva
    ) VALUES (
        @pedido_id, @prato_id, @produto_id, @quantidade, @preco_unitario, @iva
    );

    SELECT 0 AS status;
END;
GO

/* ------------------------------------------------
   9.3. sp_atualizar_status_pedido
   ------------------------------------------------
   Atualiza status de um pedido existente.
   Parâmetros:
     @pedido_id, @status VARCHAR(20) (ex: 'em_preparo', 'pronto', 'entregue', 'finalizado', 'cancelado').
   NOTA: se for 'finalizado', trigger gerará fatura automaticamente.
*/
CREATE PROCEDURE sp_atualizar_status_pedido
    @pedido_id  INT,
    @status     VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Pedido WHERE pedido_id = @pedido_id)
    BEGIN
        RAISERROR('Pedido não encontrado.', 16, 1);
        RETURN;
    END

    UPDATE Pedido
    SET status = @status
    WHERE pedido_id = @pedido_id;

    SELECT 0 AS status;
END;
GO

/* ------------------------------------------------
   9.4. sp_cancelar_pedido
   ------------------------------------------------
   Cancela um pedido e, se houver itens, deve reverter os abatimentos de estoque.
   Parâmetros:
     @pedido_id INT.
   Implementação:
     - Atualiza status para 'cancelado'.
     - Percorre PedidoItem associados e insere MovimentacaoEstoque(tipo='entrada') 
       para reverter o abatimento (usando quantidade de Ingredientes × quantidade do item).
     - Atualiza Produto.stock_atual via sp_atualizar_stock_produto para cada produto afetado.
*/
CREATE PROCEDURE sp_cancelar_pedido
    @pedido_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Pedido WHERE pedido_id = @pedido_id)
    BEGIN
        RAISERROR('Pedido não encontrado.', 16, 1);
        RETURN;
    END

    DECLARE @status_atual VARCHAR(20);
    SELECT @status_atual = status FROM Pedido WHERE pedido_id = @pedido_id;

    IF @status_atual = 'cancelado'
    BEGIN
        RAISERROR('Pedido já está cancelado.', 16, 1);
        RETURN;
    END

    -- Marcar pedido como cancelado
    UPDATE Pedido
    SET status = 'cancelado'
    WHERE pedido_id = @pedido_id;

    -- Reverter abatimentos de estoque para cada item do pedido
    DECLARE @item_id       INT,
            @prato_id      INT,
            @produto_id    INT,
            @qtd_item      INT,
            @custo_unit    DECIMAL(10,2),
            @ingred_id     INT,
            @qtd_ingred    DECIMAL(10,3),
            @prod_custo    DECIMAL(10,2);

    DECLARE cursor_itens CURSOR FOR
        SELECT
            pedido_item_id,
            prato_id,
            produto_id,
            quantidade
        FROM PedidoItem
        WHERE pedido_id = @pedido_id;

    OPEN cursor_itens;
    FETCH NEXT FROM cursor_itens INTO @item_id, @prato_id, @produto_id, @qtd_item;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @prato_id IS NOT NULL
        BEGIN
            -- Para cada ingrediente do prato, inserir movimentação de entrada
            DECLARE cursor_ingr CURSOR FOR
                SELECT
                    pi.produto_id,
                    pi.quantidade_necessaria * @qtd_item AS qtd_a_reverter
                FROM PratoIngrediente pi
                WHERE pi.prato_id = @prato_id;

            OPEN cursor_ingr;
            FETCH NEXT FROM cursor_ingr INTO @ingred_id, @qtd_ingred;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                SELECT @prod_custo = custo_unitario FROM Produto WHERE produto_id = @ingred_id;

                INSERT INTO MovimentacaoEstoque (
                    produto_id, data_movimentacao, tipo, quantidade, preco_unitario, pedido_id
                ) VALUES (
                    @ingred_id, GETDATE(), 'entrada', @qtd_ingred, @prod_custo, @pedido_id
                );

                EXEC sp_atualizar_stock_produto @ingred_id;
                FETCH NEXT FROM cursor_ingr INTO @ingred_id, @qtd_ingred;
            END

            CLOSE cursor_ingr;
            DEALLOCATE cursor_ingr;
        END
        ELSE IF @produto_id IS NOT NULL
        BEGIN
            -- Reverter abatimento para produto genérico
            SELECT @custo_unit = custo_unitario FROM Produto WHERE produto_id = @produto_id;

            INSERT INTO MovimentacaoEstoque (
                produto_id, data_movimentacao, tipo, quantidade, preco_unitario, pedido_id
            ) VALUES (
                @produto_id, GETDATE(), 'entrada', @qtd_item, @custo_unit, @pedido_id
            );

            EXEC sp_atualizar_stock_produto @produto_id;
        END

        FETCH NEXT FROM cursor_itens INTO @item_id, @prato_id, @produto_id, @qtd_item;
    END

    CLOSE cursor_itens;
    DEALLOCATE cursor_itens;

    SELECT 0 AS status;
END;
GO

/* =========================================================================
   10. CRUD Encomendas Manuais
   ========================================================================= */

/* ------------------------------------------------
   10.1. sp_cadastrar_encomenda
   ------------------------------------------------
   Insere uma nova encomenda (pendente). Não insere itens.
   Parâmetros:
     @fornecedor_id INT.
   Retorna: novo encomenda_id.
*/
CREATE PROCEDURE sp_cadastrar_encomenda
    @fornecedor_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @fornecedor_id IS NULL
    BEGIN
        RAISERROR('Fornecedor é obrigatório.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Fornecedor WHERE fornecedor_id = @fornecedor_id)
    BEGIN
        RAISERROR('Fornecedor não encontrado.', 16, 1);
        RETURN;
    END

    INSERT INTO Encomenda (
        fornecedor_id, data_encomenda, status, valor_total
    ) VALUES (
        @fornecedor_id, GETDATE(), 'pendente', 0.00
    );

    DECLARE @novo_encomenda_id INT = SCOPE_IDENTITY();
    SELECT @novo_encomenda_id AS encomenda_id;
END;
GO

/* ------------------------------------------------
   10.2. sp_adicionar_item_encomenda
   ------------------------------------------------
   Adiciona item a uma encomenda existente.
   Parâmetros:
     @encomenda_id, @produto_id, @quantidade, @preco_unitario.
   Atualiza valor_total da encomenda.
*/
CREATE PROCEDURE sp_adicionar_item_encomenda
    @encomenda_id     INT,
    @produto_id       INT,
    @quantidade       INT,
    @preco_unitario   DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @encomenda_id IS NULL OR @produto_id IS NULL OR @quantidade IS NULL OR @preco_unitario IS NULL
    BEGIN
        RAISERROR('Encomenda, produto, quantidade e preço unitário são obrigatórios.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Encomenda WHERE encomenda_id = @encomenda_id AND status = 'pendente')
    BEGIN
        RAISERROR('Encomenda não existe ou não está pendente.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Produto WHERE produto_id = @produto_id)
    BEGIN
        RAISERROR('Produto não encontrado.', 16, 1);
        RETURN;
    END

    INSERT INTO EncomendaItem (
        encomenda_id, produto_id, quantidade, preco_unitario
    ) VALUES (
        @encomenda_id, @produto_id, @quantidade, @preco_unitario
    );

    -- Recalcular valor_total da encomenda
    UPDATE Encomenda
    SET valor_total = (
        SELECT SUM(quantidade * preco_unitario) 
        FROM EncomendaItem 
        WHERE encomenda_id = @encomenda_id
    )
    WHERE encomenda_id = @encomenda_id;

    SELECT 0 AS status;
END;
GO

/* ------------------------------------------------
   10.3. sp_cancelar_encomenda
   ------------------------------------------------
   Cancela uma encomenda pendente (status → 'cancelada').
   Parâmetros:
     @encomenda_id INT.
*/
CREATE PROCEDURE sp_cancelar_encomenda
    @encomenda_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @encomenda_id IS NULL
    BEGIN
        RAISERROR('Encomenda é obrigatória.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Encomenda WHERE encomenda_id = @encomenda_id)
    BEGIN
        RAISERROR('Encomenda não encontrada.', 16, 1);
        RETURN;
    END

    UPDATE Encomenda
    SET status = 'cancelada'
    WHERE encomenda_id = @encomenda_id;

    SELECT 0 AS status;
END;
GO

/* =========================================================================
   11. CRUD Registro de Horas
   ========================================================================= */

/* ------------------------------------------------
   11.1. sp_registrar_horas
   ------------------------------------------------
   Insere um registro de horas para funcionário.
   Parâmetros:
     @funcionario_id, @data_registro, @horas_normais, @horas_extra.
*/
CREATE PROCEDURE sp_registrar_horas
    @funcionario_id   INT,
    @data_registro    DATE,
    @horas_normais    DECIMAL(4,2),
    @horas_extra      DECIMAL(4,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @funcionario_id IS NULL OR @data_registro IS NULL OR @horas_normais IS NULL OR @horas_extra IS NULL
    BEGIN
        RAISERROR('Funcionário, data, horas normais e horas extra são obrigatórios.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE funcionario_id = @funcionario_id)
    BEGIN
        RAISERROR('Funcionário não encontrado.', 16, 1);
        RETURN;
    END

    INSERT INTO RegistroHoras (
        funcionario_id, data_registro, horas_normais, horas_extra
    ) VALUES (
        @funcionario_id, @data_registro, @horas_normais, @horas_extra
    );

    SELECT 0 AS status;
END;
GO

/* ------------------------------------------------
   11.2. sp_atualizar_registro_horas
   ------------------------------------------------
   Atualiza registro de horas existente.
   Parâmetros:
     @registro_horas_id, @data_registro, @horas_normais, @horas_extra.
*/
CREATE PROCEDURE sp_atualizar_registro_horas
    @registro_horas_id INT,
    @data_registro     DATE            = NULL,
    @horas_normais     DECIMAL(4,2)    = NULL,
    @horas_extra       DECIMAL(4,2)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM RegistroHoras WHERE registro_horas_id = @registro_horas_id)
    BEGIN
        RAISERROR('Registro de horas não encontrado.', 16, 1);
        RETURN;
    END

    UPDATE RegistroHoras
    SET
        data_registro  = COALESCE(@data_registro, data_registro),
        horas_normais  = COALESCE(@horas_normais, horas_normais),
        horas_extra    = COALESCE(@horas_extra, horas_extra)
    WHERE registro_horas_id = @registro_horas_id;

    SELECT 0 AS status;
END;
GO

/* =========================================================================
   12. CRUD Faturamento Manual (se necessário)
   ========================================================================= */

/* ------------------------------------------------
   12.1. sp_cadastrar_fatura_manual
   ------------------------------------------------
   Insere fatura manual (caso algum pedido precise de correção).
   Parâmetros:
     @pedido_id, @cliente_id (NULL se consumidor final),
     @nome_cliente, @morada_cliente, @cidade_cliente, @codigo_postal,
     @contribuinte, @subtotal_comida, @subtotal_bebida, @iva_comida, @iva_bebida, @total.
*/
CREATE PROCEDURE sp_cadastrar_fatura_manual
    @pedido_id        INT,
    @cliente_id       INT            = NULL,
    @nome_cliente     VARCHAR(150)   = NULL,
    @morada_cliente   VARCHAR(255)   = NULL,
    @cidade_cliente   VARCHAR(100)   = NULL,
    @codigo_postal    VARCHAR(20)    = NULL,
    @contribuinte     VARCHAR(20)    = NULL,
    @subtotal_comida  DECIMAL(12,2),
    @subtotal_bebida  DECIMAL(12,2),
    @iva_comida       DECIMAL(10,2),
    @iva_bebida       DECIMAL(10,2),
    @total            DECIMAL(14,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF @pedido_id IS NULL OR @subtotal_comida IS NULL OR @subtotal_bebida IS NULL 
       OR @iva_comida IS NULL OR @iva_bebida IS NULL OR @total IS NULL
    BEGIN
        RAISERROR('Pedido, subtotais, IVAs e total são obrigatórios.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Pedido WHERE pedido_id = @pedido_id)
    BEGIN
        RAISERROR('Pedido não encontrado.', 16, 1);
        RETURN;
    END

    IF @cliente_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Cliente WHERE cliente_id = @cliente_id)
    BEGIN
        RAISERROR('Cliente não encontrado.', 16, 1);
        RETURN;
    END

    INSERT INTO Fatura (
        pedido_id,
        cliente_id,
        data_emissao,
        tipo_fatura,
        nome_cliente,
        morada_cliente,
        cidade_cliente,
        codigo_postal,
        contribuinte,
        subtotal_comida,
        subtotal_bebida,
        iva_comida,
        iva_bebida,
        total
    )
    VALUES (
        @pedido_id,
        @cliente_id,
        GETDATE(),
        CASE WHEN @cliente_id IS NULL THEN 'consumidor_final' ELSE 'empresa' END,
        @nome_cliente,
        @morada_cliente,
        @cidade_cliente,
        @codigo_postal,
        @contribuinte,
        @subtotal_comida,
        @subtotal_bebida,
        @iva_comida,
        @iva_bebida,
        @total
    );

    DECLARE @novo_fatura_id INT = SCOPE_IDENTITY();
    SELECT @novo_fatura_id AS fatura_id;
END;
GO

/* =========================================================================
   13. Changelog / Observações
   =========================================================================
   - Todas as SPs prefixadas com “sp_” podem ser invocadas pela API via EXEC.
   - Em caso de erros de validação, usam RAISERROR, retornando mensagem e abortando.
   - Retorno de IDs para facilitar ligação no código da aplicação cliente.
   - Triggers existentes continuarão a funcionar (ex.: abatimento de estoque,
     geração automática de fatura ao finalizar pedido).
   - Para consumo pela API, o usuário deverá ter permissão EXECUTE em todas as SPs.
   ========================================================================= */

