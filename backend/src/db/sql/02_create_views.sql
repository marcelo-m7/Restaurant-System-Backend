-- =========================================================================
-- Script: 02_create_views.sql
-- Objetivo: Criação de Views de consulta para uso pela API
-- =========================================================================
USE botecopro_db;
GO

/* ------------------------------------------------
   1. View: Mesas Disponíveis
   ------------------------------------------------ */
CREATE OR ALTER VIEW view_mesas_disponiveis AS
SELECT
    mesa_id,
    numero,
    capacidade
FROM Mesa
WHERE status = 'livre';
GO


/* ------------------------------------------------
   2. View: Pedidos em Andamento
   ------------------------------------------------ */
CREATE OR ALTER VIEW view_pedidos_em_andamento AS
SELECT
    p.pedido_id,
    p.mesa_id,
    p.funcionario_id,
    p.data_pedido,
    p.status
FROM Pedido p
WHERE p.status IN ('pendente', 'em_preparo');
GO


/* ------------------------------------------------
   3. View: Estoque de Ingredientes
   ------------------------------------------------ */
CREATE OR ALTER VIEW view_estoque_ingredientes AS
SELECT
    produto_id,
    nome AS nome_produto,
    stock_atual,
    stock_minimo
FROM Produto
WHERE tipo = 'ingrediente';
GO


/* ------------------------------------------------
   4. View: Faturamento por Período (Ano/Mês)
   ------------------------------------------------ */
CREATE OR ALTER VIEW view_faturamento_periodo AS
SELECT
    YEAR(f.data_emissao) AS ano,
    MONTH(f.data_emissao) AS mes,
    SUM(f.total) AS total_faturado
FROM Fatura f
GROUP BY
    YEAR(f.data_emissao),
    MONTH(f.data_emissao);
GO


/* ------------------------------------------------
   5. View: Horas Trabalhadas por Funcionário
   ------------------------------------------------ */
CREATE OR ALTER VIEW view_horas_funcionario AS
SELECT
    f.funcionario_id,
    f.nome AS nome_funcionario,
    SUM(r.horas_normais) AS total_horas_normais,
    SUM(r.horas_extra)   AS total_horas_extra
FROM Funcionario f
JOIN RegistroHoras r
    ON f.funcionario_id = r.funcionario_id
GROUP BY
    f.funcionario_id,
    f.nome;
GO


/* ------------------------------------------------
   6. View: Clientes Frequentes
      (removi o ORDER BY)
   ------------------------------------------------ */
CREATE OR ALTER VIEW view_clientes_frequentes AS
SELECT
    c.cliente_id,
    c.nome AS nome_cliente,
    COUNT(p.pedido_id) AS total_pedidos
FROM Cliente c
JOIN Pedido p
    ON c.cliente_id = p.cliente_id
GROUP BY
    c.cliente_id,
    c.nome;
GO


/* ------------------------------------------------
   7. View: Pratos Mais Vendidos
      (removi o ORDER BY)
   ------------------------------------------------ */
CREATE OR ALTER VIEW view_pratos_populares AS
SELECT
    pi.prato_id,
    pr.nome AS nome_prato,
    COUNT(pi.pedido_item_id) AS total_vendas
FROM PedidoItem pi
JOIN Prato pr
    ON pi.prato_id = pr.prato_id
GROUP BY
    pi.prato_id,
    pr.nome;
GO


/* ------------------------------------------------
   8. View: Entregas por Fornecedor
   ------------------------------------------------ */
CREATE OR ALTER VIEW view_fornecedores_entregas AS
SELECT
    f.fornecedor_id,
    f.nome AS nome_fornecedor,
    COUNT(e.encomenda_id) AS total_encomendas_recebidas
FROM Fornecedor f
JOIN Encomenda e
    ON f.fornecedor_id = e.fornecedor_id
WHERE e.status = 'recebida'
GROUP BY
    f.fornecedor_id,
    f.nome;
GO


/* ------------------------------------------------
   9. View: Promoções Ativas (Menus Especiais)
   ------------------------------------------------ */
CREATE OR ALTER VIEW view_promocoes_ativas AS
SELECT
    menu_especial_id,
    nome AS nome_menu,
    data_inicio,
    data_fim,
    preco_total
FROM MenuEspecial
WHERE data_inicio <= CAST(GETDATE() AS DATE)
  AND data_fim   >= CAST(GETDATE() AS DATE);
GO


/* ------------------------------------------------
   10. View: Reservas Ativas (Opcional)
   ------------------------------------------------ */
CREATE OR ALTER VIEW view_reservas_ativas AS
SELECT
    r.reserva_id,
    c.nome AS nome_cliente,
    r.mesa_id,
    r.data_reserva,
    r.hora_reserva,
    r.quantidade_pessoas
FROM Reserva r
JOIN Cliente c
    ON r.cliente_id = c.cliente_id
WHERE r.data_reserva >= CAST(GETDATE() AS DATE)
  AND r.status = 'ativa';
GO
