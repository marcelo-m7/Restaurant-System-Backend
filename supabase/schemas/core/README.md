# 🧠 Schema: `core`

O schema `core` representa o **catálogo de produtos** do BotecoPro, incluindo receitas (comidas, drinks, combos), ingredientes e categorias. É a base para o cálculo de custos e estruturação dos pedidos.

---

## 📐 Estrutura

### Tabelas

* `category`: classifica receitas por tipo (ex: comida, bebida)
* `recipe`: pratos e bebidas que podem ser vendidos
* `ingredient`: insumos usados nas receitas (com controle de estoque)
* `recipe_ingredient`: composição de cada receita
* `recipe_addition`: opcionais/adicionais para uma receita
* `addition_ingredient`: insumos consumidos por um adicional

### Funções

Nenhuma função RPC ativa neste schema ainda.

---

## 🔐 RLS Policies

* Leitura pública para todas as tabelas
* Escrita e modificação restritas a `manager`

---

## 📊 Fluxo de uso

* App lê `recipe` e seus `additions`
* Ao adicionar ao pedido, calcula-se o custo com base nos ingredientes e adicionais
* Estoque é controlado automaticamente ao confirmar o pedido (via schema `order`)

---

## 🔮 Melhorias futuras

* Suporte a múltiplos tamanhos de porção
* Função `core.calculate_recipe_cost()`
* Flag para receitas inativas ou sazonais
