USE botecopro_db;
GO


-- =========================================================================
-- Script: 04_create_functions.sql
-- Objetivo: Criação de Functions (Scalar e Table-Valued)
-- =========================================================================

/* ------------------------------------------------
   1. Scalar Function: fn_calcular_vencimentos_mes_ano
   ------------------------------------------------ */
CREATE FUNCTION fn_calcular_vencimentos_mes_ano
(
    @ano  INT,
    @mes  INT
)
RETURNS DECIMAL(14,2)
AS
BEGIN
    DECLARE @total_vencimentos DECIMAL(14,2);

    SELECT
        @total_vencimentos = SUM(
            -- cálculo das horas normais e extra proporcional ao salário base
            ( (c.salario_mensal / 160.0) * r.horas_normais )
            +
            ( CASE
                WHEN r.horas_extra <= 2
                    THEN (c.salario_mensal / 160.0) * r.horas_extra
                WHEN r.horas_extra <= 7
                    THEN (c.salario_mensal / 160.0) * 2
                         + (c.salario_mensal / 160.0) * 1.5 * (r.horas_extra - 2)
                ELSE
                    (c.salario_mensal / 160.0) * 2
                    + (c.salario_mensal / 160.0) * 1.5 * 5
                    + (c.salario_mensal / 160.0) * 2 * (r.horas_extra - 7)
              END)
        )
    FROM RegistroHoras r
    JOIN Funcionario f
        ON r.funcionario_id = f.funcionario_id
    JOIN Carreira c
        ON f.carreira_id = c.carreira_id
    WHERE YEAR(r.data_registro) = @ano
      AND MONTH(r.data_registro) = @mes;

    RETURN ISNULL(@total_vencimentos, 0.00);
END;
GO

/* ------------------------------------------------
   2. Table-Valued Function: fn_valores_gastos_stock_mes_ano
   ------------------------------------------------ */
CREATE FUNCTION fn_valores_gastos_stock_mes_ano
(
    @ano INT,
    @mes INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        me.produto_id,
        p.nome                                    AS nome_produto,
        SUM(me.quantidade * me.preco_unitario) AS valor_gasto
    FROM MovimentacaoEstoque me
    JOIN Produto p
        ON me.produto_id = p.produto_id
    WHERE me.tipo = 'saida'
      AND YEAR(me.data_movimentacao) = @ano
      AND MONTH(me.data_movimentacao) = @mes
    GROUP BY me.produto_id, p.nome
);
GO

/* ------------------------------------------------
   3. Scalar Function: fn_calcular_total_faturado
   ------------------------------------------------ */
CREATE FUNCTION fn_calcular_total_faturado
(
    @data_inicio DATE,
    @data_fim    DATE
)
RETURNS DECIMAL(14,2)
AS
BEGIN
    DECLARE @total DECIMAL(14,2);

    SELECT
        @total = SUM(f.total)
    FROM Fatura f
    WHERE CAST(f.data_emissao AS DATE) BETWEEN @data_inicio AND @data_fim;

    RETURN ISNULL(@total, 0.00);
END;
GO

/* ------------------------------------------------
   4. Table-Valued Function: fn_produtos_abaixo_stock_minimo
   ------------------------------------------------ */
CREATE FUNCTION fn_produtos_abaixo_stock_minimo()
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.produto_id,
        p.nome,
        p.stock_atual,
        p.stock_minimo
    FROM Produto p
    WHERE p.stock_atual < p.stock_minimo
);
GO

/* ------------------------------------------------
   5. Scalar Function: fn_calcular_horas_trabalhadas
   ------------------------------------------------ */
CREATE FUNCTION fn_calcular_horas_trabalhadas
(
    @funcionario_id INT,
    @data_inicio    DATE,
    @data_fim       DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total_horas DECIMAL(10,2);

    SELECT
        @total_horas = SUM(r.horas_normais + r.horas_extra)
    FROM RegistroHoras r
    WHERE r.funcionario_id = @funcionario_id
      AND r.data_registro BETWEEN @data_inicio AND @data_fim;

    RETURN ISNULL(@total_horas, 0.00);
END;
GO
