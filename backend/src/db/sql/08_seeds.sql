USE botecopro_db;
GO

-- =========================================================================
-- Script: 08_seeds.sql
-- Objetivo: População inicial (seeds) do banco de dados Boteco Pro
-- =========================================================================

/* ------------------------------------------------
   1. Inserir Categorias
------------------------------------------------ */
INSERT INTO Categoria (nome, descricao) VALUES
    ('Carnes', 'Pratos à base de carnes vermelhas e brancas'),
    ('Peixes', 'Pratos à base de peixes e frutos do mar'),
    ('Massas', 'Pratos de massas e acompanhamentos'),
    ('Sobremesas', 'Doces e sobremesas variadas'),
    ('Bebidas', 'Bebidas não alcoólicas e alcoólicas'),
    ('Café', 'Café e bebidas quentes');
GO


/* ------------------------------------------------
   2. Inserir Carreiras (Cargos e Salários)
------------------------------------------------ */
INSERT INTO Carreira (nome, salario_mensal) VALUES
    ('Cozinheiro 2ª Classe', 1200.00),
    ('Cozinheiro Chefe',      2000.00),
    ('Empregado de Mesa',     1000.00),
    ('Gerente de Sala',       2500.00);
GO


/* ------------------------------------------------
   3. Inserir Fornecedores
------------------------------------------------ */
INSERT INTO Fornecedor (nome, telefone, email, endereco, cidade, codigo_postal, pais) VALUES
    ('Fornecedor A', '912345678', 'contato@fornecedora.com', 'Rua das Flores, 123', 'Porto',  '4000-100', 'Portugal'),
    ('Fornecedor B', '919876543', 'vendas@fornecedorb.com',  'Avenida Central, 45',    'Lisboa','1000-200', 'Portugal');
GO


/* ------------------------------------------------
   4. Inserir Produtos (Ingredientes, Bebidas, Sobremesas)
------------------------------------------------ */
INSERT INTO Produto (nome, tipo, custo_unitario, preco_venda, stock_atual, stock_minimo, stock_encomenda, fornecedor_id)
VALUES
    -- Ingredientes
    ('Batata',        'ingrediente', 0.20,  0.50,  500,  50,  200, 1),
    ('Carne de Vaca', 'ingrediente', 5.00, 12.00, 100,  10,   50, 1),
    ('Filete de Peixe','ingrediente',4.50, 10.00,150,  15,   60, 2),
    ('Farinha',       'ingrediente', 0.10,  0.25,1000,100,  500, 1),
    ('Ovo',           'ingrediente', 0.15,  0.40,300,  30,  150, 2),
    ('Azeite',        'ingrediente', 1.00,  2.50,200,  20,  100, 1),

    -- Bebidas
    ('Cerveja',       'bebida',      1.00,  2.50,100,  10,   50, 2),
    ('Refrigerante',  'bebida',      0.50,  1.50,200,  20,  100, 2),
    ('Vinho Tinto',   'bebida',      4.00, 10.00, 50,  5,   20, 1),
    ('Café Expresso', 'bebida',      0.10,  0.80,500,  50,  200, 2),

    -- Sobremesas
    ('Pudim',         'sobremesa',   0.50,  2.00,100,  10,   50, 1),
    ('Gelado',        'sobremesa',   0.80,  3.00, 80,   8,   40, 2);
GO


/* ------------------------------------------------
   5. Inserir Pratos e Vincular com Ingredientes
------------------------------------------------ */
/* 5.1. Pratos */
INSERT INTO Prato (nome, categoria_id, descricao, tempo_preparo, preco_base) VALUES
    ('Bife à Portuguesa',       1, 'Bife de vaca com batatas fritas e ovo',  30, 12.00),
    ('Filet de Peixe Grelhado', 2, 'Filete de peixe grelhado com legumes',    25, 10.00),
    ('Esparguete à Carbonara',  3, 'Massa cozida com molho carbonara',      20,  8.00),
    ('Omelete de Queijo',       3, 'Omelete simples de queijo',              15,  6.00);
GO

/* 5.2. PratoIngrediente */
/* Bife à Portuguesa: Carne de Vaca (200g), Batata (150g), Ovo (1 unidade), Azeite (10ml) */
INSERT INTO PratoIngrediente (prato_id, produto_id, quantidade_necessaria) VALUES
    (1, 2, 0.200),   -- Carne de Vaca 200g
    (1, 1, 0.150),   -- Batata 150g
    (1, 5, 1.000),   -- Ovo 1 unidade
    (1, 6, 0.010);   -- Azeite 10ml

/* Filet de Peixe Grelhado: Filete de Peixe (200g), Azeite (10ml) */
INSERT INTO PratoIngrediente (prato_id, produto_id, quantidade_necessaria) VALUES
    (2, 3, 0.200),   -- Filete de Peixe 200g
    (2, 6, 0.010);   -- Azeite 10ml

/* Esparguete à Carbonara: Farinha (100g), Ovo (2 unidades), Azeite (5ml) */
INSERT INTO PratoIngrediente (prato_id, produto_id, quantidade_necessaria) VALUES
    (3, 4, 0.100),   -- Farinha 100g
    (3, 5, 2.000),   -- Ovo 2 unidades
    (3, 6, 0.005);   -- Azeite 5ml

/* Omelete de Queijo: Ovo (3 unidades), Azeite (5ml) */
INSERT INTO PratoIngrediente (prato_id, produto_id, quantidade_necessaria) VALUES
    (4, 5, 3.000),   -- Ovo 3 unidades
    (4, 6, 0.005);   -- Azeite 5ml
GO


/* ------------------------------------------------
   6. Inserir Mesas
------------------------------------------------ */
INSERT INTO Mesa (numero, capacidade, status) VALUES
    (1, 4, 'livre'),
    (2, 2, 'livre'),
    (3, 6, 'livre'),
    (4, 4, 'livre'),
    (5, 8, 'livre');
GO


/* ------------------------------------------------
   7. Inserir Clientes
------------------------------------------------ */
INSERT INTO Cliente (nome, telefone, email, morada, cidade, codigo_postal, contribuinte) VALUES
    ('Ana Silva',      '912345111', 'ana.silva@example.com',      'Rua Nova, 10',      'Lisboa', '1000-001', '123456789'),
    ('João Pereira',   '919876222', 'joao.pereira@example.com',   'Avenida Velha, 5',  'Porto',  '4000-002', '987654321'),
    ('Maria Fernandes','913333444','maria.fernandes@empresa.com','Travessa Flores, 8','Faro',   '8000-003', '456789123');
GO


/* ------------------------------------------------
   8. Inserir Reservas (opcional)
------------------------------------------------ */
INSERT INTO Reserva (cliente_id, mesa_id, data_reserva, hora_reserva, quantidade_pessoas, status) VALUES
    (1, 3, '2025-06-20', '19:30', 4, 'ativa'),
    (2, 5, '2025-07-01', '20:00', 2, 'ativa');
GO


/* ------------------------------------------------
   9. Inserir Funcionários
------------------------------------------------ */
INSERT INTO Funcionario (nome, data_nascimento, telefone, email, cargo, carreira_id, data_admissao) VALUES
    ('Pedro Costa',   '1990-05-15', '914567890', 'pedro.costa@botecopro_db.com',   'Cozinheiro',        1, '2024-01-10'),
    ('Sofia Andrade', '1985-03-22', '915678901', 'sofia.andrade@botecopro_db.com', 'Cozinheiro',        2, '2023-11-05'),
    ('Luís Gomes',    '1992-08-10', '916789012', 'luis.gomes@botecopro_db.com',    'Empregado de Mesa', 3, '2025-02-01'),
    ('Carla Rocha',   '1980-12-30', '917890123', 'carla.rocha@botecopro_db.com',   'Gerente de Sala',   4, '2022-07-15');
GO


/* ------------------------------------------------
   10. Inserir Registro de Horas para Funcionários
------------------------------------------------ */
/* Assumindo que RegistroHoras.horas_normais e horas_extra já foram alteradas para DECIMAL(10,2) */
INSERT INTO RegistroHoras (funcionario_id, data_registro, horas_normais, horas_extra) VALUES
    (1, '2025-05-31', 160.00, 10.00),  -- Pedro Costa
    (2, '2025-05-31', 160.00,  5.00),  -- Sofia Andrade
    (3, '2025-05-31', 160.00,  8.00),  -- Luís Gomes
    (4, '2025-05-31', 160.00,  0.00);  -- Carla Rocha
GO


/* ------------------------------------------------
   11. Inserir MenuEspecial e Vincular Pratos
------------------------------------------------ */
-- Menu para Dia dos Namorados
INSERT INTO MenuEspecial (nome, descricao, data_inicio, data_fim, preco_total) VALUES
    ('Menu Dia dos Namorados', 'Entrada, Peixe, Carne, Sobremesa e Café especial', '2025-06-12', '2025-06-15', 45.00);

DECLARE @menuId INT = SCOPE_IDENTITY();

-- Vincular pratos ao menu:
-- Ordem: 1=entrada (omelete de queijo), 2=peixe, 3=carnes, 4=sobremesa (pudim), 5=café
INSERT INTO MenuEspecialPrato (menu_especial_id, prato_id, ordem) VALUES
    (@menuId, 4, 1),  -- Omelete de Queijo
    (@menuId, 2, 2),  -- Filet de Peixe Grelhado
    (@menuId, 1, 3);  -- Bife à Portuguesa
GO


/* ------------------------------------------------
   12. Inserir Pedido e Itens para Demonstrar Triggers
------------------------------------------------ */
INSERT INTO Pedido (mesa_id, funcionario_id, cliente_id, data_pedido, status)
VALUES (1, 3, 1, GETDATE(), 'pendente');

DECLARE @novoPedidoId INT = SCOPE_IDENTITY();

-- Cliente pediu 1 Bife à Portuguesa e 2 Cervejas e 1 Pudim
INSERT INTO PedidoItem (pedido_id, prato_id, produto_id, quantidade, preco_unitario, iva) VALUES
    (@novoPedidoId, 1,   NULL, 1, 12.00, 13.00),  -- Bife à Portuguesa (13% IVA)
    (@novoPedidoId, NULL, 7,    2,  2.50, 23.00),  -- 2 Cerveja (23% IVA) (produto_id=7)
    (@novoPedidoId, NULL, 11,   1,  2.00, 13.00);  -- 1 Pudim (13% IVA) (produto_id=11)
GO

-- Ao inserir PedidoItem, as triggers:
--  - Geram MovimentacaoEstoque (tipo='saida') para cada ingrediente de 'Bife à Portuguesa'
--  - Abatem estoque de 'Cerveja' e 'Pudim'
--  - Atualizam Produto.stock_atual e, se abaixo do mínimo, geram Encomenda automática


/* ------------------------------------------------
   13. Inserir Encomenda e Marcar como Recebida
------------------------------------------------ */
INSERT INTO Encomenda (fornecedor_id, data_encomenda, status, valor_total)
VALUES (1, GETDATE(), 'pendente', 0.00);

DECLARE @encomendaId1 INT = SCOPE_IDENTITY();

-- Inserir itens na encomenda: 100 Batatas e 50 Carne de Vaca
INSERT INTO EncomendaItem (encomenda_id, produto_id, quantidade, preco_unitario) VALUES
    (@encomendaId1, 1, 100, 0.20),  -- Batata
    (@encomendaId1, 2,  50, 5.00);  -- Carne de Vaca

-- Atualizar valor_total da encomenda
UPDATE Encomenda
SET valor_total = (
    SELECT SUM(quantidade * preco_unitario)
    FROM EncomendaItem
    WHERE encomenda_id = @encomendaId1
)
WHERE encomenda_id = @encomendaId1;

-- Marcar a encomenda como 'recebida' para disparar trigger de entrada de estoque
UPDATE Encomenda
SET status = 'recebida'
WHERE encomenda_id = @encomendaId1;
GO


/* ------------------------------------------------
   14. Verificar Stocks Após Seeds (opcional)
------------------------------------------------ */
/*
SELECT produto_id, nome, stock_atual
FROM Produto
WHERE produto_id IN (1,2);
*/
