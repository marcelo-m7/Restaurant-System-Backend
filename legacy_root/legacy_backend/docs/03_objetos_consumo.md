### `BotecoPro/docs/03_objetos_consumo.md`

# 03. Objetos de Consumo para Boteco Pro

---

## 1. Visão Geral

Este documento lista todas as Views, Materialized Views, Functions e Stored Procedures que a API poderá consumir para realizar consultas (apenas `SELECT` ou `EXECUTE`). Não há acesso direto de inserção/atualização/deleção nesses objetos—todos os dados são alterados via triggers ou processos internos.

---

## 2. Views (Consultas Pré-definidas)

1. **view_mesas_disponiveis**  
   - Retorna todas as mesas cujo status = 'livre'.

2. **view_pedidos_em_andamento**  
   - Retorna pedidos com status em ('pendente','em_preparo').

3. **view_estoque_ingredientes**  
   - Exibe produtos do tipo 'ingrediente' com `stock_atual` e `stock_minimo`.

4. **view_faturamento_periodo**  
   - Agrupa faturamento por ano e mês (`YEAR(data_emissao)`, `MONTH(data_emissao)`).

5. **view_horas_funcionario**  
   - Soma horas_normais e horas_extra por funcionário.

6. **view_clientes_frequentes**  
   - Lista clientes ordenados por quantidade de pedidos.

7. **view_pratos_populares**  
   - Lista pratos ordenados por quantidade total vendida.

8. **view_fornecedores_entregas**  
   - Exibe fornecedores e total de encomendas recebidas.

9. **view_promocoes_ativas**  
   - Menus especiais cujo período inclui a data atual.

10. **view_reservas_ativas** *(se implementado)*  
    - Retorna reservas ativas, futuras, por cliente e mesa.

---

## 3. Materialized Views / Indexed Views

1. **mv_estoque_utilizado_periodo**  
   - Lista, agrupado por produto_id, a soma de `quantidade` (tipo='saida') e datas mínimas/máximas de movimentação.

2. **view_estoque_utilizado_detalhado**  
   - View sobre `mv_estoque_utilizado_periodo` unida com `Produto`, exibindo `nome_produto`.

---

## 4. Functions

### 4.1. Scalar Functions

1. `fn_calcular_vencimentos_mes_ano(ano INT, mes INT) RETURNS DECIMAL(14,2)`  
   - Retorna total de gastos em vencimentos em dado mês/ano, considerando salários e horas-extra.

2. `fn_calcular_total_faturado(data_inicio DATE, data_fim DATE) RETURNS DECIMAL(14,2)`  
   - Retorna soma de `Fatura.total` entre duas datas.

3. `fn_calcular_horas_trabalhadas(funcionario_id INT, data_inicio DATE, data_fim DATE) RETURNS DECIMAL(10,2)`  
   - Retorna soma de horas_normais + horas_extra para funcionário no período.

### 4.2. Table-Valued Functions

1. `fn_valores_gastos_stock_mes_ano(ano INT, mes INT) RETURNS TABLE(produto_id INT, nome_produto VARCHAR, valor_gasto NUMERIC)`  
   - Retorna gasto em estoque (tipo='saida') por produto em dado mês/ano.

2. `fn_produtos_abaixo_stock_minimo() RETURNS TABLE(produto_id INT, nome VARCHAR, stock_atual INT, stock_minimo INT)`  
   - Lista produtos cujo `stock_atual` < `stock_minimo` (alerta de reabastecimento).

---

## 5. Stored Procedures (SPs)

Todas recebem parâmetros quando necessário e devolvem resultados via SELECT. A API deverá chamar via `EXEC sp_nome @param`.

1. **sp_obter_mesas_disponiveis()**  
   - SELECT * FROM view_mesas_disponiveis.

2. **sp_obter_pedidos_por_funcionario(@funcionario_id INT)**  
   - SELECT * FROM Pedido WHERE funcionario_id = @funcionario_id 
     AND status NOT IN('finalizado','cancelado').

3. **sp_obter_estoque_ingrediente(@ingrediente_id INT)**  
   - SELECT campos de Produto WHERE produto_id = @ingrediente_id AND tipo = 'ingrediente'.

4. **sp_obter_faturamento_por_periodo(@data_inicio DATE, @data_fim DATE)**  
   - Retorna total de faturamento usando `fn_calcular_total_faturado`.

5. **sp_obter_horas_trabalhadas(@funcionario_id INT, @data_inicio DATE, @data_fim DATE)**  
   - Retorna total de horas usando `fn_calcular_horas_trabalhadas`.

6. **sp_obter_clientes_frequentes()**  
   - SELECT * FROM view_clientes_frequentes.

7. **sp_obter_pratos_populares()**  
   - SELECT * FROM view_pratos_populares.

8. **sp_obter_entregas_fornecedor(@fornecedor_id INT)**  
   - SELECT encomendas recebidas para dado fornecedor.

9. **sp_obter_promocoes_ativas()**  
   - SELECT * FROM view_promocoes_ativas.

10. **sp_obter_reservas_ativas()** *(se implementado)*  
    - SELECT * FROM view_reservas_ativas.

11. **sp_obter_faturamento_por_categoria()**  
    - Agrupa faturamento (PedidoItem × Prato × Categoria).

---

## 6. Sequência de Execução pela API

1. **Listar mesas livres:**  
   ```sql
   EXEC sp_obter_mesas_disponiveis;
    ````

2. **Listar pedidos em andamento:**

   ```sql
   SELECT * FROM view_pedidos_em_andamento;
   ```
3. **Verificar estoque de um ingrediente:**

   ```sql
   EXEC sp_obter_estoque_ingrediente @ingrediente_id = 42;
   ```
4. **Consultar faturamento entre datas:**

   ```sql
   EXEC sp_obter_faturamento_por_periodo @data_inicio='2025-05-01', @data_fim='2025-05-31';
   ```
5. **Consultar horas de um funcionário no mês:**

   ```sql
   EXEC sp_obter_horas_trabalhadas @funcionario_id=7, @data_inicio='2025-05-01', @data_fim='2025-05-31';
   ```
6. **Obter clientes frequentes:**

   ```sql
   EXEC sp_obter_clientes_frequentes;
   ```
7. **Obter pratos mais vendidos:**

   ```sql
   EXEC sp_obter_pratos_populares;
   ```
8. **Verificar produtos abaixo do estoque mínimo:**

   ```sql
   SELECT * FROM fn_produtos_abaixo_stock_minimo();
   ```
9. **Obter consumo de estoque no mês:**

   ```sql
   SELECT * FROM fn_valores_gastos_stock_mes_ano(2025, 5);
   ```
10. **Listar promoções ativas:**

    ```sql
    EXEC sp_obter_promocoes_ativas;
    ```

---

## 7. Observações Finais

* A API **não deve** fazer `INSERT`, `UPDATE` ou `DELETE` diretamente nas tabelas.
* Todas as alterações de estado (nova movimentação de estoque, finalização de pedido, recebimento de encomenda) são conduzidas por **triggers** ou processos internos.
* Se houver necessidade de relatórios parametrizados com filtro de período (por exemplo, `mv_estoque_utilizado_periodo`), crie SPs que aceitem datas e façam `WHERE` sobre a Indexed View.
* Caso seja necessário auditoria, mantenha tabelas de log separadas com triggers de INSERT/UPDATE/DELETE.

Este conjunto de objetos possibilita que a API do Boteco Pro forneça aos funcionários e gestores todas as informações de que precisam para operar e analisar o restaurante, sem expor lógica de negócio diretamente na aplicação cliente.

