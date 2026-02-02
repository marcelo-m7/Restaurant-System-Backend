
### `BotecoPro/docs/02_modelagem.md`

# 02. Modelagem Conceitual e Lógica

---

## 1. Entidades Principais

1. **Categoria**  
   - `categoria_id`: INT, PK  
   - `nome`: VARCHAR(100)  
   - `descricao`: VARCHAR(255)  

2. **Fornecedor**  
   - `fornecedor_id`: INT, PK  
   - `nome`: VARCHAR(150)  
   - `telefone`: VARCHAR(20)  
   - `email`: VARCHAR(100)  
   - `endereco`: VARCHAR(255)  
   - `cidade`: VARCHAR(100)  
   - `codigo_postal`: VARCHAR(20)  
   - `pais`: VARCHAR(100)  

3. **Produto**  
   - `produto_id`: INT, PK  
   - `nome`: VARCHAR(150)  
   - `tipo`: VARCHAR(50) (ex: 'ingrediente', 'bebida', 'sobremesa')  
   - `custo_unitario`: DECIMAL(10,2)  
   - `preco_venda`: DECIMAL(10,2)  
   - `stock_atual`: INT  
   - `stock_minimo`: INT  
   - `stock_encomenda`: INT  
   - `fornecedor_id`: INT, FK → Fornecedor  

4. **Encomenda**  
   - `encomenda_id`: INT, PK  
   - `fornecedor_id`: INT, FK → Fornecedor  
   - `data_encomenda`: DATETIME  
   - `status`: VARCHAR(20) (ex: 'pendente', 'recebida', 'cancelada')  
   - `valor_total`: DECIMAL(12,2)  

5. **EncomendaItem**  
   - `encomenda_item_id`: INT, PK  
   - `encomenda_id`: INT, FK → Encomenda  
   - `produto_id`: INT, FK → Produto  
   - `quantidade`: INT  
   - `preco_unitario`: DECIMAL(10,2)  

6. **MovimentacaoEstoque**  
   - `movimentacao_id`: INT, PK  
   - `produto_id`: INT, FK → Produto  
   - `data_movimentacao`: DATETIME  
   - `tipo`: VARCHAR(20) ('entrada' ou 'saida')  
   - `quantidade`: INT  
   - `preco_unitario`: DECIMAL(10,2)  
   - `pedido_id`: INT, FK opcional → Pedido  

7. **Prato**  
   - `prato_id`: INT, PK  
   - `nome`: VARCHAR(150)  
   - `categoria_id`: INT, FK → Categoria  
   - `descricao`: VARCHAR(255)  
   - `tempo_preparo`: INT (minutos)  
   - `preco_base`: DECIMAL(10,2)  

8. **PratoIngrediente**  
   - `prato_id`: INT, FK → Prato (PK composta)  
   - `produto_id`: INT, FK → Produto (PK composta)  
   - `quantidade_necessaria`: DECIMAL(10,3)  

9. **Carreira**  
   - `carreira_id`: INT, PK  
   - `nome`: VARCHAR(100) (ex: 'Cozinheiro 2ª Classe')  
   - `salario_mensal`: DECIMAL(12,2)  

10. **Funcionario**  
    - `funcionario_id`: INT, PK  
    - `nome`: VARCHAR(150)  
    - `data_nascimento`: DATE  
    - `telefone`: VARCHAR(20)  
    - `email`: VARCHAR(100)  
    - `cargo`: VARCHAR(100) (ex: 'Cozinheiro', 'Garçon')  
    - `carreira_id`: INT, FK → Carreira  
    - `data_admissao`: DATE  

11. **RegistroHoras**  
    - `registro_horas_id`: INT, PK  
    - `funcionario_id`: INT, FK → Funcionario  
    - `data_registro`: DATE  
    - `horas_normais`: DECIMAL(4,2)  
    - `horas_extra`: DECIMAL(4,2)  

12. **Mesa**  
    - `mesa_id`: INT, PK  
    - `numero`: INT (UNIQUE)  
    - `capacidade`: INT  
    - `status`: VARCHAR(20) ('livre', 'ocupada', 'reservada')  

13. **Cliente**  
    - `cliente_id`: INT, PK  
    - `nome`: VARCHAR(150)  
    - `telefone`: VARCHAR(20)  
    - `email`: VARCHAR(100)  
    - `morada`: VARCHAR(255)  
    - `cidade`: VARCHAR(100)  
    - `codigo_postal`: VARCHAR(20)  
    - `contribuinte`: VARCHAR(20)  

14. **Reserva** *(opcional)*  
    - `reserva_id`: INT, PK  
    - `cliente_id`: INT, FK → Cliente  
    - `mesa_id`: INT, FK → Mesa  
    - `data_reserva`: DATE  
    - `hora_reserva`: TIME  
    - `quantidade_pessoas`: INT  
    - `status`: VARCHAR(20) ('ativa', 'confirmada', 'cancelada')  

15. **Pedido**  
    - `pedido_id`: INT, PK  
    - `mesa_id`: INT, FK → Mesa  
    - `funcionario_id`: INT, FK → Funcionario  
    - `cliente_id`: INT, FK → Cliente (opcional)  
    - `data_pedido`: DATETIME  
    - `status`: VARCHAR(20) ('pendente', 'em_preparo', 'pronto', 'entregue', 'finalizado', 'cancelado')  

16. **PedidoItem**  
    - `pedido_item_id`: INT, PK  
    - `pedido_id`: INT, FK → Pedido  
    - `prato_id`: INT, FK → Prato (NULL se for produto genérico)  
    - `produto_id`: INT, FK → Produto (NULL se for prato)  
    - `quantidade`: INT  
    - `preco_unitario`: DECIMAL(10,2)  
    - `iva`: DECIMAL(5,2) (13% ou 23%)  

17. **Fatura**  
    - `fatura_id`: INT, PK  
    - `pedido_id`: INT, FK → Pedido (UNIQUE)  
    - `cliente_id`: INT, FK → Cliente (NULL se consumidor final sem contribuinte)  
    - `data_emissao`: DATETIME  
    - `tipo_fatura`: VARCHAR(20) ('consumidor_final', 'empresa')  
    - `nome_cliente`: VARCHAR(150)  
    - `morada_cliente`: VARCHAR(255)  
    - `cidade_cliente`: VARCHAR(100)  
    - `codigo_postal`: VARCHAR(20)  
    - `contribuinte`: VARCHAR(20)  
    - `subtotal_comida`: DECIMAL(12,2)  
    - `subtotal_bebida`: DECIMAL(12,2)  
    - `iva_comida`: DECIMAL(10,2)  
    - `iva_bebida`: DECIMAL(10,2)  
    - `total`: DECIMAL(14,2)  

18. **FaturaItem**  
    - `fatura_item_id`: INT, PK  
    - `fatura_id`: INT, FK → Fatura  
    - `descricao`: VARCHAR(255)  
    - `quantidade`: INT  
    - `preco_unitario`: DECIMAL(10,2)  
    - `valor_liquido`: DECIMAL(12,2)  
    - `percentual_iva`: DECIMAL(5,2)  
    - `valor_iva`: DECIMAL(10,2)  
    - `valor_total_linha`: DECIMAL(12,2)  

19. **MenuEspecial**  
    - `menu_especial_id`: INT, PK  
    - `nome`: VARCHAR(150)  
    - `descricao`: VARCHAR(255)  
    - `data_inicio`: DATE  
    - `data_fim`: DATE  
    - `preco_total`: DECIMAL(12,2)  

20. **MenuEspecialPrato**  
    - `menu_especial_id`: INT, FK → MenuEspecial (PK composta)  
    - `prato_id`: INT, FK → Prato (PK composta)  
    - `ordem`: INT (1=entrada, 2=peixe, 3=carne, 4=sobremesa, 5=café)  

---

## 2. Relacionamentos

- **Categoria 1–N Prato**  
- **Prato N–N Produto** (via PratoIngrediente)  
- **Produto N–1 Fornecedor**  
- **Encomenda N–1 Fornecedor**  
- **EncomendaItem N–1 Encomenda**  
- **Produto 1–N MovimentacaoEstoque**  
- **Carreira 1–N Funcionario**  
- **Funcionario 1–N RegistroHoras**  
- **Mesa 1–N Pedido**  
- **Cliente 1–N Pedido** (opcional)  
- **Pedido 1–N PedidoItem**  
- **Pedido 1–1 Fatura**  
- **Fatura 1–N FaturaItem**  
- **MenuEspecial N–N Prato** (via MenuEspecialPrato)  
- **Reserva N–1 Mesa** (se implementada)  
- **Reserva N–1 Cliente** (se implementada)  

---

## 3. Diagrama ER (Resumo)

```

\[Categoria]──< (categoria\_id) ──\[Prato]──< (prato\_id, produto\_id) ──\[PratoIngrediente]──> (produto\_id) ──\[Produto]──> (fornecedor\_id)──\[Fornecedor]
│                                                   │        │
│                                                   │        └─> MovimentacaoEstoque
│                                                   │
│                                                   └─> PedidoItem──> Pedido──> Mesa
│
└─< MenuEspecialPrato >─\[MenuEspecial]

\[Carreira]──< (carreira\_id) ──\[Funcionario]──< RegistroHoras
│
└─< Pedido (funcionario\_id)

\[Cliente]──<―(cliente\_id)──\[Pedido]──> PedidoItem
│            └─< Prato ou Produto
└─> Fatura──> FaturaItem

```

*(Em texto, cada `──<` representa “1 para N” e “>──` representa “N para 1”)*

---

## 4. Observações

1. Todas as tabelas utilizam `IDENTITY(1,1)` em suas chaves primárias.  
2. Tipos `VARCHAR` e precisões `DECIMAL` devem ser ajustados conforme volume/performance esperados.  
3. Campos de data usam `DATE` ou `DATETIME`, dependendo da necessidade de registro de hora exata.  
4. As tabelas de “MovimentacaoEstoque”, “PedidoItem” e “Fatura” funcionam como gatilhos indiretos (via triggers) para manter estoque e gerar faturas automaticamente.  
5. Recomenda-se criação de índices adicionais após carga de dados e testes de queries (ver arquivo `07_create_indices.sql`).  
6. A API só terá permissão de `SELECT` em Views e `EXECUTE` em SPs/Functions; métodos de inserção/atualização ficarão restritos a uma aplicação back-office ou processos internos.

Com esta modelagem, a implementação passa para a próxima fase: definir scripts SQL executáveis.

---

#### Observações Finais

1. Cada arquivo SQL deve ser executado na ordem indicada.
2. Caso queira subdividir ainda mais, é possível separar índices de tabelas principais em outro script, ou agrupar trigramas de performance em um script de “manutenção”.
3. As stored procedures auxiliares (`sp_abatimento_estoque_pedidoitem`, `sp_atualizar_stock_produto`) fazem parte de `06_create_triggers.sql` para manter a lógica de automação agrupada.
4. Ajuste nomes de schemas (por exemplo, `dbo`) conforme convenção de seu ambiente.
5. Após a execução, revise permissões: crie um usuário de API com apenas `SELECT` em Views e `EXECUTE` nas SPs/Functions.

