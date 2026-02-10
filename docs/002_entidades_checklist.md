# Checklist de Entidades

Padrão consistente pra todas:

* **Identidade & auditoria**: `id`, `tenantId`, `unitId` (quando faz sentido), `createdAt`, `updatedAt`
* **Status**: quando a entidade tem ciclo de vida
* **Campos de negócio**: o essencial pra operar o V1

---

## Relaçoes formais (cardinalidades)

Bora fechar as **relações formais (cardinalidades)** do V1. Vou listar em formato “A — B” com as multiplicidades e, quando fizer sentido, a regra extra (tipo “no máximo 1 aberto”).

> Convenção UML rápida:
> **1** = exatamente um
> **0..1** = opcional
> **0..*** = muitos (pode ser nenhum)
> **1..*** = muitos (pelo menos 1)

---

## Núcleo SaaS

### Tenant — Unit

* **Tenant (1)** —— **Unit (0..*)**
* Uma conta pode ter várias unidades; cada unidade pertence a 1 tenant.

### Tenant — User

* **Tenant (1)** —— **User (0..*)**

### Tenant — Product

* **Tenant (1)** —— **Product (0..*)**

### Tenant — Category

* **Tenant (1)** —— **Category (0..*)**

---

## Salão

### Unit — Area

* **Unit (1)** —— **Area (0..*)**

### Unit — Table

* **Unit (1)** —— **Table (0..*)**

### Area — Table

* **Area (1)** —— **Table (0..*)**
* (Cada mesa pertence a 1 área; uma área tem várias mesas.)

---

## Venda (comanda/pedido/itens)

### Table — Tab (Comanda)

* **Table (1)** —— **Tab (0..*)**
* Regra de negócio importante: **por mesa, no máximo 1 Tab com `status=open` ao mesmo tempo**.
  (Cardinalidade histórica é 0..* porque a mesa pode ter várias comandas ao longo do tempo.)

### Unit — Tab

* **Unit (1)** —— **Tab (0..*)**

### User — Tab (openedBy)

* **User (1)** —— **Tab (0..*)** *(como “openedByUserId”)*
* Uma tab é aberta por um user; um user abre várias tabs.

---

## Pedidos

### Tab — Order

* **Tab (1)** —— **Order (0..*)**
* Uma comanda pode ter vários pedidos (rodadas).

### User — Order (createdBy)

* **User (1)** —— **Order (0..*)**

### Order — OrderItem

* **Order (1)** —— **OrderItem (1..*)**
* Tecnicamente você pode permitir pedido vazio (0..*), mas **na prática**, quando `sent`, deve ter **1..***.

### Product — OrderItem

* **Product (1)** —— **OrderItem (0..*)**
* Todo item referencia 1 produto; um produto aparece em muitos itens.

> Observação de arquitetura: mesmo com `productId`, você grava `productNameSnapshot` e `unitPriceSnapshot` no OrderItem. Isso não muda cardinalidade, só melhora auditoria.

---

## Pagamentos

### Tab — Payment

* **Tab (1)** —— **Payment (0..*)**
* Uma comanda pode ter pagamentos parciais.

### User — Payment (createdBy)

* **User (1)** —— **Payment (0..*)**

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
## 1) Tenant

**Campos mínimos**

* `id`
* `name`
* `slug` (único)
* `plan` (free/pro/etc) *(opcional no V1, mas útil)*
* `createdAt`, `updatedAt`

**Invariantes**

* `slug` único.
* Nada de dados operacionais (mesa/pedido) aqui.

**Eventos**

* `TenantCreated`
* `TenantPlanChanged` *(se tiver plano)*

---

## 2) Unit

**Campos mínimos**

* `id`
* `tenantId`
* `name`
* `timezone` (ex: `Europe/Lisbon`)
* `serviceFeeEnabled` (bool)
* `serviceFeePercent` (decimal? ex: 0.10)
* `createdAt`, `updatedAt`

**Invariantes**

* `serviceFeePercent` só vale se `serviceFeeEnabled = true`.
* Timezone obrigatória (vai te salvar com relatórios e caixa depois).

**Eventos**

* `UnitCreated`
* `UnitSettingsUpdated`

---

## 3) User

**Campos mínimos**

* `id`
* `tenantId`
* `name`
* `email`
* `status` (`active|disabled`)
* `roles` (pode ser lista simples no V1)
* `createdAt`, `updatedAt`
* *(opcional)* `lastLoginAt`

**Invariantes**

* email único por tenant (ou global, você decide).
* user desativado não cria pedido/pagamento.

**Eventos**

* `UserCreated`
* `UserDisabled`
* `UserRoleChanged`

---

## 4) Area

**Campos mínimos**

* `id`
* `tenantId`
* `unitId`
* `name`
* `sortOrder` (int)
* `createdAt`, `updatedAt`

**Invariantes**

* `name` único por unidade (recomendado).
* `sortOrder` sem buraco não é obrigatório, mas fica bonito.

**Eventos**

* `AreaCreated`
* `AreaRenamed`
* `AreaReordered`

---

## 5) Table

**Campos mínimos**

* `id`
* `tenantId`
* `unitId`
* `areaId`
* `code` (ex: “12”, “B3”, “VIP-1”)
* `capacity` (int)
* `status` (`available|occupied|reserved|inactive`)
* `createdAt`, `updatedAt`

**Invariantes**

* `code` único por unidade.
* mesa `inactive` não pode receber comanda nova.

**Eventos**

* `TableCreated`
* `TableStatusChanged`

---

## 6) Category

**Campos mínimos**

* `id`
* `tenantId`
* `name`
* `sortOrder`
* `active` (bool)
* `createdAt`, `updatedAt`

**Invariantes**

* nome único por tenant (ou por cardápio se você criar Menu depois).

**Eventos**

* `CategoryCreated`
* `CategoryUpdated`

---

## 7) Product

**Campos mínimos**

* `id`
* `tenantId`
* `name`
* `categoryId`
* `basePrice` (money/decimal)
* `active` (bool)
* `createdAt`, `updatedAt`

**Invariantes**

* `basePrice >= 0`
* produto inativo não pode ser vendido.

**Eventos**

* `ProductCreated`
* `ProductPriceChanged`
* `ProductDisabled`

---

## 8) Tab (Comanda / Conta)

**Campos mínimos**

* `id`
* `tenantId`
* `unitId`
* `tableId` *(no V1 salão, sim)*
* `status` (`open|closed|cancelled`)
* `openedAt`
* `closedAt` *(nullable)*
* `openedByUserId`
* `notes` *(nullable)*

**Campos de totalização (recomendado já no V1)**

* `subtotalAmount`
* `serviceFeeAmount`
* `totalAmount`
* `paidAmount`
* `dueAmount`

> Esses totais podem ser **derivados** (calculados “on the fly”) ou **materializados** (salvos e recalculados a cada mudança). Em SaaS de restaurante, materializar costuma dar menos dor no PDV.

**Invariantes**

* Só existe **1 Tab aberta por mesa** (recomendado).
* Tab `closed` não aceita novos pedidos nem pagamentos novos.
* `dueAmount = totalAmount - paidAmount` (nunca negativo; no máximo 0).

**Eventos**

* `TabOpened`
* `TabRecalculated`
* `TabClosed`
* `TabCancelled`

---

## 9) Order

**Campos mínimos**

* `id`
* `tenantId`
* `unitId`
* `tabId`
* `createdByUserId`
* `status` (`draft|sent|cancelled`)
* `createdAt`, `sentAt?`, `cancelledAt?`

**Invariantes**

* `sentAt` só existe se status = `sent`.
* Order `sent` não muda itens (ou muda via “nova rodada” — regra clássica).

**Eventos**

* `OrderCreated`
* `OrderSent`
* `OrderCancelled`

---

## 10) OrderItem

**Campos mínimos**

* `id`
* `tenantId`
* `orderId`
* `productId`
* `productNameSnapshot` (string)
* `unitPriceSnapshot` (money)
* `qty` (decimal)
* `notes` *(nullable)*
* `status` (`active|voided`)
* `createdAt`, `updatedAt`

**Invariantes**

* **Snapshot obrigatório** (nome e preço no momento da venda).
* `qty > 0`
* `voided` não entra no subtotal (mas fica pra auditoria).

**Eventos**

* `OrderItemAdded`
* `OrderItemVoided`
* `OrderItemQtyChanged` *(se permitir antes de “sent”)*

---

## 11) Payment

**Campos mínimos**

* `id`
* `tenantId`
* `unitId`
* `tabId`
* `createdByUserId`
* `method` (`cash|card|pix|other`)
* `amount` (money)
* `status` (`pending|confirmed|voided|refunded`)
* `paidAt` *(nullable)*
* `externalRef` *(nullable: txId, nsu, etc)*
* `createdAt`, `updatedAt`

**Invariantes**

* `amount > 0`
* não pode confirmar pagamento em Tab fechada (depende da tua regra; eu bloquearia).
* `paidAt` só quando `confirmed`.

**Eventos**

* `PaymentCreated`
* `PaymentConfirmed`
* `PaymentVoided`
* `PaymentRefunded`

---

# Extra: “Objetos-valor” que salvam tua vida (sem ser entidade)

### Money

* `amount` (decimal)
* `currency` (ex: EUR)

> Mesmo que no começo você guarde só decimal, pensa nisso como conceito.

### Status enums

* Padroniza enums desde já pra não virar string solta.

---

# Checklist V1 (fluxos que o modelo precisa suportar)

1. **Abrir comanda** numa mesa
2. **Criar pedido** (draft) e **enviar**
3. Adicionar itens antes de enviar (ou via nova rodada)
4. **Calcular subtotal/taxa/total**
5. **Registrar pagamento parcial**
6. **Fechar comanda** quando `dueAmount = 0`
