# 📦 Schema: `order`

O schema `order` representa o coração operacional do BotecoPro — é responsável pelo registro, atualização e controle de pedidos, incluindo itens e adicionais.

---

## 📐 Estrutura

### Tabelas

* `order_main`: representa um pedido completo (vinculado a mesa, funcionário e cliente).
* `order_item`: lista os pratos ou bebidas solicitados no pedido.
* `order_item_addition`: detalha os adicionais (ex: "+gelo", "+gin") vinculados a cada item.

### Funções (RPC)

* `create_order(table_id, employee_id, client_id, notes)`
* `add_order_item(order_id, recipe_id, quantity, base_price)`
* `add_order_addition(order_id, recipe_id, addition_id, quantity)`
* `confirm_order(order_id)`
* `cancel_order(order_id, restore_stock)`

Essas funções são expostas via Supabase RPC como endpoints RESTful: `/rpc/order.create_order`, etc.

---

## 🔐 RLS Policies

* **Leitura:** permitida apenas ao funcionário (garçom) responsável pelo pedido.
* **Escrita:** criação e atualização de itens só são permitidas para quem criou o pedido.

Todas as regras são baseadas na verificação do JWT (`auth.jwt() ->> 'role'` e `auth.uid()`).

---

## 📊 Exemplo de fluxo

1. App Flutter chama `order.create_order(...)` → retorna `order_id`
2. Itens são adicionados via `order.add_order_item`
3. Adicionais via `order.add_order_addition`
4. Quando finalizado, `order.confirm_order` atualiza o estoque
5. Pedido pode ser revertido com `order.cancel_order(..., restore_stock := true)`

---

## 🚧 Futuras melhorias

* Registro de status intermediário (em preparo, entregue)
* Suporte a comandas múltiplas por mesa
* Logs e auditoria de alterações nos pedidos
