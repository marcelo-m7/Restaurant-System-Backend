# Fluxo entre entidades

* **Pedido “sent” não edita** (se errou: *void* item ou cria outro pedido)
* Ajustes ficam auditáveis (nada de “apagar do nada”)

---

## Resumo “em uma linha” (pra bater o olho)

* Tenant **1** → **0..*** Unit, User, Product, Category
* Unit **1** → **0..*** Area, Table, Tab
* Area **1** → **0..*** Table
* Table **1** → **0..*** Tab *(regra: máx 1 aberta)*
* Tab **1** → **0..*** Order, Payment
* Order **1** → **1..*** OrderItem
* Product **1** → **0..*** OrderItem
* User **1** → **0..*** Tab(openedBy), Order(createdBy), Payment(createdBy)

---

## 1) Use cases do V1 (o “motor” do sistema)

### 1. OpenTab (Abrir comanda)

**Input**

* `tenantId, unitId, tableId, openedByUserId, notes?`

**Regras**

* A mesa precisa estar `available` (ou permite abrir mesmo `occupied` se você quiser; eu recomendo: abrir muda pra occupied).
* **Não pode existir Tab `open` na mesma mesa**.

**Output**

* `tabId` + snapshot do estado (totais zerados)

**Evento**

* `TabOpened`

---

### 2. CreateOrder (Criar pedido rascunho)

**Input**

* `tenantId, unitId, tabId, createdByUserId`

**Regras**

* Tab tem que estar `open`.

**Output**

* `orderId` com status `draft`

**Evento**

* `OrderCreated`

---

### 3. AddItemToOrder (Adicionar item no pedido)

**Input**

* `orderId, productId, qty, notes?`

**Regras**

* Order tem que estar `draft`.
* Product precisa estar `active`.
* **Congelar preço e nome** no item: `unitPriceSnapshot`, `productNameSnapshot`.
* `qty > 0`.

**Output**

* `orderItemId`

**Evento**

* `OrderItemAdded`

---

### 4. VoidOrderItem (Anular item)

**Input**

* `orderItemId, voidedByUserId, reason?`

**Regras**

* Se Order já foi `sent`: permitido (virou “correção”), mas **não apaga**, só marca `voided`.
* Se Tab já `closed`: bloqueia.

**Output**

* item com status `voided`

**Evento**

* `OrderItemVoided`

---

### 5. SendOrder (Enviar pedido)

**Input**

* `orderId`

**Regras**

* Order tem que estar `draft`.
* Precisa ter pelo menos 1 item `active`.
* Tab tem que estar `open`.

**Output**

* Order `sent` + `sentAt`.

**Evento**

* `OrderSent`

---

### 6. RecalculateTabTotals (Recalcular totais da comanda)

**Quando roda**

* após `OrderSent`, `OrderItemVoided`, `PaymentConfirmed`, etc.

**Regras de cálculo (V1)**

* `subtotal = soma(orderItems active)`, considerando **apenas Orders sent** (recomendado).
* `serviceFee = subtotal * percent` se habilitado.
* `total = subtotal + serviceFee`
* `paid = soma(payments confirmed)`
* `due = max(total - paid, 0)`

**Evento**

* `TabRecalculated`

> Observação: dá pra incluir “itens em draft” no subtotal? Dá. Mas o padrão PDV é: só entra no total quando o pedido é “enviado/confirmado”.

---

### 7. CreatePayment (Criar pagamento)

**Input**

* `tabId, method, amount, createdByUserId, externalRef?`

**Regras**

* Tab tem que estar `open`.
* `amount > 0`
* Não deixa pagar mais que o `due`?

  * Eu sugiro: **permitir**, mas registrar `changeAmount` depois (troco). No V1, pode bloquear pra simplificar.

**Output**

* `paymentId` status `pending` (ou já `confirmed` se você não precisa de captura)

**Evento**

* `PaymentCreated`

---

### 8. ConfirmPayment (Confirmar pagamento)

**Input**

* `paymentId`

**Regras**

* Payment `pending`.
* Tab `open`.

**Output**

* Payment `confirmed`, `paidAt`.

**Evento**

* `PaymentConfirmed`

---

### 9. CloseTab (Fechar comanda)

**Input**

* `tabId, closedByUserId`

**Regras**

* Tab tem que estar `open`.
* `dueAmount == 0` (ou <= tolerância tipo 0.01)
* (Opcional) “não pode ter pedido draft pendente” — recomendado.

**Output**

* Tab `closed`, `closedAt`.

**Evento**

* `TabClosed`

---

## 2) Regras de consistência (as “leis do universo”)

### Regras de estado

* **Uma mesa só pode ter uma Tab aberta** por vez.
* **Tab fechada é imutável** (não adiciona pedido, não void item, não registra pagamento).
* **Order sent é imutável**: não edita item, só anula (void) ou cria novo pedido.

### Regras de dinheiro

* **Snapshot obrigatório** de preço/nome no OrderItem.
* Total da comanda depende de:

  * Itens ativos de pedidos enviados
  * Taxa de serviço (se habilitada)
  * Pagamentos confirmados
* `due >= 0` sempre.

### Auditoria mínima (muito importante)

* Tudo que muda estado relevante deve ter:

  * `who` (userId)
  * `when` (timestamp)
  * `why` (reason opcional)

---

## 3) Eventos do domínio (pra logs, integrações, KDS depois)

Um pacote mínimo que já te dá trilha auditável e integrações futuras:

* `TabOpened(tabId, tableId, userId, at)`
* `OrderCreated(orderId, tabId, userId, at)`
* `OrderItemAdded(orderId, orderItemId, productId, qty, unitPriceSnapshot, at)`
* `OrderSent(orderId, tabId, at)`
* `OrderItemVoided(orderItemId, reason?, userId, at)`
* `PaymentCreated(paymentId, tabId, method, amount, at)`
* `PaymentConfirmed(paymentId, tabId, amount, at)`
* `TabRecalculated(tabId, subtotal, serviceFee, total, paid, due, at)`
* `TabClosed(tabId, at)`

---

## 4) Contrato de API (bem direto, já cheirando a endpoints)

Se você for REST:

* `POST /tabs` → OpenTab
* `POST /tabs/{tabId}/orders` → CreateOrder
* `POST /orders/{orderId}/items` → AddItemToOrder
* `POST /orders/{orderId}/send` → SendOrder
* `POST /order-items/{orderItemId}/void` → VoidOrderItem
* `POST /tabs/{tabId}/payments` → CreatePayment
* `POST /payments/{paymentId}/confirm` → ConfirmPayment
* `POST /tabs/{tabId}/close` → CloseTab
* `POST /tabs/{tabId}/recalculate` → RecalculateTabTotals (ou interno)

---