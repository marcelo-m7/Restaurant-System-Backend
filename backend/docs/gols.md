## 1. Visão Geral e Requisitos

O objetivo deste guia é organizar em um plano completo o desenvolvimento do banco de dados para um aplicativo de gestão de restaurantes. A estrutura apresentada parte dos requisitos levantados na conversa anterior, oferecendo uma sequência clara de etapas, definindo tabelas, relacionamentos e objetos de consumo (Views, Materialized Views, Functions, Stored Procedures e Triggers) para que a equipe de desenvolvimento possa implementar e manter o sistema de forma consistente.

### 1.1. Escopo Funcional

1. **Cardápio e Itens de Venda**

   * Categorias de pratos (Carnes, Peixes, Massas, Sobremesas, Bebidas etc.).
   * Pratos e outros itens (bebidas, cafés, sobremesas) com preço de venda calculado a partir do custo dos componentes, trabalho de confeção, serviço e limpeza.

2. **Compras, Estoque e Fornecedores**

   * Registro de produtos adquiridos (ingredientes, bebidas, itens diversos).
   * Fornecedores associados a cada produto.
   * Controle de stock (nível atual, stock mínimo, stock de encomenda).
   * Geração automática de encomendas ao fornecedor quando o stock atinge o mínimo.

3. **Funcionários e Folha de Pagamento**

   * Cadastro de funcionários, suas carreiras (cozinheiro, empregado de mesa, auxiliar etc.) e níveis salariais (e.g. Cozinheiro 2ª Classe, Cozinheiro Chefe).
   * Registro de horas trabalhadas (normais e extraordinárias) e cálculo mensal de vencimentos, considerando:

     * Horas normais.
     * Horas extraordinárias (2h com valor normal, próximas 5h com 1.5×, demais com 2×).

4. **Atendimento a Clientes e Mesas**

   * Gerenciamento de mesas (número, capacidade, status).
   * Alocação de clientes a mesas.
   * Registro de pedidos (itens solicitados, sequência de serviço: entradas, pratos, bebidas, sobremesas).
   * Fluxo de preparação (cozinha → pronto → entrega pelo empregado de mesa → recolha de pratos).

5. **Faturamento e IVA**

   * Emissão de faturas ao consumidor final (com ou sem contribuinte) ou empresariais (dados completos do cliente).
   * Detalhamento de itens consumidos (quantidade, preço unitário, subtotal por linha), totais com IVA (13% comida, 23% bebida).

6. **Menus Especiais e Promoções Sazonais**

   * Criação de cardápios especiais para datas comemorativas (Dia dos Namorados, Páscoa, Natal etc.), incluindo conjunto fixo de entradas, prato de peixe, prato de carne, sobremesa e café, com preço especial.

### 1.2. Escopo de Objetos para API

* A API que consumirá este banco de dados disponibilizará apenas operações de leitura (SELECT), por meio de:

  * **Views** (consultas pré-definidas).
  * **Stored Procedures** (SPs) para cenários parametrizados.
  * **Functions** (Scalar e Table-Valued) para cálculos e retornos tabulares.
* **Não haverá acesso direto de INSERT/UPDATE/DELETE pela API**: todas as inserções e atualizações de dados (e.g., movimentações de estoque, novos pedidos) serão feitas pelo banco de dados via triggers e procedimentos internos, ou por uma aplicação back-office separada.

---

## 2. Modelagem Conceitual e Lógica

### 2.1. Entidades Principais

1. **Categoria**: classifica pratos (e.g. Carnes, Peixes, Massas).
2. **Produto**: ingredientes, bebidas, itens diversos, com controle de stock.
3. **Fornecedor**: dados de contato dos fornecedores de produtos.
4. **Encomenda**: pedido de produtos a fornecedores.
5. **MovimentaçãoEstoque**: histórico de uso ou entrada de produtos no estoque.
6. **Prato**: itens do cardápio (pratos principais, entradas, sobremesas).
7. **PratoIngrediente**: vincula ingredientes (Produtos) necessários para confeção de cada prato, com quantidade.
8. **Funcionario**: cadastro de colaboradores, suas carreiras e níveis.
9. **Carreira**: cargos e níveis salariais (e.g. Cozinheiro 2ª Classe, Cozinheiro Chefe).
10. **RegistroHoras**: horas trabalhadas por funcionário, indicando data, horas normais e horas extra.
11. **Mesa**: mesas do restaurante, número, capacidade e status (livre, ocupada).
12. **Cliente**: dados de clientes (nome, morada, contribuinte opcional).
13. **Pedido**: registro de pedidos feitos pelo cliente, associado a mesa, funcionário e status.
14. **PedidoItem**: itens de cada pedido (indica prato ou produto, quantidade, preço unitário).
15. **Fatura**: registro de faturamento gerado ao finalizar o pedido, com detalhamento de itens e valores de IVA.
16. **MenuEspecial**: menus criados para eventos, contendo conjunto de pratos pré-definidos e período de validade.
17. **Reserva** (opcional): agendamento prévio de mesas pelos clientes.
18. **CaixaDiario** (opcional): consolidação diária de faturamento, devoluções e outros recebimentos.

### 2.2. Relacionamentos

* **Categoria 1–N Prato**: cada prato pertence a uma categoria.
* **Prato N–N Produto** (via PratoIngrediente): define quais produtos (ingredientes) e em que quantidade são usados para elaborar cada prato.
* **Produto N–1 Fornecedor**: cada produto tem um fornecedor principal (último no histórico, para encomendas automáticas).
* **Encomenda N–1 Fornecedor**: cada encomenda é feita a um único fornecedor; pode conter múltiplos itens de produtos.
* **EncomendaItem N–1 Encomenda** (tabela auxiliar opcional): detalha quais produtos e quantas unidades foram encomendados.
* **Produto 1–N MovimentaçãoEstoque**: registra entradas (encomenda recebida) e saídas (uso em preparo de pratos).
* **Carreira 1–N Funcionario**: cada funcionário possui uma carreira (categoria) com nível e salário base.
* **Funcionario 1–N RegistroHoras**: registra diariamente ou mensalmente as horas trabalhadas.
* **Mesa 1–N Pedido**: cada pedido está associado a uma mesa.
* **Cliente 1–N Pedido**: opcionalmente, um cliente pode estar vinculado a um pedido (apenas para faturas empresariais).
* **Pedido 1–N PedidoItem**: detalha os itens consumidos no pedido (pratos, bebidas, etc.).
* **Pedido 1–1 Fatura**: cada pedido gera, ao final, uma fatura.
* **MenuEspecial N–N Prato** (via MenuEspecialPrato): vincula quais pratos fazem parte de um menu especial.
* **Reserva N–1 Mesa**: (se implementada) vincula reserva a uma mesa.
* **Reserva N–1 Cliente**: vincula reserva a um cliente que reservou.

---

## 3. Definição de Tabelas e Colunas

A seguir são apresentadas as tabelas principais com sugestões de colunas, tipos e restrições. Ajustes finos (tamanhos de campos VARCHAR, precisões decimais, NOT NULL) devem ser feitos conforme convenções da equipe e volume de dados esperado. Vamos expor também chaves primárias (PK) e estrangeiras (FK).

> **Nota**: todos os campos de data devem usar tipo `DATE` ou `DATETIME` conforme necessidade de hora exata (e.g., `Pedido.data_pedido DATETIME`).

### 3.1. Categoria

```sql
CREATE TABLE Categoria (
    categoria_id      INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(100)  NOT NULL,
    descricao         VARCHAR(255)  NULL
);
```

### 3.2. Fornecedor

```sql
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
```

### 3.3. Produto

```sql
CREATE TABLE Produto (
    produto_id        INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(150)  NOT NULL,
    tipo              VARCHAR(50)   NOT NULL,  -- ex: 'ingrediente', 'bebida', 'sobremesa'
    custo_unitario    DECIMAL(10,2) NOT NULL,  -- custo de aquisição
    preco_venda       DECIMAL(10,2) NOT NULL,  -- calculado ou definido
    stock_atual       INT           NOT NULL DEFAULT 0,
    stock_minimo      INT           NOT NULL DEFAULT 0,
    stock_encomenda   INT           NOT NULL DEFAULT 0,  -- valor de pedido quando stock atinge mínimo
    fornecedor_id     INT           NOT NULL,
    CONSTRAINT FK_Produto_Fornecedor FOREIGN KEY (fornecedor_id)
        REFERENCES Fornecedor(fornecedor_id)
);
```

### 3.4. Encomenda

```sql
CREATE TABLE Encomenda (
    encomenda_id      INT           IDENTITY(1,1) PRIMARY KEY,
    fornecedor_id     INT           NOT NULL,
    data_encomenda    DATETIME      NOT NULL DEFAULT GETDATE(),
    status            VARCHAR(20)   NOT NULL,  -- ex: 'pendente', 'recebida', 'cancelada'
    valor_total       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT FK_Encomenda_Fornecedor FOREIGN KEY (fornecedor_id)
        REFERENCES Fornecedor(fornecedor_id)
);
```

#### 3.4.1. EncomendaItem (itens de cada encomenda)

```sql
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
```

### 3.5. MovimentacaoEstoque

Registra cada saída (uso) ou entrada (recebimento de encomenda) de um produto.

```sql
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
    -- (Opcional: FK para PedidoItem se quisermos rastrear uso específico em prato)
);
```

### 3.6. Prato

```sql
CREATE TABLE Prato (
    prato_id          INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(150)  NOT NULL,
    categoria_id      INT           NOT NULL,
    descricao          VARCHAR(255)  NULL,
    tempo_preparo     INT           NOT NULL,    -- em minutos
    preco_base        DECIMAL(10,2) NOT NULL,    -- pode ser calculado ou definido
    CONSTRAINT FK_Prato_Categoria FOREIGN KEY (categoria_id)
        REFERENCES Categoria(categoria_id)
);
```

#### 3.6.1. PratoIngrediente (itens necessários para confeção)

```sql
CREATE TABLE PratoIngrediente (
    prato_id          INT           NOT NULL,
    produto_id        INT           NOT NULL,
    quantidade_necessaria DECIMAL(10,3) NOT NULL,  -- unidade: kg, unidade ou litro, conforme produto
    CONSTRAINT PK_PratoIngrediente PRIMARY KEY (prato_id, produto_id),
    CONSTRAINT FK_PratoIngrediente_Prato FOREIGN KEY (prato_id)
        REFERENCES Prato(prato_id),
    CONSTRAINT FK_PratoIngrediente_Produto FOREIGN KEY (produto_id)
        REFERENCES Produto(produto_id)
);
```

### 3.7. Carreira

```sql
CREATE TABLE Carreira (
    carreira_id       INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(100)  NOT NULL,    -- ex: 'Cozinheiro 2ª Classe', 'Cozinheiro Chefe'
    salario_mensal    DECIMAL(12,2) NOT NULL
);
```

### 3.8. Funcionario

```sql
CREATE TABLE Funcionario (
    funcionario_id    INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(150)  NOT NULL,
    data_nascimento   DATE          NULL,
    telefone          VARCHAR(20)   NULL,
    email             VARCHAR(100)  NULL,
    cargo              VARCHAR(100) NOT NULL,  -- ex: 'Cozinheiro', 'Empregado de Mesa'
    carreira_id       INT           NOT NULL,  -- nível e salário base
    data_admissao     DATE          NOT NULL,
    CONSTRAINT FK_Funcionario_Carreira FOREIGN KEY (carreira_id)
        REFERENCES Carreira(carreira_id)
);
```

### 3.9. RegistroHoras

```sql
CREATE TABLE RegistroHoras (
    registro_horas_id INT           IDENTITY(1,1) PRIMARY KEY,
    funcionario_id    INT           NOT NULL,
    data_registro     DATE          NOT NULL,
    horas_normais     DECIMAL(4,2)  NOT NULL,  -- e.g. 8.00
    horas_extra       DECIMAL(4,2)  NOT NULL,  -- e.g. 3.50
    CONSTRAINT FK_RegHoras_Funcionario FOREIGN KEY (funcionario_id)
        REFERENCES Funcionario(funcionario_id)
);
```

### 3.10. Mesa

```sql
CREATE TABLE Mesa (
    mesa_id           INT           IDENTITY(1,1) PRIMARY KEY,
    numero            INT           NOT NULL UNIQUE,
    capacidade        INT           NOT NULL,
    status            VARCHAR(20)   NOT NULL  DEFAULT 'livre'  -- 'livre', 'ocupada', 'reservada'
);
```

### 3.11. Cliente

```sql
CREATE TABLE Cliente (
    cliente_id        INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(150)  NOT NULL,
    telefone          VARCHAR(20)   NULL,
    email             VARCHAR(100)  NULL,
    morada            VARCHAR(255)  NULL,
    cidade            VARCHAR(100)  NULL,
    codigo_postal     VARCHAR(20)   NULL,
    contribuinte      VARCHAR(20)   NULL  -- NIF ou similar, opcional
);
```

### 3.12. Reserva (opcional)

```sql
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
```

### 3.13. Pedido

```sql
CREATE TABLE Pedido (
    pedido_id         INT           IDENTITY(1,1) PRIMARY KEY,
    mesa_id           INT           NOT NULL,
    funcionario_id    INT           NOT NULL,  -- empregado de mesa que atendeu
    cliente_id        INT           NULL,      -- quando desejar associar cliente
    data_pedido       DATETIME      NOT NULL DEFAULT GETDATE(),
    status            VARCHAR(20)   NOT NULL,  -- 'pendente', 'em_preparo', 'pronto', 'entregue', 'finalizado', 'cancelado'
    CONSTRAINT FK_Pedido_Mesa FOREIGN KEY (mesa_id)
        REFERENCES Mesa(mesa_id),
    CONSTRAINT FK_Pedido_Funcionario FOREIGN KEY (funcionario_id)
        REFERENCES Funcionario(funcionario_id),
    CONSTRAINT FK_Pedido_Cliente FOREIGN KEY (cliente_id)
        REFERENCES Cliente(cliente_id)
);
```

#### 3.13.1. PedidoItem

```sql
CREATE TABLE PedidoItem (
    pedido_item_id    INT           IDENTITY(1,1) PRIMARY KEY,
    pedido_id         INT           NOT NULL,
    prato_id          INT           NULL,       -- ou Produto (bebida/sobremesa) se quisermos unificar; aqui consideramos só Prato
    produto_id        INT           NULL,       -- para itens que não são pratos (bebidas, sobremesas)
    quantidade        INT           NOT NULL,
    preco_unitario    DECIMAL(10,2) NOT NULL,
    iva               DECIMAL(5,2)  NOT NULL,   -- 13% para comida, 23% para bebida
    CONSTRAINT FK_PedidoItem_Pedido FOREIGN KEY (pedido_id)
        REFERENCES Pedido(pedido_id),
    CONSTRAINT FK_PedidoItem_Prato FOREIGN KEY (prato_id)
        REFERENCES Prato(prato_id),
    CONSTRAINT FK_PedidoItem_Produto FOREIGN KEY (produto_id)
        REFERENCES Produto(produto_id)
);
```

### 3.14. Fatura

```sql
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
    contribuinte      VARCHAR(20)   NULL,  -- NIF cliente
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
```

#### 3.14.1. FaturaItem (detalhamento das linhas de faturamento)

```sql
CREATE TABLE FaturaItem (
    fatura_item_id    INT           IDENTITY(1,1) PRIMARY KEY,
    fatura_id         INT           NOT NULL,
    descricao         VARCHAR(255)  NOT NULL,  -- nome do prato ou produto
    quantidade        INT           NOT NULL,
    preco_unitario    DECIMAL(10,2) NOT NULL,
    valor_liquido     DECIMAL(12,2) NOT NULL,  -- antes de IVA
    percentual_iva     DECIMAL(5,2)  NOT NULL,  -- 13 ou 23
    valor_iva         DECIMAL(10,2) NOT NULL,
    valor_total_linha DECIMAL(12,2) NOT NULL,  -- valor_liquido + valor_iva
    CONSTRAINT FK_FaturaItem_Fatura FOREIGN KEY (fatura_id)
        REFERENCES Fatura(fatura_id)
);
```

### 3.15. MenuEspecial

```sql
CREATE TABLE MenuEspecial (
    menu_especial_id  INT           IDENTITY(1,1) PRIMARY KEY,
    nome              VARCHAR(150)  NOT NULL,
    descricao         VARCHAR(255)  NULL,
    data_inicio       DATE          NOT NULL,
    data_fim          DATE          NOT NULL,
    preco_total       DECIMAL(12,2) NOT NULL
);
```

#### 3.15.1. MenuEspecialPrato (itens de cada menu especial)

```sql
CREATE TABLE MenuEspecialPrato (
    menu_especial_id  INT           NOT NULL,
    prato_id          INT           NOT NULL,
    ordem             INT           NOT NULL,  -- 1=entrada, 2=peixe, 3=carne, 4=sobremesa, 5=café
    CONSTRAINT PK_MenuEspecialPrato PRIMARY KEY (menu_especial_id, prato_id),
    CONSTRAINT FK_MenuEspPrato_MenuEspecial FOREIGN KEY (menu_especial_id)
        REFERENCES MenuEspecial(menu_especial_id),
    CONSTRAINT FK_MenuEspPrato_Prato FOREIGN KEY (prato_id)
        REFERENCES Prato(prato_id)
);
```

---

## 4. Estrutura de Índices e Considerações de Performance

1. **Chaves Primárias e Índices Clusterizados**

   * Garanta que todas as chaves primárias (`IDENTITY(1,1)`) sejam índices clusterizados por padrão.
2. **Índices em Colunas-Filtro**

   * `Produto(stock_atual)`: se houver consultas frequentes para detectar baixo estoque, crie índice não clusterizado sobre `stock_atual`.
   * `MovimentacaoEstoque(data_movimentacao)`: índice sobre data para relatórios periódicos.
   * `Pedido(status)`: índice para filtrar pedidos “pendente” ou “em\_preparo”.
   * `Fatura(data_emissao)`: índice para consultas de faturamento por período.
3. **Unique Constraints**

   * `Mesa(numero)` já definido como UNIQUE.
   * `Fatura(pedido_id)`: garantir 1–1 entre pedido e fatura.
4. **Índice em Materialized View**

   * Sobre a coluna de produto (nome ou ID) para acelerar buscas em relatórios de consumo de estoque.

---

## 5. Objetos de Consumo: Views

As Views permitem fornecer à API consultas pré-definidas, encapsulando lógica de junção e agregação. A equipe de front-end/back-end faz apenas SELECT nas Views.

### 5.1. Visão de Mesas Disponíveis

```sql
CREATE VIEW view_mesas_disponiveis AS
SELECT
    mesa_id,
    numero,
    capacidade
FROM Mesa
WHERE status = 'livre';
```

**Caso de uso:** listar mesas que podem receber novos clientes.

### 5.2. Visão de Pedidos em Andamento

```sql
CREATE VIEW view_pedidos_em_andamento AS
SELECT
    p.pedido_id,
    p.mesa_id,
    p.funcionario_id,
    p.data_pedido,
    p.status
FROM Pedido p
WHERE p.status IN ('pendente', 'em_preparo');
```

**Caso de uso:** permitir que a cozinha ou gerência monitore pedidos que ainda não foram finalizados.

### 5.3. Visão de Estoque de Ingredientes

```sql
CREATE VIEW view_estoque_ingredientes AS
SELECT
    produto_id,
    nome AS nome_produto,
    stock_atual,
    stock_minimo
FROM Produto
WHERE tipo = 'ingrediente';
```

**Caso de uso:** verificar quantidades de ingredientes e identificar itens próximos do stock mínimo.

### 5.4. Visão de Faturamento por Período

```sql
CREATE VIEW view_faturamento_periodo AS
SELECT
    YEAR(f.data_emissao) AS ano,
    MONTH(f.data_emissao) AS mes,
    SUM(f.total) AS total_faturado
FROM Fatura f
GROUP BY YEAR(f.data_emissao), MONTH(f.data_emissao);
```

**Caso de uso:** dashboard de faturamento mensal ou anual.

### 5.5. Visão de Horas Trabalhadas por Funcionário

```sql
CREATE VIEW view_horas_funcionario AS
SELECT
    f.funcionario_id,
    f.nome AS nome_funcionario,
    SUM(r.horas_normais)    AS total_horas_normais,
    SUM(r.horas_extra)      AS total_horas_extra
FROM Funcionario f
JOIN RegistroHoras r
    ON f.funcionario_id = r.funcionario_id
GROUP BY f.funcionario_id, f.nome;
```

**Caso de uso:** relatório de horas totais de cada funcionário, para cálculos de salários.

### 5.6. Visão de Clientes Frequentes

```sql
CREATE VIEW view_clientes_frequentes AS
SELECT
    c.cliente_id,
    c.nome AS nome_cliente,
    COUNT(p.pedido_id) AS total_pedidos
FROM Cliente c
JOIN Pedido p
    ON c.cliente_id = p.cliente_id
GROUP BY c.cliente_id, c.nome
ORDER BY total_pedidos DESC;
```

**Caso de uso:** identificar clientes com maior número de visitas.

### 5.7. Visão de Pratos Mais Vendidos

```sql
CREATE VIEW view_pratos_populares AS
SELECT
    pi.prato_id,
    pr.nome AS nome_prato,
    COUNT(pi.pedido_item_id) AS total_vendas
FROM PedidoItem pi
JOIN Prato pr
    ON pi.prato_id = pr.prato_id
GROUP BY pi.prato_id, pr.nome
ORDER BY total_vendas DESC;
```

**Caso de uso:** análise de cardápio para detectar pratos de maior sucesso.

### 5.8. Visão de Entregas por Fornecedor

```sql
CREATE VIEW view_fornecedores_entregas AS
SELECT
    f.fornecedor_id,
    f.nome AS nome_fornecedor,
    COUNT(e.encomenda_id) AS total_encomendas_recebidas
FROM Fornecedor f
JOIN Encomenda e
    ON f.fornecedor_id = e.fornecedor_id
WHERE e.status = 'recebida'
GROUP BY f.fornecedor_id, f.nome;
```

**Caso de uso:** monitorar a frequência e pontualidade de cada fornecedor.

### 5.9. Visão de Promoções Ativas (Menus Especiais)

```sql
CREATE VIEW view_promocoes_ativas AS
SELECT
    menu_especial_id,
    nome AS nome_menu,
    data_inicio,
    data_fim,
    preco_total
FROM MenuEspecial
WHERE data_inicio <= CAST(GETDATE() AS DATE)
  AND data_fim    >= CAST(GETDATE() AS DATE);
```

**Caso de uso:** listar menus especiais disponíveis na data atual.

### 5.10. Visão de Reservas Ativas (se for implementada)

```sql
CREATE VIEW view_reservas_ativas AS
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
```

**Caso de uso:** visualizar reservas futuras confirmadas.

---

## 6. Materialized Views

Para relatórios pesados que reúnem grandes volumes de dados (ex.: consumo de estoque ao longo do tempo), utilizamos Materialized Views, reprocessadas periodicamente por ETL ou agendadas. A API lê diretamente as MV para alta performance.

### 6.1. MV: Estoque Utilizado por Período

**Objetivo:** listar quantidade de cada produto consumido em um intervalo de datas (data\_início, data\_fim).
**Observação:** no SQL Server, usar *Indexed View* ou agendar rebuild manualmente.

```sql
CREATE VIEW mv_estoque_utilizado_periodo
WITH SCHEMABINDING
AS
SELECT
    me.produto_id,
    SUM(me.quantidade) AS quantidade_total,
    MIN(me.data_movimentacao) AS data_inicio,
    MAX(me.data_movimentacao) AS data_fim
FROM dbo.MovimentacaoEstoque AS me
WHERE me.tipo = 'saida'
GROUP BY me.produto_id;
GO

-- Para tornar a view indexada (materializada), é necessário criar índice clusterizado:
CREATE UNIQUE CLUSTERED INDEX idx_mv_estoque_utilizado_periodo
    ON mv_estoque_utilizado_periodo (produto_id);
```

> **Como usar parâmetros?** Por limitações do SQL Server em Indexed Views, a filtragem por data deve ser feita em uma View derivada ou em Stored Procedure:

```sql
CREATE VIEW view_estoque_utilizado_periodo_param AS
SELECT
    produto_id,
    quantidade_total,
    data_inicio,
    data_fim
FROM mv_estoque_utilizado_periodo
WHERE data_inicio >= @data_inicio
  AND data_fim   <= @data_fim;
```

Mas como o SQL Server não permite parâmetros em VIEW, recomenda-se criar uma Stored Procedure (`sp_get_estoque_utilizado`) que filtre sobre a MV.

### 6.2. Índice sobre MV para Nome de Produto

A MV acima agrupa por `produto_id`, mas para pesquisa por nome, podemos criar uma View adicional unindo MV com Produto:

```sql
CREATE VIEW view_estoque_utilizado_detalhado
AS
SELECT
    mv.produto_id,
    p.nome AS nome_produto,
    mv.quantidade_total,
    mv.data_inicio,
    mv.data_fim
FROM mv_estoque_utilizado_periodo AS mv
JOIN Produto p
    ON mv.produto_id = p.produto_id;
GO

-- Índice não clusterizado sobre nome_produto:
CREATE NONCLUSTERED INDEX idx_mv_estoque_nome_produto
    ON view_estoque_utilizado_detalhado (nome_produto);
```

---

## 7. Funções (Functions)

As Functions encapsulam lógica de cálculo que pode ser reaproveitada tanto em Views quanto em Stored Procedures. Há dois tipos principais:

1. **Scalar Functions**: retornam um valor escalar (NUMERIC, INT etc.).
2. **Table-Valued Functions**: retornam um conjunto de linhas/tabulado.

### 7.1. Scalar Function: Calcular Vencimentos em Mês/Ano

Calcula o total gasto em salários para um dado mês e ano, com base em `RegistroHoras` e `Carreira`.

```sql
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
            CASE
                -- cálculo do valor a pagar pelas horas registradas: salário mensal proporcional + horas extra
                -- Assumimos que RegistroHoras.horas_normais e horas_extra são as horas daquele dia
                -- Primeiro, obter salário base mensal dividido por 160h (30 dias × 8h)
                ((c.salario_mensal / 160.0) * r.horas_normais)
                +
                (CASE
                    WHEN r.horas_extra <= 2
                        THEN (c.salario_mensal / 160.0) * r.horas_extra
                    WHEN r.horas_extra <= 7  -- 2h normais + próximas 5h ×1.5
                        THEN (c.salario_mensal / 160.0) * 2
                               + (c.salario_mensal / 160.0) * 1.5 * (r.horas_extra - 2)
                    ELSE -- acima de 7h extra: 2h normais, 5h ×1.5, restante ×2
                        (c.salario_mensal / 160.0) * 2
                        + (c.salario_mensal / 160.0) * 1.5 * 5
                        + (c.salario_mensal / 160.0) * 2 * (r.horas_extra - 7)
                 END)
            )
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
```

> **Comentário:** A lógica interna pode variar conforme regras específicas (e.g., horário de almoço, faltas). Ajuste coeficientes se a convenção de horas mensais diferir.

### 7.2. Table-Valued Function: Valores Gastos em Stock por Mês/Ano

Retorna, para cada produto, o valor total gasto em saídas de estoque (uso em preparo de pratos) em um mês e ano informados.

```sql
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
        p.nome            AS nome_produto,
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
```

### 7.3. Scalar Function: Calcular Total Faturado entre Datas

Retorna o somatório do campo `Fatura.total` para faturas emitidas em um intervalo dado.

```sql
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
```

### 7.4. Table-Valued Function: Produtos Abaixo do Stock Mínimo

Retorna lista de produtos cujo `stock_atual` está abaixo do `stock_minimo`.

```sql
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
```

### 7.5. Scalar Function: Calcular Horas Trabalhadas de Funcionário em Período

Retorna a soma de horas (normais + extra) para determinado funcionário e par data\_inicio/data\_fim.

```sql
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
```

---

## 8. Stored Procedures

As Stored Procedures (SPs) expõem cenários de leitura mais complexos, envolvendo parâmetros e chamando as Functions ou Views definidas. A API irá invocar essas SPs (com EXEC nome\_sp @param1, @param2…).

### 8.1. SP: Obter Mesas Disponíveis

```sql
CREATE PROCEDURE sp_obter_mesas_disponiveis
AS
BEGIN
    SELECT * 
    FROM view_mesas_disponiveis;
END;
GO
```

### 8.2. SP: Obter Pedidos por Funcionário

Parâmetro: `@funcionario_id INT`

```sql
CREATE PROCEDURE sp_obter_pedidos_por_funcionario
    @funcionario_id INT
AS
BEGIN
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
```

### 8.3. SP: Obter Estoque de Ingrediente Específico

Parâmetro: `@ingrediente_id INT`

```sql
CREATE PROCEDURE sp_obter_estoque_ingrediente
    @ingrediente_id INT
AS
BEGIN
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
```

### 8.4. SP: Obter Faturamento por Período (Usando Function)

Parâmetros: `@data_inicio DATE`, `@data_fim DATE`

```sql
CREATE PROCEDURE sp_obter_faturamento_por_periodo
    @data_inicio DATE,
    @data_fim    DATE
AS
BEGIN
    DECLARE @total DECIMAL(14,2);
    SET @total = dbo.fn_calcular_total_faturado(@data_inicio, @data_fim);

    SELECT
        @data_inicio AS data_inicio,
        @data_fim    AS data_fim,
        @total       AS total_faturado;
END;
GO
```

### 8.5. SP: Obter Horas Trabalhadas de Funcionário em Período (Usando Function)

Parâmetros: `@funcionario_id INT`, `@data_inicio DATE`, `@data_fim DATE`

```sql
CREATE PROCEDURE sp_obter_horas_trabalhadas
    @funcionario_id INT,
    @data_inicio    DATE,
    @data_fim       DATE
AS
BEGIN
    DECLARE @total_horas DECIMAL(10,2);
    SET @total_horas = dbo.fn_calcular_horas_trabalhadas(@funcionario_id, @data_inicio, @data_fim);

    SELECT
        @funcionario_id AS funcionario_id,
        @data_inicio    AS data_inicio,
        @data_fim       AS data_fim,
        @total_horas    AS total_horas;
END;
GO
```

### 8.6. SP: Obter Clientes Frequentes

```sql
CREATE PROCEDURE sp_obter_clientes_frequentes
AS
BEGIN
    SELECT * 
    FROM view_clientes_frequentes;
END;
GO
```

### 8.7. SP: Obter Pratos Mais Vendidos

```sql
CREATE PROCEDURE sp_obter_pratos_populares
AS
BEGIN
    SELECT * 
    FROM view_pratos_populares;
END;
GO
```

### 8.8. SP: Obter Entregas de um Fornecedor

Parâmetro: `@fornecedor_id INT`

```sql
CREATE PROCEDURE sp_obter_entregas_fornecedor
    @fornecedor_id INT
AS
BEGIN
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
```

### 8.9. SP: Obter Promoções Ativas

```sql
CREATE PROCEDURE sp_obter_promocoes_ativas
AS
BEGIN
    SELECT *
    FROM view_promocoes_ativas;
END;
GO
```

### 8.10. SP: Obter Reservas Ativas (Se Implementada)

```sql
CREATE PROCEDURE sp_obter_reservas_ativas
AS
BEGIN
    SELECT *
    FROM view_reservas_ativas;
END;
GO
```

### 8.11. SP: Obter Faturamento por Categoria de Prato

```sql
CREATE PROCEDURE sp_obter_faturamento_por_categoria
AS
BEGIN
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
```

---

## 9. Triggers

Os Triggers automatizam comportamentos críticos, como abatimento de estoque e geração automática de encomendas quando o stock cai abaixo do mínimo. Todas as operações de INSERT/UPDATE/DELETE sobre tabelas-chave (PedidoItem, MovimentacaoEstoque) disparam as ações necessárias.

### 9.1. Trigger: Abatimento de Estoque ao Inserir PedidoItem

**Objetivo:** sempre que um item de pedido (PedidoItem) for inserido com tipo “prato” ou “produto” de consumo imediato, gerar no estoque as movimentações de saída correspondentes. Se o pedido for cancelado (status alterado para ‘cancelado’), deve haver outra trigger para reverter esse abatimento.

```sql
-- Função auxiliar para abatimento
CREATE PROCEDURE sp_abatimento_estoque_pedidoitem
    @pedido_item_id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @prato_id       INT,
            @produto_id     INT,
            @quantidade     INT,
            @preco_unitario DECIMAL(10,2);

    SELECT
        @prato_id       = prato_id,
        @produto_id     = produto_id,
        @quantidade     = quantidade,
        @preco_unitario = preco_unitario
    FROM PedidoItem
    WHERE pedido_item_id = @pedido_item_id;

    IF @prato_id IS NOT NULL
    BEGIN
        -- Se for prato, buscar todos os ingredientes e abater no estoque
        INSERT INTO MovimentacaoEstoque (produto_id, data_movimentacao, tipo, quantidade, preco_unitario, pedido_id)
        SELECT 
            pi.produto_id,
            GETDATE(),
            'saida',
            pi.quantidade_necessaria * @quantidade,
            p.custo_unitario,
            (SELECT pedido_id FROM PedidoItem WHERE pedido_item_id = @pedido_item_id)
        FROM PratoIngrediente pi
        JOIN Produto p
            ON pi.produto_id = p.produto_id
        WHERE pi.prato_id = @prato_id;
    END
    ELSE IF @produto_id IS NOT NULL
    BEGIN
        -- Se for produto (bebida/sobremesa), abater diretamente
        INSERT INTO MovimentacaoEstoque (produto_id, data_movimentacao, tipo, quantidade, preco_unitario, pedido_id)
        VALUES
        (
            @produto_id,
            GETDATE(),
            'saida',
            @quantidade,
            @preco_unitario,
            (SELECT pedido_id FROM PedidoItem WHERE pedido_item_id = @pedido_item_id)
        );
    END;
END;
GO

-- Trigger AFTER INSERT em PedidoItem
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
```

### 9.2. Trigger: Verificar Stock Mínimo e Gerar Encomenda Automática

**Objetivo:** sempre que uma movimentação de estoque de tipo “saida” for inserida, verificar se o `stock_atual` do produto caiu abaixo do `stock_minimo` e, em caso afirmativo, gerar automaticamente uma nova `Encomenda` para o `Fornecedor` associado ao produto, com a quantidade necessária para retornar ao `stock_encomenda`.

```sql
-- Função auxiliar: recalcular stock_atual após qualquer movimentação
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

-- Trigger AFTER INSERT em MovimentacaoEstoque
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

    -- 3. Se tipo = 'saida' e stock_atual < stock_minimo, gerar encomenda
    IF @tipo = 'saida' AND @stock_atual < @stock_minimo
    BEGIN
        SET @quantidade_a_encomendar = @stock_encom - @stock_atual;
        IF @quantidade_a_encomendar > 0
        BEGIN
            -- Inserir nova encomenda
            DECLARE @nova_encomenda_id INT;
            INSERT INTO Encomenda (fornecedor_id, data_encomenda, status, valor_total)
            VALUES (@fornecedor_id, GETDATE(), 'pendente', 0.00);

            SET @nova_encomenda_id = SCOPE_IDENTITY();

            -- Obter custo unitário atual do produto
            DECLARE @custo_unitario DECIMAL(10,2);
            SELECT @custo_unitario = custo_unitario
            FROM Produto
            WHERE produto_id = @produto_id;

            -- Inserir item de encomenda
            INSERT INTO EncomendaItem (encomenda_id, produto_id, quantidade, preco_unitario)
            VALUES (@nova_encomenda_id, @produto_id, @quantidade_a_encomendar, @custo_unitario);

            -- Atualizar valor_total na encomenda
            UPDATE Encomenda
            SET valor_total = (@quantidade_a_encomendar * @custo_unitario)
            WHERE encomenda_id = @nova_encomenda_id;
        END
    END
END;
GO
```

> **Observação:** caso haja requisição de inventário manual (entradas de estoque), essas movimentações também disparam `sp_atualizar_stock_produto`, mas não geram encomenda automática, pois condicionalmente só disparam se `tipo = 'saida'`.

### 9.3. Trigger: Atualizar Stock ao Receber Encomenda

Quando uma encomenda muda de status para “recebida” (por exemplo via atualização de aplicação back-office), devemos inserir movimentações de tipo “entrada” para todos os itens da encomenda, somando ao estoque.

```sql
-- Trigger AFTER UPDATE em Encomenda
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

    -- Somente se o status mudou para 'recebida'
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

        -- Para cada produto, recalcular stock (disparamos a SP de atualização para cada um)
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
```

### 9.4. Trigger: Geração Automática de Fatura ao Finalizar Pedido

Quando o status do pedido é alterado para “finalizado”, gera automaticamente a Fatura correspondente, calculando subtotal, IVA e total.

```sql
-- Trigger AFTER UPDATE em Pedido
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
        -- Buscar dados do pedido e do cliente
        SELECT @cliente_id = p.cliente_id
        FROM Pedido p
        WHERE p.pedido_id = @pedido_id;

        IF @cliente_id IS NULL
            SET @tipo_fatura = 'consumidor_final';
        ELSE
            SET @tipo_fatura = 'empresa';

        -- Calcular subtotais (comida e bebida) e IVA
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
        DECLARE @qtd           INT,
                @preco_unit    DECIMAL(10,2),
                @perc_iva      DECIMAL(5,2),
                @tipo_item     VARCHAR(10);

        FETCH NEXT FROM itens_cursor
        INTO @qtd, @preco_unit, @perc_iva, @tipo_item;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @total_linha = @qtd * @preco_unit;
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
            INTO @qtd, @preco_unit, @perc_iva, @tipo_item;
        END

        CLOSE itens_cursor;
        DEALLOCATE itens_cursor;

        DECLARE @total_geral DECIMAL(14,2) = @subtotal_comida + @subtotal_bebida + @iva_comida + @iva_bebida;

        -- Inserir registro de fatura
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
            @cliente_id,
            GETDATE(),
            @tipo_fatura,
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

        IF @cliente_id IS NULL
        BEGIN
            -- Caso seja consumidor final sem cadastro, preencher dados genéricos
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
```

> **Observação:** Se for necessário detalhar linhas de fatura, podemos inserir registros na tabela `FaturaItem` após obter o `fatura_id` recém-criado, replicando lógica semelhante.

---

## 10. Plano de Implementação Passo a Passo

Resumo em etapas para que a equipe entregue o banco de dados pronto para uso pela API:

1. **Configuração Inicial do Servidor e Banco de Dados**

   * Criar a instância no SQL Server.
   * Criar o banco de dados (`CREATE DATABASE RestauranteDB;`).
   * Definir usuários, roles e permissões mínimas de acesso (somente SELECT em Views, SPs e Functions para o usuário da API).

2. **Criar Tabelas Base e Relacionamentos**

   * Executar scripts de DDL para as tabelas:

     1. `Categoria`
     2. `Fornecedor`
     3. `Produto`
     4. `Encomenda` e `EncomendaItem`
     5. `MovimentacaoEstoque`
     6. `Prato` e `PratoIngrediente`
     7. `Carreira`
     8. `Funcionario`
     9. `RegistroHoras`
     10. `Mesa`
     11. `Cliente`
     12. `Reserva` (se aplicável)
     13. `Pedido` e `PedidoItem`
     14. `Fatura` e `FaturaItem`
     15. `MenuEspecial` e `MenuEspecialPrato`
   * Garantir criação de chaves estrangeiras e índices primários conforme definido.

3. **Implementar Funções de Cálculo**

   * Criar Functions:

     * `fn_calcular_vencimentos_mes_ano`
     * `fn_valores_gastos_stock_mes_ano`
     * `fn_calcular_total_faturado`
     * `fn_produtos_abaixo_stock_minimo`
     * `fn_calcular_horas_trabalhadas`
   * Testar cada Function isoladamente, fornecendo valores de parâmetros e verificando retornos.

4. **Criar Views de Consulta**

   * Executar scripts para Views:

     * `view_mesas_disponiveis`
     * `view_pedidos_em_andamento`
     * `view_estoque_ingredientes`
     * `view_faturamento_periodo`
     * `view_horas_funcionario`
     * `view_clientes_frequentes`
     * `view_pratos_populares`
     * `view_fornecedores_entregas`
     * `view_promocoes_ativas`
     * `view_reservas_ativas` (opcional)
   * Validar se cada View retorna os dados esperados com SELECT simples.

5. **Criar Materialized Views (Indexed Views)**

   * Script para `mv_estoque_utilizado_periodo` com índice clusterizado.
   * Criar View auxiliar `view_estoque_utilizado_detalhado` com índice não clusterizado em `nome_produto`.
   * Ajustar políticas de atualização (rebuild) das Indexed Views se necessário.

6. **Criar Stored Procedures**

   * Implementar SPs de leitura parametrizada:

     * `sp_obter_mesas_disponiveis`
     * `sp_obter_pedidos_por_funcionario`
     * `sp_obter_estoque_ingrediente`
     * `sp_obter_faturamento_por_periodo`
     * `sp_obter_horas_trabalhadas`
     * `sp_obter_clientes_frequentes`
     * `sp_obter_pratos_populares`
     * `sp_obter_entregas_fornecedor`
     * `sp_obter_promocoes_ativas`
     * `sp_obter_reservas_ativas` (se implementado)
     * `sp_obter_faturamento_por_categoria`
   * Testar cada SP com EXEC e checar se retornam os resultados esperados.

7. **Criar Procedimentos Auxiliares para Triggers**

   * `sp_abatimento_estoque_pedidoitem`
   * `sp_atualizar_stock_produto`
   * Outras procedures de apoio necessárias para separar lógica de triggers.

8. **Criar Triggers**

   * `trg_abatimento_estoque_quando_inserir_pedidoitem`
   * `trg_atualizar_stock_e_verificar_minimo`
   * `trg_receber_encomenda`
   * `trg_gerar_fatura_ao_finalizar_pedido`
   * (Opcional) `trg_reverter_abatimento_ao_cancelar_pedido`
   * Verificar comportamento em ambiente de testes: inserir pedidos, cancelar, receber encomenda, finalizar pedido e checar resultados.

9. **Criar Índices Adicionais e Estatísticas**

   * Índice não clusterizado sobre `Produto(stock_atual)` para consultas de alerta de estoque.
   * Índice sobre `Pedido(status)` para filtrar estados.
   * Índice sobre `Fatura(data_emissao)`.
   * Manter estatísticas atualizadas para performance (periodicamente rodar `UPDATE STATISTICS`).

10. **Carga Inicial de Dados de Referência (Seed)**

    * Inserir registros de **Categoria** (Carnes, Peixes, Massas, Sobremesas, Bebidas).
    * Inserir registros de **Carreira** com níveis salariais.
    * Inserir algum **Fornecedor** e **Produto** base (para testes de estoque).
    * Inserir usuários funcionais de teste (Funcionários, Mesa, Cliente).

11. **Configurar Segurança e Permissões**

    * Criar **Login/Usuário** destinado à API, com permissão EXCLUSIVA de `EXECUTE` em SPs e Functions, e `SELECT` nas Views.
    * Revogar permissões diretas de `INSERT/UPDATE/DELETE` em tabelas para esse usuário.
    * Configurar roles de leitura/consulta (`db_datareader` restrito a Views).

12. **Testes de Integração**

    * Simular fluxo completo:

      1. **Criação de Pedido** → verifica abatimento de estoque via Trigger → checa se stock\_atual foi atualizado.
      2. **Pedido finalizado** → Trigger gera Fatura automaticamente → validar cálculos de IVA e totais.
      3. **Estoque abaixo do mínimo** → Trigger deveria gerar nova Encomenda → checar Encomenda e item com quantidade correta.
      4. **Recebimento de Encomenda** → Trigger de entrada atualiza o stock\_ atual dos produtos.
      5. **Registro Horas** → testar cálculo de vencimentos via Function `fn_calcular_vencimentos_mes_ano`.
      6. **Consulta via API** → chamar SPs e Views e validar retornos (Mesas disponíveis, Pedidos em Andamento, Faturamento, etc.).

13. **Documentação Final**

    * Registrar todos os scripts de DDL (tabelas, índices, constraints).
    * Registrar scripts de criação de objetos (Views, MV, Functions, SPs, Triggers).
    * Manual de uso da API, mencionando quais SPs e Views estão disponíveis, parâmetros esperados e formato de retorno.
    * Expor diagrama de entidade-relacionamento (ER) para referência.

14. **Deploy em Produção**

    * Planejar janela de manutenção para deploy.
    * Backup completo do banco de dados pré-existentes (se houver).
    * Executar scripts de criação em ambiente de produção.
    * Validar acesso de API em produção com usuário restrito.
    * Configurar jobs de manutenção (rebuild de índices, atualização de estatísticas, refresh de materialized views se necessário).

---

## 11. Considerações e Boas Práticas

* **Separação de Ambientes**: mantenha ambientes de Desenvolvimento, Homologação/QA e Produção, com scripts versionados em controle de versão (Git).
* **Naming Conventions**: adote convenções claras para nomes de objetos (prefixos “tbl\_” para tabelas, “vw\_” para views, “sp\_” para procedures, “fn\_” para functions, “trg\_” para triggers).
* **Manutenção de Materialized Views**: no SQL Server, Indexed Views não exigem refresh manual, mas lembre-se de manter a opção `SCHEMABINDING`. Para relatórios mais flexíveis (com parâmetros de data), utilize Stored Procedures que filtram a Indexed View.
* **Transações e Locking**: triggers devem ser concisos e evitar loops extensos. Se muitas linhas forem afetadas, avalie a performance e possíveis deadlocks.
* **Segurança de Dados**: conceda ao usuário da API somente permissão de execução de SPs/Functions e SELECT limitado às Views. Phases de OAuth ou JWT podem autenticar chamadas API.
* **Auditoria (Opcional)**: se for necessária auditoria de alterações (quem alterou e quando), implemente tabelas de log e triggers de INSERT/UPDATE/DELETE que gravem em tabelas de histórico.
* **Controle de Versão**: registre cada alteração no schema em arquivos de migração (por exemplo, usando ferramentas como Flyway ou SQL Server Data Tools).

---

## 12. Exemplo de Diagrama de Fluxo de Dados (Processos Críticos)

Para auxiliar no entendimento do fluxo, aqui está um resumo de processos críticos:

1. **Entrada de Pedido (PedidoItem)**

   * Usuário da aplicação insere registro em `PedidoItem` (via aplicação back-office).
   * **Trigger**: `trg_abatimento_estoque_quando_inserir_pedidoitem` → chama `sp_abatimento_estoque_pedidoitem`.
   * `sp_abatimento_estoque_pedidoitem` insere em `MovimentacaoEstoque (tipo='saida')` para cada ingrediente ou item.
   * **Trigger**: `trg_atualizar_stock_e_verificar_minimo` → atualiza `Produto.stock_atual` e, se baixo, cria `Encomenda` automática.

2. **Finalização de Pedido (Pedido.status → 'finalizado')**

   * **Trigger**: `trg_gerar_fatura_ao_finalizar_pedido` → calcula subtotais, IVA e insere em `Fatura`.
   * Opcional: gera registros em `FaturaItem` para detalhamento.

3. **Recebimento de Encomenda (Encomenda.status → 'recebida')**

   * **Trigger**: `trg_receber_encomenda` → insere `MovimentacaoEstoque (tipo='entrada')` para cada `EncomendaItem` e recalcula `Produto.stock_atual`.

4. **Cálculo de Vencimentos**

   * A cada mês, rotina de back-office executa SP que chama `fn_calcular_vencimentos_mes_ano(@ano, @mes)` e grava resultados em relatório ou tabela de `Vencimentos` (caso queira armazenar histórico).

5. **Relatórios / Consultas via API**

   * API executa SPs ou SELECT sobre Views para apresentar:

     * Mesas disponíveis (`sp_obter_mesas_disponiveis`).
     * Pedidos em andamento (`view_pedidos_em_andamento`).
     * Estoque atual e alertas (`view_estoque_ingredientes` / `sp_alerta_estoque`).
     * Faturamento por período (`sp_obter_faturamento_por_periodo` ou `view_faturamento_periodo`).
     * Horas trabalhadas e custo de mão de obra (`sp_obter_horas_trabalhadas` / `fn_calcular_vencimentos_mes_ano`).
     * Consumo de estoque por período (`sp_get_estoque_utilizado` lendo da MV).
     * Clientes frequentes, pratos populares, entregas de fornecedores, promoções ativas, reservas, faturamento por categoria etc.

---

## 13. Conclusão

Este plano de desenvolvimento organiza, em etapas claras, a criação do banco de dados para gestão de restaurante, cobrindo:

* **Modelagem**: entidades, relacionamentos, definições de colunas e tipos.
* **Objetos de Consumo**: Views, Materialized Views (Indexed Views), Functions, Stored Procedures.
* **Triggers**: automatizando controle de estoque, geração de encomendas e faturas.
* **Índices**: para otimizar consultas críticas.
* **Plano de Implementação**: passo a passo desde a criação das tabelas até testes finais.

Seguindo este guia, a equipe poderá implementar o sistema de forma padronizada, garantindo que a API tenha acesso seguro e performático aos dados necessários para os casos de uso dos funcionários no dia a dia. Fica aberto espaço para ajustes específicos conforme necessidades futuros (e.g., auditoria, relatórios personalizados, futuras integrações).

