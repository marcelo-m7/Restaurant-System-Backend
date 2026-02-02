USE botecopro_db;
-- =========================================================================
-- Script: 01_create_tables.sql
-- Objetivo: Criação de todas as tabelas principais do banco de dados
-- Boteco Pro, conforme modelagem definida.
-- =========================================================================

/* ------------------------------------------------
   1. Tabela Categoria
   ------------------------------------------------ */
CREATE TABLE Categoria (
    categoria_id      INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(100)  NOT NULL,
    descricao         VARCHAR(255)  NULL
);

GO

/* ------------------------------------------------
   2. Tabela Fornecedor
   ------------------------------------------------ */
CREATE TABLE Fornecedor (
    fornecedor_id     INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(150)  NOT NULL,
    telefone          VARCHAR(20)   NULL,
    email             VARCHAR(100)  NULL,
    endereco          VARCHAR(255)  NULL,
    cidade            VARCHAR(100)  NULL,
    codigo_postal     VARCHAR(20)   NULL,
    pais              VARCHAR(100)  NULL
);

GO

/* ------------------------------------------------
   3. Tabela Produto
   ------------------------------------------------ */
CREATE TABLE Produto (
    produto_id        INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(150)  NOT NULL,
    tipo              VARCHAR(50)   NOT NULL,  -- 'ingrediente', 'bebida', 'sobremesa'
    custo_unitario    DECIMAL(10,2) NOT NULL,
    preco_venda       DECIMAL(10,2) NOT NULL,
    stock_atual       INT           NOT NULL DEFAULT 0,
    stock_minimo      INT           NOT NULL DEFAULT 0,
    stock_encomenda   INT           NOT NULL DEFAULT 0,
    fornecedor_id     INT           NOT NULL,
    CONSTRAINT FK_Produto_Fornecedor FOREIGN KEY (fornecedor_id)
        REFERENCES Fornecedor(fornecedor_id)
);

GO

/* ------------------------------------------------
   4. Tabela Encomenda
   ------------------------------------------------ */
CREATE TABLE Encomenda (
    encomenda_id      INT           IDENTITY(1,1) PRIMARY KEY,
    fornecedor_id     INT           NOT NULL,
    data_encomenda    DATETIME      NOT NULL DEFAULT GETDATE(),
    status            VARCHAR(20)   NOT NULL,  -- 'pendente', 'recebida', 'cancelada'
    valor_total       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT FK_Encomenda_Fornecedor FOREIGN KEY (fornecedor_id)
        REFERENCES Fornecedor(fornecedor_id)
);

GO

/* ------------------------------------------------
   5. Tabela EncomendaItem
   ------------------------------------------------ */
CREATE TABLE EncomendaItem (
    encomenda_item_id INT           IDENTITY(1,1) PRIMARY KEY,
    encomenda_id      INT           NOT NULL,
    produto_id        INT           NOT NULL,
    quantidade        INT           NOT NULL,
    preco_unitario    DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_EncomendaItem_Encomenda FOREIGN KEY (encomenda_id)
        REFERENCES Encomenda(encomenda_id),
    CONSTRAINT FK_EncomendaItem_Produto FOREIGN KEY (produto_id)
        REFERENCES Produto(produto_id)
);

GO

/* ------------------------------------------------
   6. Tabela MovimentacaoEstoque
   ------------------------------------------------ */
CREATE TABLE MovimentacaoEstoque (
    movimentacao_id   INT           IDENTITY(1,1) PRIMARY KEY,
    produto_id        INT           NOT NULL,
    data_movimentacao DATETIME      NOT NULL DEFAULT GETDATE(),
    tipo              VARCHAR(20)   NOT NULL,  -- 'entrada' ou 'saida'
    quantidade        INT           NOT NULL,
    preco_unitario    DECIMAL(10,2) NOT NULL,  -- custo no momento da movimentação
    pedido_id         INT           NULL,      -- se for consumo em prato (relaciona com PedidoItem.pedido_id)
    CONSTRAINT FK_MovEstoque_Produto FOREIGN KEY (produto_id)
        REFERENCES Produto(produto_id)
    -- (Opcional: FK para PedidoItem se desejar rastrear uso em prato específico)
);

GO

/* ------------------------------------------------
   7. Tabela Prato
   ------------------------------------------------ */
CREATE TABLE Prato (
    prato_id          INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(150)  NOT NULL,
    categoria_id      INT           NOT NULL,
    descricao          VARCHAR(255)  NULL,
    tempo_preparo     INT           NOT NULL,    -- em minutos
    preco_base        DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Prato_Categoria FOREIGN KEY (categoria_id)
        REFERENCES Categoria(categoria_id)
);

GO

/* ------------------------------------------------
   8. Tabela PratoIngrediente
   ------------------------------------------------ */
CREATE TABLE PratoIngrediente (
    prato_id              INT           NOT NULL,
    produto_id            INT           NOT NULL,
    quantidade_necessaria DECIMAL(10,3) NOT NULL,  -- unidade: kg, unid. ou litro
    CONSTRAINT PK_PratoIngrediente PRIMARY KEY (prato_id, produto_id),
    CONSTRAINT FK_PratoIngrediente_Prato FOREIGN KEY (prato_id)
        REFERENCES Prato(prato_id),
    CONSTRAINT FK_PratoIngrediente_Produto FOREIGN KEY (produto_id)
        REFERENCES Produto(produto_id)
);

GO

/* ------------------------------------------------
   9. Tabela Carreira
   ------------------------------------------------ */
CREATE TABLE Carreira (
    carreira_id       INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(100)  NOT NULL,    -- ex: 'Cozinheiro 2ª Classe'
    salario_mensal    DECIMAL(12,2) NOT NULL
);

GO

/* ------------------------------------------------
   10. Tabela Funcionario
   ------------------------------------------------ */
CREATE TABLE Funcionario (
    funcionario_id    INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(150)  NOT NULL,
    data_nascimento   DATE          NULL,
    telefone          VARCHAR(20)   NULL,
    email             VARCHAR(100)  NULL,
    cargo             VARCHAR(100)  NOT NULL,  -- ex: 'Cozinheiro', 'Garçon'
    carreira_id       INT           NOT NULL,
    data_admissao     DATE          NOT NULL,
    CONSTRAINT FK_Funcionario_Carreira FOREIGN KEY (carreira_id)
        REFERENCES Carreira(carreira_id)
);

GO

/* ------------------------------------------------
   11. Tabela RegistroHoras
   ------------------------------------------------ */
CREATE TABLE RegistroHoras (
    registro_horas_id INT           IDENTITY(1,1) PRIMARY KEY,
    funcionario_id    INT           NOT NULL,
    data_registro     DATE          NOT NULL,
    horas_normais     DECIMAL(4,2)  NOT NULL,  -- ex: 8.00
    horas_extra       DECIMAL(4,2)  NOT NULL,  -- ex: 3.50
    CONSTRAINT FK_RegHoras_Funcionario FOREIGN KEY (funcionario_id)
        REFERENCES Funcionario(funcionario_id)
);

GO

/* ------------------------------------------------
   12. Tabela Mesa
   ------------------------------------------------ */
CREATE TABLE Mesa (
    mesa_id           INT           IDENTITY(1,1) PRIMARY KEY,
    numero            INT           NOT NULL UNIQUE,
    capacidade        INT           NOT NULL,
    status            VARCHAR(20)   NOT NULL  DEFAULT 'livre'  -- 'livre', 'ocupada', 'reservada'
);

GO

/* ------------------------------------------------
   13. Tabela Cliente
   ------------------------------------------------ */
CREATE TABLE Cliente (
    cliente_id        INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(150)  NOT NULL,
    telefone          VARCHAR(20)   NULL,
    email             VARCHAR(100)  NULL,
    morada            VARCHAR(255)  NULL,
    cidade            VARCHAR(100)  NULL,
    codigo_postal     VARCHAR(20)   NULL,
    contribuinte      VARCHAR(20)   NULL  -- NIF ou similar
);

GO

/* ------------------------------------------------
   14. Tabela Reserva (Opcional)
   ------------------------------------------------ */
CREATE TABLE Reserva (
    reserva_id        INT           IDENTITY(1,1) PRIMARY KEY,
    cliente_id        INT           NOT NULL,
    mesa_id           INT           NOT NULL,
    data_reserva      DATE          NOT NULL,
    hora_reserva      TIME          NOT NULL,
    quantidade_pessoas INT          NOT NULL,
    status            VARCHAR(20)   NOT NULL DEFAULT 'ativa',  -- 'ativa', 'confirmada', 'cancelada'
    CONSTRAINT FK_Reserva_Cliente FOREIGN KEY (cliente_id)
        REFERENCES Cliente(cliente_id),
    CONSTRAINT FK_Reserva_Mesa FOREIGN KEY (mesa_id)
        REFERENCES Mesa(mesa_id)
);

GO

/* ------------------------------------------------
   15. Tabela Pedido
   ------------------------------------------------ */
CREATE TABLE Pedido (
    pedido_id         INT           IDENTITY(1,1) PRIMARY KEY,
    mesa_id           INT           NOT NULL,
    funcionario_id    INT           NOT NULL,  -- empregado de mesa que atendeu
    cliente_id        INT           NULL,      -- opcional
    data_pedido       DATETIME      NOT NULL DEFAULT GETDATE(),
    status            VARCHAR(20)   NOT NULL,  -- 'pendente', 'em_preparo', 'pronto', 'entregue', 'finalizado', 'cancelado'
    CONSTRAINT FK_Pedido_Mesa FOREIGN KEY (mesa_id)
        REFERENCES Mesa(mesa_id),
    CONSTRAINT FK_Pedido_Funcionario FOREIGN KEY (funcionario_id)
        REFERENCES Funcionario(funcionario_id),
    CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (cliente_id)
        REFERENCES Cliente(cliente_id)
);

GO

/* ------------------------------------------------
   16. Tabela PedidoItem
   ------------------------------------------------ */
CREATE TABLE PedidoItem (
    pedido_item_id    INT           IDENTITY(1,1) PRIMARY KEY,
    pedido_id         INT           NOT NULL,
    prato_id          INT           NULL,       -- NULL se for produto genérico (bebida/sobremesa)
    produto_id        INT           NULL,       -- NULL se for prato
    quantidade        INT           NOT NULL,
    preco_unitario    DECIMAL(10,2) NOT NULL,
    iva               DECIMAL(5,2)  NOT NULL,   -- 13% comida, 23% bebida
    CONSTRAINT FK_PedidoItem_Pedido FOREIGN KEY (pedido_id)
        REFERENCES Pedido(pedido_id),
    CONSTRAINT FK_PedidoItem_Prato FOREIGN KEY (prato_id)
        REFERENCES Prato(prato_id),
    CONSTRAINT FK_PedidoItem_Produto FOREIGN KEY (produto_id)
        REFERENCES Produto(produto_id)
);

GO

/* ------------------------------------------------
   17. Tabela Fatura
   ------------------------------------------------ */
CREATE TABLE Fatura (
    fatura_id         INT           IDENTITY(1,1) PRIMARY KEY,
    pedido_id         INT           NOT NULL UNIQUE,
    cliente_id        INT           NULL,  -- obrigatório se fatura empresarial
    data_emissao      DATETIME      NOT NULL DEFAULT GETDATE(),
    tipo_fatura       VARCHAR(20)   NOT NULL,  -- 'consumidor_final', 'empresa'
    nome_cliente      VARCHAR(150)  NULL,
    morada_cliente    VARCHAR(255)  NULL,
    cidade_cliente    VARCHAR(100)  NULL,
    codigo_postal     VARCHAR(20)   NULL,
    contribuinte      VARCHAR(20)   NULL,
    subtotal_comida   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    subtotal_bebida   DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    iva_comida        DECIMAL(10,2) NOT NULL DEFAULT 0.00,  -- 13%
    iva_bebida        DECIMAL(10,2) NOT NULL DEFAULT 0.00,  -- 23%
    total             DECIMAL(14,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT FK_Fatura_Pedido FOREIGN KEY (pedido_id)
        REFERENCES Pedido(pedido_id),
    CONSTRAINT FK_Fatura_Cliente FOREIGN KEY (cliente_id)
        REFERENCES Cliente(cliente_id)
);

GO

/* ------------------------------------------------
   18. Tabela FaturaItem
   ------------------------------------------------ */
CREATE TABLE FaturaItem (
    fatura_item_id    INT           IDENTITY(1,1) PRIMARY KEY,
    fatura_id         INT           NOT NULL,
    descricao         VARCHAR(255)  NOT NULL,
    quantidade        INT           NOT NULL,
    preco_unitario    DECIMAL(10,2) NOT NULL,
    valor_liquido     DECIMAL(12,2) NOT NULL,
    percentual_iva     DECIMAL(5,2)  NOT NULL,
    valor_iva         DECIMAL(10,2) NOT NULL,
    valor_total_linha DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_FaturaItem_Fatura FOREIGN KEY (fatura_id)
        REFERENCES Fatura(fatura_id)
);

GO

/* ------------------------------------------------
   19. Tabela MenuEspecial
   ------------------------------------------------ */
CREATE TABLE MenuEspecial (
    menu_especial_id  INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(150)  NOT NULL,
    descricao         VARCHAR(255)  NULL,
    data_inicio       DATE          NOT NULL,
    data_fim          DATE          NOT NULL,
    preco_total       DECIMAL(12,2) NOT NULL
);

GO

/* ------------------------------------------------
   20. Tabela MenuEspecialPrato
   ------------------------------------------------ */
CREATE TABLE MenuEspecialPrato (
    menu_especial_id  INT           NOT NULL,
    prato_id          INT           NOT NULL,
    ordem             INT           NOT NULL,  -- 1=entrada,2=peixe,3=carne,4=sobremesa,5=café
    CONSTRAINT PK_MenuEspecialPrato PRIMARY KEY (menu_especial_id, prato_id),
    CONSTRAINT FK_MenuEspPrato_MenuEspecial FOREIGN KEY (menu_especial_id)
        REFERENCES MenuEspecial(menu_especial_id),
    CONSTRAINT FK_MenuEspPrato_Prato FOREIGN KEY (prato_id)
        REFERENCES Prato(prato_id)
);

GO
