USE botecopro_db;
GO

-- =========================================================================
-- Script: 03_create_materialized_views.sql
-- Objetivo: Criação de Indexed View e de View detalhada para relatório de estoque
-- =========================================================================

/* ------------------------------------------------
   1. Indexed View: mv_estoque_saida_agregado
   ------------------------------------------------
   Para Indexed Views com agregação no SQL Server, é obrigatório
   incluir COUNT_BIG(*) no SELECT. Aqui agregamos apenas a soma das 
   quantidades de saída por produto.
*/
CREATE OR ALTER VIEW mv_estoque_saida_agregado
WITH SCHEMABINDING
AS
    SELECT
        me.produto_id,
        SUM(me.quantidade)   AS quantidade_total,
        COUNT_BIG(*)         AS registros_count
    FROM dbo.MovimentacaoEstoque AS me
    WHERE me.tipo = 'saida'
    GROUP BY me.produto_id;
GO

-- Índice clusterizado na Indexed View (chave única em produto_id)
CREATE UNIQUE CLUSTERED INDEX idx_mv_estoque_saida_agregado
    ON mv_estoque_saida_agregado (produto_id);
GO


/* ------------------------------------------------
   2. View de Consulta Detalhada: view_estoque_utilizado_detalhado
   ------------------------------------------------
   Une a Indexed View (que contém a soma de quantidades e COUNT_BIG)
   à tabela Produto, e usa subqueries para obter datas mínima e máxima
   de movimentação para cada produto. Essa view não é indexada.
*/
CREATE OR ALTER VIEW view_estoque_utilizado_detalhado AS
SELECT
    agg.produto_id,
    p.nome            AS nome_produto,
    agg.quantidade_total,
    (
        SELECT MIN(me2.data_movimentacao)
        FROM dbo.MovimentacaoEstoque AS me2
        WHERE me2.tipo = 'saida'
          AND me2.produto_id = agg.produto_id
    ) AS data_inicio,
    (
        SELECT MAX(me3.data_movimentacao)
        FROM dbo.MovimentacaoEstoque AS me3
        WHERE me3.tipo = 'saida'
          AND me3.produto_id = agg.produto_id
    ) AS data_fim
FROM mv_estoque_saida_agregado AS agg
JOIN dbo.Produto AS p
    ON agg.produto_id = p.produto_id;
GO
