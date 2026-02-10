
**Observações sobre o script de seeds:**

1. **Categorias, Carreiras, Fornecedores, Produtos e Pratos**

   * Insere dados de referência para permitir testes de cadastro, pedidos e faturas.

2. **PratoIngrediente**

   * Vincula ingredientes a cada prato, com quantidade necessária.
   * Ao inserir itens em `PedidoItem`, as triggers criam entradas em `MovimentacaoEstoque` e abatem o `stock_atual` dos produtos.

3. **Mesas e Clientes**

   * Cria algumas mesas livres e clientes de exemplo.
   * Insere reservas para demonstrar `view_reservas_ativas`.

4. **Funcionários e RegistroHoras**

   * Cria funcionários com diferentes carreiras e registra horas trabalhadas de maio/2025 para demonstração da Function `fn_calcular_vencimentos_mes_ano`.

5. **MenuEspecial**

   * Cria um menu para o Dia dos Namorados e vincula alguns pratos ao mesmo.
   * O Café Expresso (produto\_id = 10) pode ser adicionado em `PedidoItem` conforme necessidade.

6. **Pedido e PedidoItem**

   * Insere um pedido “pendente” e alguns itens (prato principal, bebida e sobremesa).
   * As triggers associadas a `PedidoItem` geram movimentações de estoque (tipo = 'saida') e, se o `stock_atual` cair abaixo do `stock_minimo`, automaticamente criam nova `Encomenda`.

7. **Encomendas**

   * Cria uma encomenda manual e, ao marcá-la como “recebida”, dispara o trigger que gera `MovimentacaoEstoque` (tipo = 'entrada') e atualiza o `stock_atual` dos produtos correspondentes.

8. **Ordem de Execução**

   * Execute este script **depois** de ter rodado todos os scripts de criação de tabelas, índices, views, functions, SPs e triggers.
   * As instruções `GO` devem ser mantidas para delimitar batches e ativar triggers corretamente.

9. **Testes de Verificação**

   * Após a execução, você pode consultar:

     ```sql
     -- Verificar estoque atualizado de “Batata” e “Carne de Vaca” (produto_id = 1 e 2)
     SELECT produto_id, nome, stock_atual, stock_minimo
     FROM Produto
     WHERE produto_id IN (1, 2);

     -- Verificar fatura gerada automaticamente para o pedido inserido
     SELECT *
     FROM Fatura
     WHERE pedido_id = @novoPedidoId;  -- utilize o valor retornado no batch anterior

     -- Verificar movimentações de estoque
     SELECT *
     FROM MovimentacaoEstoque
     WHERE produto_id IN (1,2,3,6,7,11);
     ```
   * Utilize as Views e Functions para validar resultados:

     ```sql
     -- Exemplo: faturamento no período
     EXEC sp_obter_faturamento_por_periodo @data_inicio='2025-06-01', @data_fim='2025-06-30';

     -- Exemplo: produtos abaixo do estoque mínimo
     SELECT * FROM fn_produtos_abaixo_stock_minimo();

     -- Exemplo: consumo de estoque em Maio/2025
     SELECT * FROM fn_valores_gastos_stock_mes_ano(2025, 5);
     ```

Com estes seeds, o ambiente ficará populado com dados de exemplo que permitem testar todas as funcionalidades automatizadas (triggers, funções, SPs e consultas via Views) do Boteco Pro.
