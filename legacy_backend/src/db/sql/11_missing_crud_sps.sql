USE botecopro_db;
GO

-- =========================================================================
-- Script: 11_missing_crud_sps.sql
-- Objetivo: Criação dos Stored Procedures faltantes para operações de DELETE/UPDATE
-- =========================================================================

/* =========================================================================
   1. sp_excluir_cliente
   -------------------------------------------------------------------------
   Exclui um cliente somente se não houver pedidos associados.
   Parâmetros:
     @cliente_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_cliente
    @cliente_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Cliente WHERE cliente_id = @cliente_id)
    BEGIN
        RAISERROR('Cliente não encontrado.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Pedido WHERE cliente_id = @cliente_id)
    BEGIN
        RAISERROR('Cliente possui pedidos registrados e não pode ser excluído.', 16, 1);
        RETURN;
    END

    DELETE FROM Cliente WHERE cliente_id = @cliente_id;
    SELECT 0 AS status;
END;
GO


/* =========================================================================
   2. sp_excluir_mesa
   -------------------------------------------------------------------------
   Exclui uma mesa somente se estiver livre.
   Parâmetros:
     @mesa_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_mesa
    @mesa_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Mesa WHERE mesa_id = @mesa_id)
    BEGIN
        RAISERROR('Mesa não encontrada.', 16, 1);
        RETURN;
    END

    DECLARE @status VARCHAR(20);
    SELECT @status = status FROM Mesa WHERE mesa_id = @mesa_id;

    IF @status <> 'livre'
    BEGIN
        RAISERROR('Somente mesas livres podem ser excluídas.', 16, 1);
        RETURN;
    END

    DELETE FROM Mesa WHERE mesa_id = @mesa_id;
    SELECT 0 AS status;
END;
GO


/* =========================================================================
   3. sp_excluir_carreira
   -------------------------------------------------------------------------
   Exclui uma carreira somente se não houver funcionários vinculados.
   Parâmetros:
     @carreira_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_carreira
    @carreira_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Carreira WHERE carreira_id = @carreira_id)
    BEGIN
        RAISERROR('Carreira não encontrada.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Funcionario WHERE carreira_id = @carreira_id)
    BEGIN
        RAISERROR('Há funcionários vinculados a esta carreira. Não pode excluir.', 16, 1);
        RETURN;
    END

    DELETE FROM Carreira WHERE carreira_id = @carreira_id;
    SELECT 0 AS status;
END;
GO


/* =========================================================================
   4. sp_excluir_funcionario
   -------------------------------------------------------------------------
   Exclui um funcionário somente se não houver registros de horas ou pedidos abertos.
   Parâmetros:
     @funcionario_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_funcionario
    @funcionario_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Funcionario WHERE funcionario_id = @funcionario_id)
    BEGIN
        RAISERROR('Funcionário não encontrado.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM RegistroHoras WHERE funcionario_id = @funcionario_id)
    BEGIN
        RAISERROR('Há registros de horas vinculados a este funcionário.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Pedido WHERE funcionario_id = @funcionario_id AND status NOT IN ('finalizado','cancelado'))
    BEGIN
        RAISERROR('Funcionário possui pedidos em andamento. Não pode excluir.', 16, 1);
        RETURN;
    END

    DELETE FROM Funcionario WHERE funcionario_id = @funcionario_id;
    SELECT 0 AS status;
END;
GO


/* =========================================================================
   5. sp_excluir_fornecedor
   -------------------------------------------------------------------------
   Exclui um fornecedor somente se não houver encomendas associadas.
   Parâmetros:
     @fornecedor_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_fornecedor
    @fornecedor_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Fornecedor WHERE fornecedor_id = @fornecedor_id)
    BEGIN
        RAISERROR('Fornecedor não encontrado.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Encomenda WHERE fornecedor_id = @fornecedor_id)
    BEGIN
        RAISERROR('Há encomendas associadas a este fornecedor. Não pode excluir.', 16, 1);
        RETURN;
    END

    DELETE FROM Fornecedor WHERE fornecedor_id = @fornecedor_id;
    SELECT 0 AS status;
END;
GO


/* =========================================================================
   6. sp_excluir_produto
   -------------------------------------------------------------------------
   Exclui um produto somente se não houver movimentações de estoque ou vínculo a pratos.
   Parâmetros:
     @produto_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_produto
    @produto_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Produto WHERE produto_id = @produto_id)
    BEGIN
        RAISERROR('Produto não encontrado.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM MovimentacaoEstoque WHERE produto_id = @produto_id)
    BEGIN
        RAISERROR('Há movimentações de estoque para este produto.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM PratoIngrediente WHERE produto_id = @produto_id)
    BEGIN
        RAISERROR('Produto vinculado a pratos. Não pode excluir.', 16, 1);
        RETURN;
    END

    DELETE FROM Produto WHERE produto_id = @produto_id;
    SELECT 0 AS status;
END;
GO


/* =========================================================================
   7. sp_excluir_prato
   -------------------------------------------------------------------------
   Exclui um prato somente se não houver pedidos ou vínculo a menus especiais.
   Parâmetros:
     @prato_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_prato
    @prato_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Prato WHERE prato_id = @prato_id)
    BEGIN
        RAISERROR('Prato não encontrado.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM PedidoItem WHERE prato_id = @prato_id)
    BEGIN
        RAISERROR('Prato já foi vendido em pedidos. Não pode excluir.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM MenuEspecialPrato WHERE prato_id = @prato_id)
    BEGIN
        RAISERROR('Prato vinculado a menus especiais. Remova o vínculo antes.', 16, 1);
        RETURN;
    END

    DELETE FROM PratoIngrediente WHERE prato_id = @prato_id;
    DELETE FROM Prato WHERE prato_id = @prato_id;

    SELECT 0 AS status;
END;
GO


/* =========================================================================
   8. sp_excluir_menu_especial
   -------------------------------------------------------------------------
   Exclui um menu especial somente se estiver fora do período ativo.
   Parâmetros:
     @menu_especial_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_menu_especial
    @menu_especial_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM MenuEspecial WHERE menu_especial_id = @menu_especial_id)
    BEGIN
        RAISERROR('MenuEspecial não encontrado.', 16, 1);
        RETURN;
    END

    DECLARE @hoje DATE = CAST(GETDATE() AS DATE);
    DECLARE @data_inicio DATE, @data_fim DATE;
    SELECT @data_inicio = data_inicio, @data_fim = data_fim
    FROM MenuEspecial
    WHERE menu_especial_id = @menu_especial_id;

    IF @hoje BETWEEN @data_inicio AND @data_fim
    BEGIN
        RAISERROR('MenuEspecial está ativo. Não pode excluir durante o período válido.', 16, 1);
        RETURN;
    END

    DELETE FROM MenuEspecialPrato WHERE menu_especial_id = @menu_especial_id;
    DELETE FROM MenuEspecial WHERE menu_especial_id = @menu_especial_id;

    SELECT 0 AS status;
END;
GO


/* =========================================================================
   9. sp_excluir_pedido
   -------------------------------------------------------------------------
   Exclui um pedido pendente e reverte o estoque.
   Parâmetros:
     @pedido_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_pedido
    @pedido_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Pedido WHERE pedido_id = @pedido_id)
    BEGIN
        RAISERROR('Pedido não encontrado.', 16, 1);
        RETURN;
    END

    DECLARE @status VARCHAR(20);
    SELECT @status = status FROM Pedido WHERE pedido_id = @pedido_id;

    IF @status <> 'pendente'
    BEGIN
        RAISERROR('Somente pedidos em status "pendente" podem ser excluídos.', 16, 1);
        RETURN;
    END

    -- Reverter estoque e excluir itens via sp_cancelar_pedido
    EXEC sp_cancelar_pedido @pedido_id;

    DELETE FROM PedidoItem WHERE pedido_id = @pedido_id;
    DELETE FROM Pedido WHERE pedido_id = @pedido_id;

    SELECT 0 AS status;
END;
GO


/* =========================================================================
   10. sp_remover_item_pedido
   -------------------------------------------------------------------------
   Remove um item de pedido pendente e reverte o abatimento de estoque.
   Parâmetros:
     @pedido_item_id INT
   ========================================================================= */
/* =========================================================================
   sp_remover_item_pedido  (versão corrigida: @custo_unit declarado só 1 vez)
   -------------------------------------------------------------------------
   Remove um item de pedido pendente e devolve o estoque correspondente.
   Parâmetros: @pedido_item_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_remover_item_pedido
    @pedido_item_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM PedidoItem WHERE pedido_item_id = @pedido_item_id)
    BEGIN
        RAISERROR('Item de pedido não encontrado.', 16, 1);
        RETURN;
    END

    DECLARE 
        @pedido_id   INT,
        @prato_id    INT,
        @produto_id  INT,
        @qtd_item    INT,
        @status      VARCHAR(20),
        @custo_unit  DECIMAL(10,2);   -- <<<<<< ÚNICA declaração de @custo_unit

    SELECT 
        @pedido_id  = pedido_id,
        @prato_id   = prato_id,
        @produto_id = produto_id,
        @qtd_item   = quantidade
    FROM PedidoItem
    WHERE pedido_item_id = @pedido_item_id;

    SELECT @status = status FROM Pedido WHERE pedido_id = @pedido_id;

    IF @status <> 'pendente'
    BEGIN
        RAISERROR('Somente itens de pedido em "pendente" podem ser removidos.', 16, 1);
        RETURN;
    END

    /* ----------- Tratamento se for prato (repor cada ingrediente) ----------- */
    IF @prato_id IS NOT NULL
    BEGIN
        DECLARE 
            @ingred_id  INT,
            @qtd_ingred DECIMAL(10,3);

        DECLARE cursor_ingr CURSOR FOR
            SELECT produto_id,
                   quantidade_necessaria * @qtd_item
            FROM PratoIngrediente
            WHERE prato_id = @prato_id;

        OPEN cursor_ingr;
        FETCH NEXT FROM cursor_ingr INTO @ingred_id, @qtd_ingred;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SELECT @custo_unit = custo_unitario
            FROM   Produto
            WHERE  produto_id = @ingred_id;

            INSERT INTO MovimentacaoEstoque (
                produto_id, data_movimentacao, tipo, quantidade,
                preco_unitario, pedido_id
            )
            VALUES (
                @ingred_id, GETDATE(), 'entrada',
                @qtd_ingred, @custo_unit, @pedido_id
            );

            EXEC sp_atualizar_stock_produto @ingred_id;
            FETCH NEXT FROM cursor_ingr INTO @ingred_id, @qtd_ingred;
        END

        CLOSE cursor_ingr;
        DEALLOCATE cursor_ingr;
    END
    /* -------------- Tratamento se for produto avulso ----------------- */
    ELSE IF @produto_id IS NOT NULL
    BEGIN
        SELECT @custo_unit = custo_unitario
        FROM   Produto
        WHERE  produto_id = @produto_id;

        INSERT INTO MovimentacaoEstoque (
            produto_id, data_movimentacao, tipo, quantidade,
            preco_unitario, pedido_id
        )
        VALUES (
            @produto_id, GETDATE(), 'entrada',
            @qtd_item, @custo_unit, @pedido_id
        );

        EXEC sp_atualizar_stock_produto @produto_id;
    END

    DELETE FROM PedidoItem WHERE pedido_item_id = @pedido_item_id;
    SELECT 0 AS status;
END;
GO




/* =========================================================================
   11. sp_excluir_encomenda
   -------------------------------------------------------------------------
   Exclui uma encomenda pendente e seus itens.
   Parâmetros:
     @encomenda_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_encomenda
    @encomenda_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Encomenda WHERE encomenda_id = @encomenda_id)
    BEGIN
        RAISERROR('Encomenda não encontrada.', 16, 1);
        RETURN;
    END

    DECLARE @status VARCHAR(20);
    SELECT @status = status FROM Encomenda WHERE encomenda_id = @encomenda_id;

    IF @status <> 'pendente'
    BEGIN
        RAISERROR('Somente encomendas pendentes podem ser excluídas.', 16, 1);
        RETURN;
    END

    DELETE FROM EncomendaItem WHERE encomenda_id = @encomenda_id;
    DELETE FROM Encomenda WHERE encomenda_id = @encomenda_id;

    SELECT 0 AS status;
END;
GO


/* =========================================================================
   12. sp_remover_item_encomenda
   -------------------------------------------------------------------------
   Remove um item de encomenda pendente e atualiza valor_total.
   Parâmetros:
     @encomenda_item_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_remover_item_encomenda
    @encomenda_item_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM EncomendaItem WHERE encomenda_item_id = @encomenda_item_id)
    BEGIN
        RAISERROR('Item de encomenda não encontrado.', 16, 1);
        RETURN;
    END

    DECLARE @encomenda_id INT;
    SELECT @encomenda_id = encomenda_id FROM EncomendaItem WHERE encomenda_item_id = @encomenda_item_id;

    DECLARE @status VARCHAR(20);
    SELECT @status = status FROM Encomenda WHERE encomenda_id = @encomenda_id;

    IF @status <> 'pendente'
    BEGIN
        RAISERROR('Somente itens de encomenda pendentes podem ser removidos.', 16, 1);
        RETURN;
    END

    DELETE FROM EncomendaItem WHERE encomenda_item_id = @encomenda_item_id;

    UPDATE Encomenda
    SET valor_total = ISNULL(
        (SELECT SUM(quantidade * preco_unitario) 
         FROM EncomendaItem 
         WHERE encomenda_id = @encomenda_id),
        0.00
    )
    WHERE encomenda_id = @encomenda_id;

    SELECT 0 AS status;
END;
GO


/* =========================================================================
   13. sp_excluir_registro_horas
   -------------------------------------------------------------------------
   Exclui um registro de horas.
   Parâmetros:
     @registro_horas_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_registro_horas
    @registro_horas_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM RegistroHoras WHERE registro_horas_id = @registro_horas_id)
    BEGIN
        RAISERROR('Registro de horas não encontrado.', 16, 1);
        RETURN;
    END

    DELETE FROM RegistroHoras WHERE registro_horas_id = @registro_horas_id;
    SELECT 0 AS status;
END;
GO


/* =========================================================================
   14. sp_excluir_fatura
   -------------------------------------------------------------------------
   Exclui uma fatura e seus itens.
   Parâmetros:
     @fatura_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_fatura
    @fatura_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Fatura WHERE fatura_id = @fatura_id)
    BEGIN
        RAISERROR('Fatura não encontrada.', 16, 1);
        RETURN;
    END

    DELETE FROM FaturaItem WHERE fatura_id = @fatura_id;
    DELETE FROM Fatura WHERE fatura_id = @fatura_id;
    SELECT 0 AS status;
END;
GO


/* =========================================================================
   15. sp_excluir_item_fatura
   -------------------------------------------------------------------------
   Exclui um item de fatura e recalcula total (opcional).
   Parâmetros:
     @fatura_item_id INT
   ========================================================================= */
CREATE OR ALTER PROCEDURE sp_excluir_item_fatura
    @fatura_item_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM FaturaItem WHERE fatura_item_id = @fatura_item_id)
    BEGIN
        RAISERROR('Item de fatura não encontrado.', 16, 1);
        RETURN;
    END

    DECLARE @fatura_id INT;
    SELECT @fatura_id = fatura_id FROM FaturaItem WHERE fatura_item_id = @fatura_item_id;

    DELETE FROM FaturaItem WHERE fatura_item_id = @fatura_item_id;

    -- Opcional: Recalcular total da fatura
    -- UPDATE Fatura
    -- SET total = ISNULL((SELECT SUM(valor_total_linha) FROM FaturaItem WHERE fatura_id = @fatura_id), 0.00)
    -- WHERE fatura_id = @fatura_id;

    SELECT 0 AS status;
END;
GO
