## 🍽️ **1. Cadastro e Gerência de Receitas**

### Regras:

* Uma **receita** pode ser de tipo `dish`, `cocktail`, `combo`, etc.
* Cada receita deve ter pelo menos um ingrediente.
* O **preço de venda sugerido** pode ser calculado com base:

  ```plaintext
  preço de custo total dos ingredientes + margem de lucro padrão + extras
  ```
* **Adições** devem alterar o preço final do pedido.

### Para API:

* Endpoint: `GET /recipes/{id}` → retornar estrutura da receita com ingredientes e adições.
* Endpoint: `POST /recipes/calculate-price` → retorna preço sugerido baseado na quantidade e adições.

---

## 🍷 **2. Bebidas Alcoólicas e Combinações**

### Regras:

* Cocktails podem ter múltiplas **bases alternativas** (ex: rum, gin).
* Preço pode variar conforme a base selecionada.
* Cada base deve ser definida como uma **adição** à receita base (`Recipe_Addition`).

### Para API:

* Mostrar lista de “bases” ao cliente ao selecionar a bebida.
* Preço final do cocktail muda automaticamente se uma base mais cara for selecionada.

---

## 📦 **3. Estoque e Insumos**

### Regras:

* Cada pedido **consome** ingredientes proporcionalmente à quantidade vendida.
* O estoque de `Ingredient` deve ser atualizado automaticamente após o fechamento do pedido.
* Notificações devem ser emitidas para ingredientes abaixo do nível mínimo (`stock_minimum`).

### Para API / backend:

* Procedure: `sp_AtualizarEstoquePorPedido(@order_id)`
* View: `vw_IngredientesAbaixoEstoqueMinimo`
* Endpoint: `GET /inventory/alerts`

---

## 🧾 **4. Pedidos e Faturamento**

### Regras:

* Um pedido pode conter múltiplos itens, cada um com adições opcionais.
* O valor final da fatura = soma dos itens + soma das adições + impostos
* Impostos podem ser diferentes para comida e bebida.

### Para API:

* `POST /orders` → criar pedido
* `GET /orders/{id}` → ver detalhes do pedido
* `POST /invoice/generate` → calcular e gerar fatura
* `GET /invoice/{id}` → ver total com breakdown (subtotais, impostos, extras)

---

## 👨‍🍳 **5. Funcionários e Controle de Trabalho**

### Regras:

* Cada funcionário tem um valor/hora e está vinculado a um plano de carreira.
* As horas são lançadas mensalmente, com extras contabilizadas.
* Login e senha são controlados separadamente em `Employee_Login`.

### Para API:

* `POST /login` → autenticação
* `POST /workhours` → lançamento de horas
* `GET /payroll/{month}/{year}` → cálculo estimado de remuneração

---

## 📲 **6. Comanda e Atendimento**

> A ser discutido mais adiante, mas proposta inicial:

* Uma **comanda** representa uma sessão ativa da mesa (pode conter múltiplos pedidos).
* Permite pedidos em etapas sem fechar a conta.
* Ao final, todos os pedidos da comanda são consolidados na fatura.

---

Deseja que eu escreva essas regras diretamente no banco como *comentários estruturais* ou devemos seguir criando *procedimentos armazenados* e endpoints que as implementem na prática?
