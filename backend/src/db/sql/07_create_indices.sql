USE botecopro_db;
GO
-- =========================================================================
-- Script: 07_create_indices.sql
-- Objetivo: Criação de índices adicionais para otimização de consultas
-- =========================================================================

/* ------------------------------------------------
   1. Índice em Produto(stock_atual) para alertas
   ------------------------------------------------ */
CREATE NONCLUSTERED INDEX idx_produto_stock_atual
    ON Produto (stock_atual);
GO

/* ------------------------------------------------
   2. Índice em MovimentacaoEstoque(data_movimentacao)
   ------------------------------------------------ */
CREATE NONCLUSTERED INDEX idx_movimentacao_data
    ON MovimentacaoEstoque (data_movimentacao);
GO

/* ------------------------------------------------
   3. Índice em Pedido(status) para filtrar estado
   ------------------------------------------------ */
CREATE NONCLUSTERED INDEX idx_pedido_status
    ON Pedido (status);
GO

/* ------------------------------------------------
   4. Índice em Fatura(data_emissao) para relatórios
   ------------------------------------------------ */
CREATE NONCLUSTERED INDEX idx_fatura_data
    ON Fatura (data_emissao);
GO

/* ------------------------------------------------
   5. Índice em RegistroHoras(data_registro) para relatórios
   ------------------------------------------------ */
CREATE NONCLUSTERED INDEX idx_reghoras_data
    ON RegistroHoras (data_registro);
GO

/* ------------------------------------------------
   6. Índice em Mesa(status) para busca de mesas
   ------------------------------------------------ */
CREATE NONCLUSTERED INDEX idx_mesa_status
    ON Mesa (status);
GO

/* ------------------------------------------------
   7. Índice em Fornecedor(nome) para buscas rápidas
   ------------------------------------------------ */
CREATE NONCLUSTERED INDEX idx_fornecedor_nome
    ON Fornecedor (nome);
GO

/* ------------------------------------------------
   8. Índice em Prato(categoria_id) para agrupar por categoria
   ------------------------------------------------ */
CREATE NONCLUSTERED INDEX idx_prato_categoria
    ON Prato (categoria_id);
GO

/* ------------------------------------------------
   9. Índice em PedidoItem(prato_id) para relatórios de venda
   ------------------------------------------------ */
CREATE NONCLUSTERED INDEX idx_pedidoitem_prato
    ON PedidoItem (prato_id);
GO

/* ------------------------------------------------
   10. Índice em PedidoItem(produto_id) para relatórios de venda
   ------------------------------------------------ */
CREATE NONCLUSTERED INDEX idx_pedidoitem_produto
    ON PedidoItem (produto_id);
GO

