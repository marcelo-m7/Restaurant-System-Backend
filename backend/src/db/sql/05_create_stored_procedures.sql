USE botecopro_db;
GO
-- =========================================================================
-- Script: 05_create_stored_procedures.sql
-- Objetivo: Criação de Stored Procedures para consultas parametrizadas
-- =========================================================================

/* ------------------------------------------------
   1. SP: sp_obter_mesas_disponiveis
   ------------------------------------------------ */
CREATE PROCEDURE sp_obter_mesas_disponiveis
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * 
    FROM view_mesas_disponiveis;
END;
GO

/* ------------------------------------------------
   2. SP: sp_obter_pedidos_por_funcionario
   ------------------------------------------------ */
CREATE PROCEDURE sp_obter_pedidos_por_funcionario
    @funcionario_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.pedido_id,
        p.mesa_id,
        p.data_pedido,
        p.status
    FROM Pedido p
    WHERE p.funcionario_id = @funcionario_id
      AND p.status NOT IN ('finalizado', 'cancelado');
END;
GO

/* ------------------------------------------------
   3. SP: sp_obter_estoque_ingrediente
   ------------------------------------------------ */
CREATE PROCEDURE sp_obter_estoque_ingrediente
    @ingrediente_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        p.produto_id,
        p.nome,
        p.stock_atual,
        p.stock_minimo,
        p.stock_encomenda
    FROM Produto p
    WHERE p.produto_id = @ingrediente_id
      AND p.tipo = 'ingrediente';
END;
GO

/* ------------------------------------------------
   4. SP: sp_obter_faturamento_por_periodo
   ------------------------------------------------ */
CREATE PROCEDURE sp_obter_faturamento_por_periodo
    @data_inicio DATE,
    @data_fim    DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @total DECIMAL(14,2);
    SET @total = dbo.fn_calcular_total_faturado(@data_inicio, @data_fim);

    SELECT
        @data_inicio AS data_inicio,
        @data_fim    AS data_fim,
        @total       AS total_faturado;
END;
GO

/* ------------------------------------------------
   5. SP: sp_obter_horas_trabalhadas
   ------------------------------------------------ */
CREATE PROCEDURE sp_obter_horas_trabalhadas
    @funcionario_id INT,
    @data_inicio    DATE,
    @data_fim       DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @total_horas DECIMAL(10,2);
    SET @total_horas = dbo.fn_calcular_horas_trabalhadas(@funcionario_id, @data_inicio, @data_fim);

    SELECT
        @funcionario_id AS funcionario_id,
        @data_inicio    AS data_inicio,
        @data_fim       AS data_fim,
        @total_horas    AS total_horas;
END;
GO

/* ------------------------------------------------
   6. SP: sp_obter_clientes_frequentes
   ------------------------------------------------ */
CREATE PROCEDURE sp_obter_clientes_frequentes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * 
    FROM view_clientes_frequentes;
END;
GO

/* ------------------------------------------------
   7. SP: sp_obter_pratos_populares
   ------------------------------------------------ */
CREATE PROCEDURE sp_obter_pratos_populares
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * 
    FROM view_pratos_populares;
END;
GO

/* ------------------------------------------------
   8. SP: sp_obter_entregas_fornecedor
   ------------------------------------------------ */
CREATE PROCEDURE sp_obter_entregas_fornecedor
    @fornecedor_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        e.encomenda_id,
        e.data_encomenda,
        e.status,
        e.valor_total
    FROM Encomenda e
    WHERE e.fornecedor_id = @fornecedor_id
      AND e.status = 'recebida';
END;
GO

/* ------------------------------------------------
   9. SP: sp_obter_promocoes_ativas
   ------------------------------------------------ */
CREATE PROCEDURE sp_obter_promocoes_ativas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM view_promocoes_ativas;
END;
GO

/* ------------------------------------------------
   10. SP: sp_obter_reservas_ativas (Opcional)
   ------------------------------------------------ */
CREATE PROCEDURE sp_obter_reservas_ativas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT *
    FROM view_reservas_ativas;
END;
GO

/* ------------------------------------------------
   11. SP: sp_obter_faturamento_por_categoria
   ------------------------------------------------ */
CREATE PROCEDURE sp_obter_faturamento_por_categoria
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.nome         AS categoria,
        SUM(pi.quantidade * pi.preco_unitario) AS total_faturado
    FROM PedidoItem pi
    JOIN Prato p
        ON pi.prato_id = p.prato_id
    JOIN Categoria c
        ON p.categoria_id = c.categoria_id
    GROUP BY c.nome;
END;
GO