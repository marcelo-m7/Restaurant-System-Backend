USE botecopro_db;
GO

-- =========================================================================
-- Script: 06_create_triggers.sql
-- Objetivo: Criação de Triggers para automatizar estoque, faturas e encomendas
-- =========================================================================

/* ------------------------------------------------
   6.1. Procedimento Auxiliar: sp_abatimento_estoque_pedidoitem
   ------------------------------------------------ */
CREATE PROCEDURE sp_abatimento_estoque_pedidoitem
    @pedido_item_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @prato_id       INT,
            @produto_id     INT,
            @quantidade     INT,
            @preco_unitario DECIMAL(10,2),
            @pedido_id      INT;

    SELECT
        @prato_id       = prato_id,
        @produto_id     = produto_id,
        @quantidade     = quantidade,
        @preco_unitario = preco_unitario,
        @pedido_id      = pedido_id
    FROM PedidoItem
    WHERE pedido_item_id = @pedido_item_id;

    IF @prato_id IS NOT NULL
    BEGIN
        -- Para cada ingrediente do prato, abater no estoque
        INSERT INTO MovimentacaoEstoque (produto_id, data_movimentacao, tipo, quantidade, preco_unitario, pedido_id)
        SELECT 
            pi.produto_id,
            GETDATE(),
            'saida',
            pi.quantidade_necessaria * @quantidade,
            p.custo_unitario,
            @pedido_id
        FROM PratoIngrediente pi
        JOIN Produto p
            ON pi.produto_id = p.produto_id
        WHERE pi.prato_id = @prato_id;
    END
    ELSE IF @produto_id IS NOT NULL
    BEGIN
        -- Se for produto genérico (bebida ou sobremesa)
        INSERT INTO MovimentacaoEstoque (produto_id, data_movimentacao, tipo, quantidade, preco_unitario, pedido_id)
        VALUES
        (
            @produto_id,
            GETDATE(),
            'saida',
            @quantidade,
            @preco_unitario,
            @pedido_id
        );
    END;
END;
GO

/* ------------------------------------------------
   6.2. Trigger: trg_abatimento_estoque_quando_inserir_pedidoitem
   ------------------------------------------------ */
CREATE TRIGGER trg_abatimento_estoque_quando_inserir_pedidoitem
ON PedidoItem
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @new_id INT;
    SELECT @new_id = i.pedido_item_id FROM inserted i;

    EXEC sp_abatimento_estoque_pedidoitem @new_id;
END;
GO

/* ------------------------------------------------
   6.3. Procedimento Auxiliar: sp_atualizar_stock_produto
   ------------------------------------------------ */
CREATE PROCEDURE sp_atualizar_stock_produto
    @produto_id INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @novo_stock INT;

    SELECT @novo_stock = ISNULL(
        (
            SELECT 
                SUM(
                    CASE WHEN me.tipo = 'entrada' THEN me.quantidade
                         WHEN me.tipo = 'saida'  THEN -me.quantidade
                    END
                )
            FROM MovimentacaoEstoque me
            WHERE me.produto_id = @produto_id
        ), 0);

    UPDATE Produto
    SET stock_atual = @novo_stock
    WHERE produto_id = @produto_id;
END;
GO

/* ------------------------------------------------
   6.4. Trigger: trg_atualizar_stock_e_verificar_minimo
   ------------------------------------------------ */
CREATE TRIGGER trg_atualizar_stock_e_verificar_minimo
ON MovimentacaoEstoque
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @produto_id    INT,
            @tipo          VARCHAR(20),
            @stock_minimo  INT,
            @stock_atual   INT,
            @stock_encom   INT,
            @fornecedor_id INT,
            @quantidade_a_encomendar INT;

    SELECT
        @produto_id = i.produto_id,
        @tipo       = i.tipo
    FROM inserted i;

    -- 1. Recalcular stock
    EXEC sp_atualizar_stock_produto @produto_id;

    -- 2. Obter valores atuais de stock e parâmetros
    SELECT
        @stock_atual   = p.stock_atual,
        @stock_minimo  = p.stock_minimo,
        @stock_encom   = p.stock_encomenda,
        @fornecedor_id = p.fornecedor_id
    FROM Produto p
    WHERE p.produto_id = @produto_id;

    -- 3. Se type = 'saida' e estoque abaixo do mínimo, gerar encomenda
    IF @tipo = 'saida' AND @stock_atual < @stock_minimo
    BEGIN
        SET @quantidade_a_encomendar = @stock_encom - @stock_atual;
        IF @quantidade_a_encomendar > 0
        BEGIN
            DECLARE @nova_encomenda_id INT;
            INSERT INTO Encomenda (fornecedor_id, data_encomenda, status, valor_total)
            VALUES (@fornecedor_id, GETDATE(), 'pendente', 0.00);

            SET @nova_encomenda_id = SCOPE_IDENTITY();

            DECLARE @custo_unitario DECIMAL(10,2);
            SELECT @custo_unitario = custo_unitario
            FROM Produto
            WHERE produto_id = @produto_id;

            INSERT INTO EncomendaItem (encomenda_id, produto_id, quantidade, preco_unitario)
            VALUES (@nova_encomenda_id, @produto_id, @quantidade_a_encomendar, @custo_unitario);

            UPDATE Encomenda
            SET valor_total = (@quantidade_a_encomendar * @custo_unitario)
            WHERE encomenda_id = @nova_encomenda_id;
        END
    END
END;
GO

/* ------------------------------------------------
   6.5. Trigger: trg_receber_encomenda (Entrada de Estoque)
   ------------------------------------------------ */
CREATE TRIGGER trg_receber_encomenda
ON Encomenda
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @encomenda_id INT,
            @novo_status   VARCHAR(20);

    SELECT
        @encomenda_id = i.encomenda_id,
        @novo_status   = i.status
    FROM inserted i;

    IF @novo_status = 'recebida'
    BEGIN
        -- Inserir movimentação de entrada para cada item da encomenda
        INSERT INTO MovimentacaoEstoque (produto_id, data_movimentacao, tipo, quantidade, preco_unitario)
        SELECT
            ei.produto_id,
            GETDATE(),
            'entrada',
            ei.quantidade,
            ei.preco_unitario
        FROM EncomendaItem ei
        WHERE ei.encomenda_id = @encomenda_id;

        -- Recalcular estoque para cada produto
        DECLARE @produto_id INT;
        DECLARE itens_cursor CURSOR FOR
            SELECT produto_id
            FROM EncomendaItem
            WHERE encomenda_id = @encomenda_id;

        OPEN itens_cursor;
        FETCH NEXT FROM itens_cursor INTO @produto_id;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC sp_atualizar_stock_produto @produto_id;
            FETCH NEXT FROM itens_cursor INTO @produto_id;
        END

        CLOSE itens_cursor;
        DEALLOCATE itens_cursor;
    END
END;
GO

/* ------------------------------------------------
   6.6. Trigger: trg_gerar_fatura_ao_finalizar_pedido
   ------------------------------------------------ */
CREATE TRIGGER trg_gerar_fatura_ao_finalizar_pedido
ON Pedido
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @pedido_id     INT,
            @status_antigo VARCHAR(20),
            @status_novo   VARCHAR(20),
            @cliente_id    INT,
            @tipo_fatura   VARCHAR(20);

    SELECT
        @pedido_id     = i.pedido_id,
        @status_novo   = i.status
    FROM inserted i;

    SELECT @status_antigo = d.status
    FROM deleted d
    WHERE d.pedido_id = @pedido_id;

    IF @status_antigo <> 'finalizado' AND @status_novo = 'finalizado'
    BEGIN
        SELECT @cliente_id = p.cliente_id
        FROM Pedido p
        WHERE p.pedido_id = @pedido_id;

        IF @cliente_id IS NULL
            SET @tipo_fatura = 'consumidor_final';
        ELSE
            SET @tipo_fatura = 'empresa';

        DECLARE @subtotal_comida DECIMAL(12,2) = 0.00,
                @subtotal_bebida DECIMAL(12,2) = 0.00,
                @iva_comida      DECIMAL(10,2) = 0.00,
                @iva_bebida      DECIMAL(10,2) = 0.00,
                @total_linha     DECIMAL(12,2);

        DECLARE itens_cursor CURSOR FOR
            SELECT
                pi.quantidade,
                pi.preco_unitario,
                pi.iva,
                CASE
                    WHEN pr.categoria_id IN (
                        SELECT categoria_id FROM Categoria WHERE nome IN ('Bebidas','Café','Sobremesa')
                    )
                    THEN 'bebida'
                    ELSE 'comida'
                END AS tipo_item
            FROM PedidoItem pi
            LEFT JOIN Prato pr
                ON pi.prato_id = pr.prato_id
            WHERE pi.pedido_id = @pedido_id;

        OPEN itens_cursor;
        DECLARE @qtd       INT,
                @preco     DECIMAL(10,2),
                @perc_iva  DECIMAL(5,2),
                @tipo_item VARCHAR(10);

        FETCH NEXT FROM itens_cursor
        INTO @qtd, @preco, @perc_iva, @tipo_item;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @total_linha = @qtd * @preco;
            IF @tipo_item = 'comida'
            BEGIN
                SET @subtotal_comida += @total_linha;
                SET @iva_comida += (@total_linha * (@perc_iva / 100.0));
            END
            ELSE
            BEGIN
                SET @subtotal_bebida += @total_linha;
                SET @iva_bebida += (@total_linha * (@perc_iva / 100.0));
            END
            FETCH NEXT FROM itens_cursor
            INTO @qtd, @preco, @perc_iva, @tipo_item;
        END

        CLOSE itens_cursor;
        DEALLOCATE itens_cursor;

        DECLARE @total_geral DECIMAL(14,2) = @subtotal_comida + @subtotal_bebida + @iva_comida + @iva_bebida;

        -- Inserir fatura
        IF @cliente_id IS NOT NULL
        BEGIN
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
            SELECT
                @pedido_id,
                c.cliente_id,
                GETDATE(),
                'empresa',
                c.nome,
                c.morada,
                c.cidade,
                c.codigo_postal,
                c.contribuinte,
                @subtotal_comida,
                @subtotal_bebida,
                @iva_comida,
                @iva_bebida,
                @total_geral
            FROM Cliente c
            WHERE c.cliente_id = @cliente_id;
        END
        ELSE
        BEGIN
            INSERT INTO Fatura (
                pedido_id,
                data_emissao,
                tipo_fatura,
                subtotal_comida,
                subtotal_bebida,
                iva_comida,
                iva_bebida,
                total
            ) VALUES (
                @pedido_id,
                GETDATE(),
                'consumidor_final',
                @subtotal_comida,
                @subtotal_bebida,
                @iva_comida,
                @iva_bebida,
                @total_geral
            );
        END
    END
END;
GO
