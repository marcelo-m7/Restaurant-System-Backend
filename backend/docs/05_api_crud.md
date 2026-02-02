# Boteco Pro API – Entidades e Atributos

---

## 1. Introdução

Este README descreve as principais **entidades** disponíveis na API do Boteco Pro, com seus **atributos** (campos) e como cada objeto (Stored Procedure, View ou Function) deve ser consumido pelo front-end. Ao final, há uma tabela-resumo com todos os objetos expostos pela API e os parâmetros ou colunas que cada um disponibiliza.

---

## 2. Entidades e Atributos

Cada entidade listada abaixo corresponde a uma tabela do banco de dados, mas _a aplicação front-end interage apenas via_:

- **Stored Procedures** (SPs) para criar, atualizar ou excluir registros.  
- **Views** para listar ou filtrar dados.  
- **Functions** para cálculos específicos (valores agregados).

Para cada entidade, são apresentados:

1. **Nome da Entidade**  
2. **Atributos / Campos**  
3. **Objetos de API** (SPs/Views/Functions) que retornam ou manipulam esses atributos.

---

### 2.1. Cliente

**Atributos**:

| Atributo       | Tipo       | Descrição                                        |
| -------------- | ---------- | ------------------------------------------------ |
| `cliente_id`   | INT        | Identificador único (gerado por `sp_cadastrar_cliente`) |
| `nome`         | VARCHAR    | Nome completo do cliente                          |
| `telefone`     | VARCHAR    | Número de telefone (opcional)                     |
| `email`        | VARCHAR    | Endereço de e-mail (opcional)                     |
| `morada`       | VARCHAR    | Endereço completo (opcional)                      |
| `cidade`       | VARCHAR    | Cidade (opcional)                                 |
| `codigo_postal`| VARCHAR    | Código Postal (opcional)                          |
| `contribuinte` | VARCHAR    | Número de contribuinte (opcional)                 |

**Objetos de API**:

- **Criar Cliente**:  
  - `sp_cadastrar_cliente(@nome, @telefone, @email, @morada, @cidade, @codigo_postal, @contribuinte)` → retorna `cliente_id`
- **Atualizar Cliente**:  
  - `sp_atualizar_cliente(@cliente_id, @nome, @telefone, @email, @morada, @cidade, @codigo_postal, @contribuinte)`  
- **Excluir Cliente**:  
  - `sp_excluir_cliente(@cliente_id)`  
- **Consultar Cliente** (por ID):  
  - _opcional:_ `sp_obter_cliente_por_id(@cliente_id)` ou `SELECT * FROM Cliente WHERE cliente_id = ?`  

---

### 2.2. Mesa

**Atributos**:

| Atributo     | Tipo      | Descrição                                      |
| ------------ | --------- | ---------------------------------------------- |
| `mesa_id`    | INT       | Identificador único (gerado por `sp_cadastrar_mesa`) |
| `numero`     | INT       | Número físico da mesa                          |
| `capacidade` | INT       | Quantidade máxima de pessoas                   |
| `status`     | VARCHAR   | `'livre'`, `'ocupada'` ou `'reservada'`       |

**Objetos de API**:

- **Criar Mesa**:  
  - `sp_cadastrar_mesa(@numero, @capacidade)` → retorna `mesa_id`
- **Atualizar Mesa**:  
  - `sp_atualizar_mesa(@mesa_id, @numero, @capacidade, @status)`
- **Excluir Mesa**:  
  - `sp_excluir_mesa(@mesa_id)`
- **Listar Mesas Livres**:  
  - `SELECT * FROM view_mesas_disponiveis`  
- **Consultar Todas as Mesas** (opcional):  
  - `SELECT * FROM Mesa`

---

### 2.3. Carreira

**Atributos**:

| Atributo         | Tipo      | Descrição                                      |
| ---------------- | --------- | ---------------------------------------------- |
| `carreira_id`    | INT       | Identificador único (gerado por `sp_cadastrar_carreira`) |
| `nome`           | VARCHAR   | Nome da carreira (e.g., “Cozinheiro Chefe”)    |
| `salario_mensal` | DECIMAL   | Valor fixo mensal associado                    |

**Objetos de API**:

- **Criar Carreira**:  
  - `sp_cadastrar_carreira(@nome, @salario_mensal)` → retorna `carreira_id`
- **Atualizar Carreira**:  
  - `sp_atualizar_carreira(@carreira_id, @nome, @salario_mensal)`
- **Excluir Carreira**:  
  - `sp_excluir_carreira(@carreira_id)`
- **Listar Carreiras** (opcional):  
  - `SELECT * FROM Carreira`

---

### 2.4. Funcionário

**Atributos**:

| Atributo         | Tipo       | Descrição                                         |
| ---------------- | ---------- | ------------------------------------------------- |
| `funcionario_id` | INT        | Identificador único (gerado por `sp_cadastrar_funcionario`) |
| `nome`           | VARCHAR    | Nome completo                                      |
| `data_nascimento`| DATE       | Data de nascimento (opcional)                       |
| `telefone`       | VARCHAR    | Telefone de contato (opcional)                      |
| `email`          | VARCHAR    | E-mail de contato (opcional)                        |
| `cargo`          | VARCHAR    | Descrição do cargo (e.g., “Empregado de Mesa”)      |
| `carreira_id`    | INT        | Chave estrangeira para `Carreira`                   |
| `data_admissao`  | DATE       | Data de admissão no restaurante                      |

**Objetos de API**:

- **Criar Funcionário**:  
  - `sp_cadastrar_funcionario(@nome, @data_nascimento, @telefone, @email, @cargo, @carreira_id, @data_admissao)` → retorna `funcionario_id`
- **Atualizar Funcionário**:  
  - `sp_atualizar_funcionario(@funcionario_id, @nome, @data_nascimento, @telefone, @email, @cargo, @carreira_id)`
- **Excluir Funcionário**:  
  - `sp_excluir_funcionario(@funcionario_id)`
- **Listar Funcionários**:  
  - `SELECT * FROM Funcionario`
- **Consultar Horas Trabalhadas**:  
  - `sp_obter_horas_trabalhadas(@funcionario_id, @data_inicio, @data_fim)`

---

### 2.5. Fornecedor

**Atributos**:

| Atributo         | Tipo      | Descrição                                           |
| ---------------- | --------- | --------------------------------------------------- |
| `fornecedor_id`  | INT       | Identificador único (gerado por `sp_cadastrar_fornecedor`) |
| `nome`           | VARCHAR   | Nome da empresa-fornecedor                           |
| `telefone`       | VARCHAR   | Telefone de contato (opcional)                       |
| `email`          | VARCHAR   | E-mail de contato (opcional)                         |
| `endereco`       | VARCHAR   | Endereço completo (opcional)                         |
| `cidade`         | VARCHAR   | Cidade (opcional)                                    |
| `codigo_postal`  | VARCHAR   | Código Postal (opcional)                             |
| `pais`           | VARCHAR   | País (opcional)                                      |

**Objetos de API**:

- **Criar Fornecedor**:  
  - `sp_cadastrar_fornecedor(@nome, @telefone, @email, @endereco, @cidade, @codigo_postal, @pais)` → retorna `fornecedor_id`
- **Atualizar Fornecedor**:  
  - `sp_atualizar_fornecedor(@fornecedor_id, @nome, @telefone, @email, @endereco, @cidade, @codigo_postal, @pais)`
- **Excluir Fornecedor**:  
  - `sp_excluir_fornecedor(@fornecedor_id)`
- **Listar Fornecedores**:  
  - `SELECT * FROM Fornecedor`
- **Consultar Entregas**:  
  - `sp_obter_entregas_fornecedor(@fornecedor_id)`

---

### 2.6. Produto

**Atributos**:

| Atributo          | Tipo       | Descrição                                             |
| ----------------- | ---------- | ----------------------------------------------------- |
| `produto_id`      | INT        | Identificador único (gerado por `sp_cadastrar_produto`) |
| `nome`            | VARCHAR    | Nome do produto (e.g., “Batata”, “Cerveja”)           |
| `tipo`            | VARCHAR    | `'ingrediente'`, `'bebida'` ou `'sobremesa'`          |
| `custo_unitario`  | DECIMAL    | Custo de aquisição (para cálculo de valor gasto)      |
| `preco_venda`     | DECIMAL    | Preço de venda ao cliente                              |
| `stock_atual`     | INT        | Quantidade disponível em estoque (mantido por triggers) |
| `stock_minimo`    | INT        | Limite mínimo para acionamento automático de compra    |
| `stock_encomenda` | INT        | Quantidade-alvo para repor estoque quando abaixo do mínimo |
| `fornecedor_id`   | INT        | FK para `Fornecedor`                                   |

**Objetos de API**:

- **Criar Produto**:  
  - `sp_cadastrar_produto(@nome, @tipo, @custo_unitario, @preco_venda, @stock_atual, @stock_minimo, @stock_encomenda, @fornecedor_id)` → retorna `produto_id`
- **Atualizar Produto**:  
  - `sp_atualizar_produto(@produto_id, @nome, @tipo, @custo_unitario, @preco_venda, @stock_minimo, @stock_encomenda, @fornecedor_id)`
- **Excluir Produto**:  
  - `sp_excluir_produto(@produto_id)`
- **Listar Ingredientes**:  
  - `SELECT * FROM view_estoque_ingredientes`
- **Consultar Estoque em Período**:  
  - `SELECT * FROM view_estoque_utilizado_detalhado` (filtrar por `produto_id` ou intervalo de datas)
- **Consultar Produtos Abaixo do Mínimo**:  
  - `SELECT * FROM fn_produtos_abaixo_stock_minimo()`

---

### 2.7. Prato

**Atributos**:

| Atributo         | Tipo       | Descrição                                             |
| ---------------- | ---------- | ----------------------------------------------------- |
| `prato_id`       | INT        | Identificador único (gerado por `sp_cadastrar_prato`)  |
| `nome`           | VARCHAR    | Nome do prato (e.g., “Bife à Portuguesa”)             |
| `categoria_id`   | INT        | FK para `Categoria`                                    |
| `descricao`       | VARCHAR    | Descrição breve do prato                              |
| `tempo_preparo`  | INT        | Tempo de preparo em minutos                            |
| `preco_base`     | DECIMAL    | Custo-base considerado no cálculo do preço de venda    |

**Objetos de API**:

- **Criar Prato**:  
  - `sp_cadastrar_prato(@nome, @categoria_id, @descricao, @tempo_preparo, @preco_base)` → retorna `prato_id`
- **Atualizar Prato**:  
  - `sp_atualizar_prato(@prato_id, @nome, @categoria_id, @descricao, @tempo_preparo, @preco_base)`
- **Excluir Prato**:  
  - `sp_excluir_prato(@prato_id)`
- **Listar Pratos**:  
  - `SELECT * FROM Prato`  
- **Vincular Ingrediente**:  
  - `sp_cadastrar_prato_ingrediente(@prato_id, @produto_id, @quantidade_necessaria)`
- **Remover Ingrediente**:  
  - `sp_remover_prato_ingrediente(@prato_id, @produto_id)`

---

### 2.8. MenuEspecial

**Atributos**:

| Atributo           | Tipo       | Descrição                                                   |
| ------------------ | ---------- | ----------------------------------------------------------- |
| `menu_especial_id` | INT        | Identificador único (gerado por `sp_cadastrar_menu_especial`) |
| `nome`             | VARCHAR    | Nome do menu especial (e.g., “Menu Dia dos Namorados”)      |
| `descricao`        | VARCHAR    | Texto descritivo (opcional)                                  |
| `data_inicio`      | DATE       | Data de início da vigência                                   |
| `data_fim`         | DATE       | Data de término da vigência                                   |
| `preco_total`      | DECIMAL    | Preço fechado para o conjunto de pratos                       |

**Objetos de API**:

- **Criar MenuEspecial**:  
  - `sp_cadastrar_menu_especial(@nome, @descricao, @data_inicio, @data_fim, @preco_total)` → retorna `menu_especial_id`
- **Atualizar MenuEspecial**:  
  - `sp_atualizar_menu_especial(@menu_especial_id, @nome, @descricao, @data_inicio, @data_fim, @preco_total)`
- **Excluir MenuEspecial**:  
  - `sp_excluir_menu_especial(@menu_especial_id)`
- **Listar Menus Ativos**:  
  - `SELECT * FROM view_promocoes_ativas`
- **Vincular Prato**:  
  - `sp_cadastrar_menu_especial_prato(@menu_especial_id, @prato_id, @ordem)`
- **Remover Vínculo**:  
  - `sp_remover_menu_especial_prato(@menu_especial_id, @prato_id)`

---

### 2.9. Reserva

**Atributos**:

| Atributo            | Tipo      | Descrição                                                      |
| ------------------- | --------- | -------------------------------------------------------------- |
| `reserva_id`        | INT       | Identificador único (gerado por `sp_cadastrar_reserva`)         |
| `cliente_id`        | INT       | FK para `Cliente`                                               |
| `mesa_id`           | INT       | FK para `Mesa`                                                  |
| `data_reserva`      | DATE      | Dia reservado                                                  |
| `hora_reserva`      | TIME      | Horário reservado                                              |
| `quantidade_pessoas`| INT       | Número de pessoas alocadas                                      |
| `status`            | VARCHAR   | `'ativa'`, `'confirmada'` ou `'cancelada'`                     |

**Objetos de API**:

- **Criar Reserva**:  
  - `sp_cadastrar_reserva(@cliente_id, @mesa_id, @data_reserva, @hora_reserva, @quantidade_pessoas)` → retorna `reserva_id`
- **Atualizar Reserva**:  
  - `sp_atualizar_reserva(@reserva_id, @mesa_id, @data_reserva, @hora_reserva, @quantidade_pessoas, @status)`
- **Listar Reservas Ativas**:  
  - `SELECT * FROM view_reservas_ativas`
- **Cancelar Reserva**:  
  - ajuste via `sp_atualizar_reserva(@reserva_id, status='cancelada')`

---

### 2.10. Pedido

**Atributos**:

| Atributo         | Tipo       | Descrição                                                       |
| ---------------- | ---------- | --------------------------------------------------------------- |
| `pedido_id`      | INT        | Identificador único (gerado por `sp_cadastrar_pedido`)            |
| `mesa_id`        | INT        | FK para `Mesa`                                                   |
| `funcionario_id` | INT        | FK para `Funcionario`                                            |
| `cliente_id`     | INT (NULL) | FK para `Cliente` (NULL se houver “consumidor final”)            |
| `data_pedido`    | DATETIME   | Timestamp de criação (automático)                                |
| `status`         | VARCHAR    | `'pendente'`, `'em_preparo'`, `'pronto'`, `'entregue'`, `'finalizado'`, `'cancelado'` |

**Objetos de API**:

- **Criar Pedido**:  
  - `sp_cadastrar_pedido(@mesa_id, @funcionario_id, @cliente_id)` → retorna `pedido_id`
- **Atualizar Status do Pedido**:  
  - `sp_atualizar_status_pedido(@pedido_id, @status)`
- **Cancelar Pedido**:  
  - `sp_cancelar_pedido(@pedido_id)`  
- **Excluir Pedido**:  
  - `sp_excluir_pedido(@pedido_id)`  
- **Listar Pedidos em Andamento**:  
  - `SELECT * FROM view_pedidos_em_andamento`
- **Obter Pedido por ID**:  
  - criar `sp_obter_pedido_por_id(@pedido_id)` se necessário

---

### 2.11. PedidoItem

**Atributos**:

| Atributo         | Tipo      | Descrição                                                        |
| ---------------- | --------- | ---------------------------------------------------------------- |
| `pedido_item_id` | INT       | Identificador único (gerado no INSERT)                           |
| `pedido_id`      | INT       | FK para `Pedido`                                                  |
| `prato_id`       | INT (NULL)| FK para `Prato` (NULL se for produto avulso)                      |
| `produto_id`     | INT (NULL)| FK para `Produto` (NULL se for prato)                             |
| `quantidade`     | INT       | Quantidade solicitada                                            |
| `preco_unitario` | DECIMAL   | Preço unitário de venda                                           |
| `iva`            | DECIMAL   | Percentual de IVA (13.00 para comida, 23.00 para bebida)         |

**Objetos de API**:

- **Adicionar Item ao Pedido**:  
  - `sp_adicionar_item_pedido(@pedido_id, @prato_id, @produto_id, @quantidade, @preco_unitario, @iva)`
- **Remover Item do Pedido**:  
  - `sp_remover_item_pedido(@pedido_item_id)`

---

### 2.12. Encomenda

**Atributos**:

| Atributo         | Tipo       | Descrição                                                      |
| ---------------- | ---------- | -------------------------------------------------------------- |
| `encomenda_id`   | INT        | Identificador único (gerado por `sp_cadastrar_encomenda`)        |
| `fornecedor_id`  | INT        | FK para `Fornecedor`                                            |
| `data_encomenda` | DATETIME   | Timestamp de criação (automático)                                |
| `status`         | VARCHAR    | `'pendente'`, `'recebida'` ou `'cancelada'`                    |
| `valor_total`    | DECIMAL    | Somatório dos itens (`EncomendaItem`)                            |

**Objetos de API**:

- **Criar Encomenda**:  
  - `sp_cadastrar_encomenda(@fornecedor_id)` → retorna `encomenda_id`
- **Cancelar Encomenda**:  
  - `sp_cancelar_encomenda(@encomenda_id)`  
- **Excluir Encomenda**:  
  - `sp_excluir_encomenda(@encomenda_id)`  
- **Adicionar Item à Encomenda**:  
  - `sp_adicionar_item_encomenda(@encomenda_id, @produto_id, @quantidade, @preco_unitario)`
- **Remover Item da Encomenda**:  
  - `sp_remover_item_encomenda(@encomenda_item_id)`

---

### 2.13. EncomendaItem

**Atributos**:

| Atributo           | Tipo     | Descrição                                                      |
| ------------------ | -------- | -------------------------------------------------------------- |
| `encomenda_item_id`| INT      | Identificador único (gerado no INSERT)                         |
| `encomenda_id`     | INT      | FK para `Encomenda`                                            |
| `produto_id`       | INT      | FK para `Produto`                                              |
| `quantidade`       | INT      | Quantidade encomendada                                         |
| `preco_unitario`   | DECIMAL  | Preço unitário de compra                                       |

**Objetos de API**:

- **Inserir Item de Encomenda**:  
  - `sp_adicionar_item_encomenda(@encomenda_id, @produto_id, @quantidade, @preco_unitario)`

---

### 2.14. MovimentacaoEstoque

**Atributos**:

| Atributo            | Tipo      | Descrição                                                      |
| ------------------- | --------- | -------------------------------------------------------------- |
| `movimentacao_id`   | INT       | Identificador único (gerado no INSERT)                         |
| `produto_id`        | INT       | FK para `Produto`                                              |
| `data_movimentacao` | DATETIME  | Timestamp da movimentação                                      |
| `tipo`              | VARCHAR   | `'entrada'` ou `'saida'`                                       |
| `quantidade`        | DECIMAL   | Quantidade movimentada                                         |
| `preco_unitario`    | DECIMAL   | Custo unitário no momento da movimentação                      |
| `pedido_id`         | INT (NULL)| FK para `Pedido` (NULL se for entrada via `Encomenda`)         |

> **Observação**:  
> - Não exposto diretamente pela API.  
> - As movimentações são geradas automaticamente por triggers ao inserir `PedidoItem` ou atualizar `Encomenda` para `recebida`.  
> - Para consultar, usar Views:  
>   - `view_estoque_ingredientes` (lista níveis atuais)  
>   - `view_estoque_utilizado_detalhado` (consumo em período)  

---

### 2.15. RegistroHoras

**Atributos**:

| Atributo            | Tipo      | Descrição                                                            |
| ------------------- | --------- | -------------------------------------------------------------------- |
| `registro_horas_id` | INT       | Identificador único (gerado por `sp_registrar_horas`)                   |
| `funcionario_id`    | INT       | FK para `Funcionario`                                                 |
| `data_registro`     | DATE      | Data do registro de ponto                                              |
| `horas_normais`     | DECIMAL   | Quantidade de horas normais naquele dia ou período                       |
| `horas_extra`       | DECIMAL   | Quantidade de horas extras naquele dia ou período                        |

**Objetos de API**:

- **Registrar Horas**:  
  - `sp_registrar_horas(@funcionario_id, @data_registro, @horas_normais, @horas_extra)` → retorna `registro_horas_id`
- **Atualizar Registro de Horas**:  
  - `sp_atualizar_registro_horas(@registro_horas_id, @data_registro, @horas_normais, @horas_extra)`
- **Excluir Registro de Horas**:  
  - `sp_excluir_registro_horas(@registro_horas_id)`
- **Consultar Total de Horas**:  
  - `sp_obter_horas_trabalhadas(@funcionario_id, @data_inicio, @data_fim)`

---

### 2.16. Fatura

**Atributos**:

| Atributo           | Tipo       | Descrição                                                              |
| ------------------ | ---------- | ---------------------------------------------------------------------- |
| `fatura_id`        | INT        | Identificador único (gerado automaticamente ao finalizar `Pedido` ou manual via `sp_cadastrar_fatura_manual`) |
| `pedido_id`        | INT        | FK para `Pedido`                                                         |
| `cliente_id`       | INT (NULL) | FK para `Cliente` (NULL se consumidor final)                              |
| `data_emissao`     | DATETIME   | Timestamp de emissão da fatura                                           |
| `tipo_fatura`      | VARCHAR    | `'consumidor_final'` ou `'empresa'`                                       |
| `nome_cliente`     | VARCHAR    | Nome impresso na fatura                                                   |
| `morada_cliente`   | VARCHAR    | Endereço impresso                                                          |
| `cidade_cliente`   | VARCHAR    | Cidade impresso                                                            |
| `codigo_postal`    | VARCHAR    | Código Postal impresso                                                     |
| `contribuinte`     | VARCHAR    | Número de contribuinte impresso                                            |
| `subtotal_comida`  | DECIMAL    | Valor líquido referente apenas aos itens de comida (13% IVA)              |
| `subtotal_bebida`  | DECIMAL    | Valor líquido referente apenas aos itens de bebida (23% IVA)              |
| `iva_comida`       | DECIMAL    | Valor de IVA incidente sobre comidas                                       |
| `iva_bebida`       | DECIMAL    | Valor de IVA incidente sobre bebidas                                       |
| `total`            | DECIMAL    | Valor total da fatura (subtotal + IVA)                                     |

**Objetos de API**:

- **Consultar Fatura por Pedido**:  
  - _opcional:_ `sp_obter_fatura_por_pedido(@pedido_id)` ou `SELECT * FROM Fatura WHERE pedido_id = ?`
- **Criar Fatura Manual** (correções):  
  - `sp_cadastrar_fatura_manual(@pedido_id, @cliente_id, @nome_cliente, @morada_cliente, @cidade_cliente, @codigo_postal, @contribuinte, @subtotal_comida, @subtotal_bebida, @iva_comida, @iva_bebida, @total)` → retorna `fatura_id`
- **Excluir Fatura**:  
  - `sp_excluir_fatura(@fatura_id)`
- **Listar Faturamento por Período**:  
  - `sp_obter_faturamento_por_periodo(@data_inicio, @data_fim)`

---

### 2.17. FaturaItem

**Atributos**:

| Atributo            | Tipo       | Descrição                                                          |
| ------------------- | ---------- | ------------------------------------------------------------------ |
| `fatura_item_id`    | INT        | Identificador único (gerado automaticamente ao inserir fatura)      |
| `fatura_id`         | INT        | FK para `Fatura`                                                     |
| `descricao`         | VARCHAR    | Descrição do item (nome do prato ou produto)                          |
| `quantidade`        | INT        | Quantidade daquele item                                               |
| `preco_unitario`    | DECIMAL    | Preço unitário cobrado                                                |
| `valor_liquido`     | DECIMAL    | Valor total antes de IVA (quantidade × preço_unitario)                |
| `percentual_iva`    | DECIMAL    | Percentual de IVA aplicado (13.00 ou 23.00)                            |
| `valor_iva`         | DECIMAL    | Valor absoluto de IVA (valor_liquido × percentual_iva/100)            |
| `valor_total_linha` | DECIMAL    | Valor_liquido + valor_iva                                              |

**Objetos de API**:

- **Obter Itens de Fatura**:  
  - _opcional:_ `sp_obter_itens_fatura(@fatura_id)` ou `SELECT * FROM FaturaItem WHERE fatura_id = ?`
- **Excluir Item de Fatura**:  
  - `sp_excluir_item_fatura(@fatura_item_id)`

---

## 3. Tabela-Resumo de Objetos (Views, Functions, Stored Procedures)

A tabela abaixo lista, de forma resumida, cada objeto exposto pela API, seu tipo (View/SP/Function) e os parâmetros (ou colunas de saída).  

| **Objeto**                          | **Tipo**       | **Parâmetros / Colunas de Saída**                                                                                                                |
| ----------------------------------- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| `view_mesas_disponiveis`            | View           | **Colunas:** `mesa_id`, `numero`, `capacidade`                                                                                                    |
| `view_pedidos_em_andamento`         | View           | **Colunas:** `pedido_id`, `mesa_id`, `funcionario_id`, `data_pedido`, `status`                                                                    |
| `view_estoque_ingredientes`         | View           | **Colunas:** `produto_id`, `nome_produto`, `stock_atual`, `stock_minimo`                                                                          |
| `view_faturamento_periodo`          | View           | **Colunas:** `ano`, `mes`, `total_faturado`                                                                                                       |
| `view_horas_funcionario`            | View           | **Colunas:** `funcionario_id`, `nome_funcionario`, `total_horas_normais`, `total_horas_extra`                                                      |
| `view_clientes_frequentes`          | View           | **Colunas:** `cliente_id`, `nome_cliente`, `total_pedidos`                                                                                         |
| `view_pratos_populares`             | View           | **Colunas:** `prato_id`, `nome_prato`, `total_vendas`                                                                                              |
| `view_fornecedores_entregas`        | View           | **Colunas:** `fornecedor_id`, `nome_fornecedor`, `total_encomendas_recebidas`                                                                      |
| `view_promocoes_ativas`             | View           | **Colunas:** `menu_especial_id`, `nome_menu`, `data_inicio`, `data_fim`, `preco_total`                                                             |
| `view_reservas_ativas`              | View           | **Colunas:** `reserva_id`, `nome_cliente`, `mesa_id`, `data_reserva`, `hora_reserva`, `quantidade_pessoas`                                        |
| `mv_estoque_utilizado_periodo` (indexed) | Indexed View | **Colunas:** `produto_id`, `quantidade_total`, `data_inicio`, `data_fim`                                                                           |
| `view_estoque_utilizado_detalhado`  | View           | **Colunas:** `produto_id`, `nome_produto`, `quantidade_total`, `data_inicio`, `data_fim`                                                           |
| `fn_calcular_vencimentos_mes_ano`   | Function (Scalar) | **Params:** `@ano INT`, `@mes INT` → **Retorna:** `DECIMAL`                                                                                         |
| `fn_calcular_total_faturado`        | Function (Scalar) | **Params:** `@data_inicio DATE`, `@data_fim DATE` → **Retorna:** `DECIMAL`                                                                          |
| `fn_calcular_horas_trabalhadas`     | Function (Scalar) | **Params:** `@funcionario_id INT`, `@data_inicio DATE`, `@data_fim DATE` → **Retorna:** `DECIMAL`                                                   |
| `fn_valores_gastos_stock_mes_ano`   | Function (TVF) | **Params:** `@ano INT`, `@mes INT` → **Cols:** `produto_id`, `nome_produto`, `valor_gasto`                                                          |
| `fn_produtos_abaixo_stock_minimo`   | Function (TVF) | **Params:** nenhum → **Cols:** `produto_id`, `nome`, `stock_atual`, `stock_minimo`                                                                  |
| `sp_cadastrar_cliente`              | Stored Procedure | **Params:** `@nome VARCHAR`, `@telefone VARCHAR = NULL`, `@email VARCHAR = NULL`, `@morada VARCHAR = NULL`, `@cidade VARCHAR = NULL`, `@codigo_postal VARCHAR = NULL`, `@contribuinte VARCHAR = NULL` <br>**Retorna:** `cliente_id INT` |
| `sp_atualizar_cliente`              | Stored Procedure | **Params:** `@cliente_id INT`, `@nome VARCHAR`, `@telefone VARCHAR = NULL`, `@email VARCHAR = NULL`, `@morada VARCHAR = NULL`, `@cidade VARCHAR = NULL`, `@codigo_postal VARCHAR = NULL`, `@contribuinte VARCHAR = NULL` <br>**Retorna:** `status INT (0=sucesso)` |
| `sp_excluir_cliente`                | Stored Procedure | **Params:** `@cliente_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                              |
| `sp_cadastrar_mesa`                 | Stored Procedure | **Params:** `@numero INT`, `@capacidade INT` → **Retorna:** `mesa_id INT`                                                                            |
| `sp_atualizar_mesa`                 | Stored Procedure | **Params:** `@mesa_id INT`, `@numero INT = NULL`, `@capacidade INT = NULL`, `@status VARCHAR = NULL` → **Retorna:** `status INT (0=sucesso)`          |
| `sp_excluir_mesa`                   | Stored Procedure | **Params:** `@mesa_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                                   |
| `sp_cadastrar_carreira`             | Stored Procedure | **Params:** `@nome VARCHAR`, `@salario_mensal DECIMAL` → **Retorna:** `carreira_id INT`                                                                |
| `sp_atualizar_carreira`             | Stored Procedure | **Params:** `@carreira_id INT`, `@nome VARCHAR = NULL`, `@salario_mensal DECIMAL = NULL` → **Retorna:** `status INT (0=sucesso)`                         |
| `sp_excluir_carreira`               | Stored Procedure | **Params:** `@carreira_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                               |
| `sp_cadastrar_funcionario`          | Stored Procedure | **Params:** `@nome VARCHAR`, `@data_nascimento DATE = NULL`, `@telefone VARCHAR = NULL`, `@email VARCHAR = NULL`, `@cargo VARCHAR`, `@carreira_id INT`, `@data_admissao DATE` → **Retorna:** `funcionario_id INT` |
| `sp_atualizar_funcionario`          | Stored Procedure | **Params:** `@funcionario_id INT`, `@nome VARCHAR = NULL`, `@data_nascimento DATE = NULL`, `@telefone VARCHAR = NULL`, `@email VARCHAR = NULL`, `@cargo VARCHAR = NULL`, `@carreira_id INT = NULL` → **Retorna:** `status INT (0=sucesso)` |
| `sp_excluir_funcionario`            | Stored Procedure | **Params:** `@funcionario_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                            |
| `sp_cadastrar_fornecedor`           | Stored Procedure | **Params:** `@nome VARCHAR`, `@telefone VARCHAR = NULL`, `@email VARCHAR = NULL`, `@endereco VARCHAR = NULL`, `@cidade VARCHAR = NULL`, `@codigo_postal VARCHAR = NULL`, `@pais VARCHAR = NULL` → **Retorna:** `fornecedor_id INT` |
| `sp_atualizar_fornecedor`           | Stored Procedure | **Params:** `@fornecedor_id INT`, `@nome VARCHAR = NULL`, `@telefone VARCHAR = NULL`, `@email VARCHAR = NULL`, `@endereco VARCHAR = NULL`, `@cidade VARCHAR = NULL`, `@codigo_postal VARCHAR = NULL`, `@pais VARCHAR = NULL` → **Retorna:** `status INT (0=sucesso)` |
| `sp_excluir_fornecedor`             | Stored Procedure | **Params:** `@fornecedor_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                             |
| `sp_cadastrar_produto`              | Stored Procedure | **Params:** `@nome VARCHAR`, `@tipo VARCHAR`, `@custo_unitario DECIMAL`, `@preco_venda DECIMAL`, `@stock_atual INT`, `@stock_minimo INT`, `@stock_encomenda INT`, `@fornecedor_id INT` → **Retorna:** `produto_id INT` |
| `sp_atualizar_produto`              | Stored Procedure | **Params:** `@produto_id INT`, `@nome VARCHAR = NULL`, `@tipo VARCHAR = NULL`, `@custo_unitario DECIMAL = NULL`, `@preco_venda DECIMAL = NULL`, `@stock_minimo INT = NULL`, `@stock_encomenda INT = NULL`, `@fornecedor_id INT = NULL` → **Retorna:** `status INT (0=sucesso)` |
| `sp_excluir_produto`                | Stored Procedure | **Params:** `@produto_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                                 |
| `sp_cadastrar_prato`                | Stored Procedure | **Params:** `@nome VARCHAR`, `@categoria_id INT`, `@descricao VARCHAR = NULL`, `@tempo_preparo INT`, `@preco_base DECIMAL` → **Retorna:** `prato_id INT` |
| `sp_atualizar_prato`                | Stored Procedure | **Params:** `@prato_id INT`, `@nome VARCHAR = NULL`, `@categoria_id INT = NULL`, `@descricao VARCHAR = NULL`, `@tempo_preparo INT = NULL`, `@preco_base DECIMAL = NULL` → **Retorna:** `status INT (0=sucesso)` |
| `sp_excluir_prato`                  | Stored Procedure | **Params:** `@prato_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                                  |
| `sp_cadastrar_prato_ingrediente`    | Stored Procedure | **Params:** `@prato_id INT`, `@produto_id INT`, `@quantidade_necessaria DECIMAL` → **Retorna:** `status INT (0=sucesso)`                                   |
| `sp_remover_prato_ingrediente`      | Stored Procedure | **Params:** `@prato_id INT`, `@produto_id INT` → **Retorna:** `status INT (0=sucesso)`                                                             |
| `sp_cadastrar_menu_especial`        | Stored Procedure | **Params:** `@nome VARCHAR`, `@descricao VARCHAR = NULL`, `@data_inicio DATE`, `@data_fim DATE`, `@preco_total DECIMAL` → **Retorna:** `menu_especial_id INT` |
| `sp_atualizar_menu_especial`        | Stored Procedure | **Params:** `@menu_especial_id INT`, `@nome VARCHAR = NULL`, `@descricao VARCHAR = NULL`, `@data_inicio DATE = NULL`, `@data_fim DATE = NULL`, `@preco_total DECIMAL = NULL` → **Retorna:** `status INT (0=sucesso)` |
| `sp_excluir_menu_especial`          | Stored Procedure | **Params:** `@menu_especial_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                        |
| `sp_cadastrar_menu_especial_prato`  | Stored Procedure | **Params:** `@menu_especial_id INT`, `@prato_id INT`, `@ordem INT` → **Retorna:** `status INT (0=sucesso)`                                                |
| `sp_remover_menu_especial_prato`    | Stored Procedure | **Params:** `@menu_especial_id INT`, `@prato_id INT` → **Retorna:** `status INT (0=sucesso)`                                                       |
| `sp_cadastrar_reserva`              | Stored Procedure | **Params:** `@cliente_id INT`, `@mesa_id INT`, `@data_reserva DATE`, `@hora_reserva TIME`, `@quantidade_pessoas INT` → **Retorna:** `reserva_id INT` |
| `sp_atualizar_reserva`              | Stored Procedure | **Params:** `@reserva_id INT`, `@mesa_id INT = NULL`, `@data_reserva DATE = NULL`, `@hora_reserva TIME = NULL`, `@quantidade_pessoas INT = NULL`, `@status VARCHAR = NULL` → **Retorna:** `status INT (0=sucesso)` |
| `sp_cadastrar_pedido`               | Stored Procedure | **Params:** `@mesa_id INT`, `@funcionario_id INT`, `@cliente_id INT = NULL` → **Retorna:** `pedido_id INT`                                         |
| `sp_atualizar_status_pedido`        | Stored Procedure | **Params:** `@pedido_id INT`, `@status VARCHAR` → **Retorna:** `status INT (0=sucesso)`                                                            |
| `sp_cancelar_pedido`                | Stored Procedure | **Params:** `@pedido_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                              |
| `sp_excluir_pedido`                 | Stored Procedure | **Params:** `@pedido_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                              |
| `sp_adicionar_item_pedido`          | Stored Procedure | **Params:** `@pedido_id INT`, `@prato_id INT = NULL`, `@produto_id INT = NULL`, `@quantidade INT`, `@preco_unitario DECIMAL`, `@iva DECIMAL` → **Retorna:** `status INT (0=sucesso)` |
| `sp_remover_item_pedido`            | Stored Procedure | **Params:** `@pedido_item_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                        |
| `sp_cadastrar_encomenda`            | Stored Procedure | **Params:** `@fornecedor_id INT` → **Retorna:** `encomenda_id INT`                                                                                 |
| `sp_cancelar_encomenda`             | Stored Procedure | **Params:** `@encomenda_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                            |
| `sp_excluir_encomenda`              | Stored Procedure | **Params:** `@encomenda_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                            |
| `sp_adicionar_item_encomenda`       | Stored Procedure | **Params:** `@encomenda_id INT`, `@produto_id INT`, `@quantidade INT`, `@preco_unitario DECIMAL` → **Retorna:** `status INT (0=sucesso)`         |
| `sp_remover_item_encomenda`         | Stored Procedure | **Params:** `@encomenda_item_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                       |
| `sp_registrar_horas`                | Stored Procedure | **Params:** `@funcionario_id INT`, `@data_registro DATE`, `@horas_normais DECIMAL`, `@horas_extra DECIMAL` → **Retorna:** `registro_horas_id INT` |
| `sp_atualizar_registro_horas`       | Stored Procedure | **Params:** `@registro_horas_id INT`, `@data_registro DATE = NULL`, `@horas_normais DECIMAL = NULL`, `@horas_extra DECIMAL = NULL` → **Retorna:** `status INT (0=sucesso)` |
| `sp_excluir_registro_horas`         | Stored Procedure | **Params:** `@registro_horas_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                       |
| `sp_obter_horas_trabalhadas`        | Stored Procedure | **Params:** `@funcionario_id INT`, `@data_inicio DATE`, `@data_fim DATE` → **Retorna:** `(funcionario_id, data_inicio, data_fim, total_horas)` |
| `sp_cadastrar_fatura_manual`        | Stored Procedure | **Params:** `@pedido_id INT`, `@cliente_id INT = NULL`, `@nome_cliente VARCHAR = NULL`, `@morada_cliente VARCHAR = NULL`, `@cidade_cliente VARCHAR = NULL`, `@codigo_postal VARCHAR = NULL`, `@contribuinte VARCHAR = NULL`, `@subtotal_comida DECIMAL`, `@subtotal_bebida DECIMAL`, `@iva_comida DECIMAL`, `@iva_bebida DECIMAL`, `@total DECIMAL` → **Retorna:** `fatura_id INT` |
| `sp_excluir_fatura`                 | Stored Procedure | **Params:** `@fatura_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                              |
| `sp_excluir_item_fatura`            | Stored Procedure | **Params:** `@fatura_item_id INT` → **Retorna:** `status INT (0=sucesso)`                                                                         |

---

## 4. Como Consumir estes Objetos na API

- **Views**:  
  - Serão expostas como endpoints de leitura (GET).  
  - Exemplo:  
    ```http
    GET /api/mesas/disponiveis     → executa `SELECT * FROM view_mesas_disponiveis`
    GET /api/pratos/populares       → executa `SELECT * FROM view_pratos_populares`
    ```

- **Functions**:  
  - Utilizadas para cálculo de agregados; chamadas via SELECT ou em SPs de relatório.  
  - Exemplo:  
    ```http
    GET /api/financeiro/faturamento?inicio=2025-06-01&fim=2025-06-30 
      → executa `SELECT fn_calcular_total_faturado('2025-06-01','2025-06-30')`
    ```

- **Stored Procedures**:  
  - Chamadas via EXEC (POST/PUT/DELETE).  
  - Exemplo:  
    ```http
    POST /api/clientes  
      BODY { "nome":"Ana Silva","telefone":"912345111", ... }  
      → executa `EXEC sp_cadastrar_cliente 'Ana Silva','912345111',...`

    PUT /api/clientes/5  
      BODY { "nome":"Ana Silva Santos","telefone":"91xxxxxxx", ... }  
      → executa `EXEC sp_atualizar_cliente 5,'Ana Silva Santos','91xxxxxxx',...`

    DELETE /api/clientes/5  
      → executa `EXEC sp_excluir_cliente 5`
    ```
---

## 5. Conclusão

Este documento apresenta:

1. **Entidades** (classes) com seus atributos e os objetos de API que manipulam esses atributos.  
2. **Tabela-resumo** com todos os objetos disponíveis (Views, Functions e Stored Procedures) e seus parâmetros ou colunas de saída.

Com base neste README, o desenvolvedor front-end poderá mapear cada entidade em suas **models** (por exemplo, em TypeScript ou outra linguagem) e saber exatamente:

- Quais campos estarão presentes ao consumir uma View ou Function.  
- Quais parâmetros devem ser enviados para cada Stored Procedure para criar, atualizar ou excluir registros.  

Dessa forma, garante-se fidelidade ao modelo de dados do Boteco Pro, evitando inconsistências e facilitando manutenções futuras.

