## 🍽️ **1. Recipe Management**

### Rules

* A **recipe** can be of type `dish`, `cocktail`, `combo`, etc.
* Every recipe must have at least one ingredient.
* The **suggested sale price** can be calculated as:

  ```plaintext
  total cost of ingredients + default profit margin + extras
  ```
* **Additions** must change the final order price.

### API

* Endpoint: `GET /recipes/{id}` → return the recipe structure with ingredients and additions.
* Endpoint: `POST /recipes/calculate-price` → return suggested price based on quantity and additions.

---

## 🍷 **2. Alcoholic Drinks and Combos**

### Rules

* Cocktails can have multiple **alternative bases** (e.g. rum, gin).
* Price may vary according to the selected base.
* Each base should be defined as an **addition** to the base recipe (`Recipe_Addition`).

### API

* Show a list of "bases" when the client selects the drink.
* The final cocktail price changes automatically if a more expensive base is chosen.

---

## 📦 **3. Stock and Ingredients**

### Rules

* Each order **consumes** ingredients proportionally to the sold quantity.
* The `Ingredient` stock must be updated automatically after closing the order.
* Notifications must be issued for ingredients below the minimum level (`stock_minimum`).

### API / backend

* Procedure: `sp_AtualizarEstoquePorPedido(@order_id)`
* View: `vw_IngredientesAbaixoEstoqueMinimo`
* Endpoint: `GET /inventory/alerts`

---

## 🧾 **4. Orders and Billing**

### Rules

* An order may contain multiple items, each with optional additions.
* The final invoice value = sum of items + sum of additions + taxes.
* Taxes may differ for food and drinks.

### API

* `POST /orders` → create order
* `GET /orders/{id}` → view order details
* `POST /invoice/generate` → calculate and generate invoice
* `GET /invoice/{id}` → view total with breakdown (subtotals, taxes, extras)

---

## 👨‍🍳 **5. Employees and Work Control**

### Rules

* Each employee has an hourly rate and is linked to a career plan.
* Hours are logged monthly, with extras accounted for.
* Login and password are managed separately in `Employee_Login`.

### API

* `POST /login` → authentication
* `POST /workhours` → log hours
* `GET /payroll/{month}/{year}` → estimated remuneration calculation

---

## 📲 **6. Tabs and Service**

> To be discussed later, but initial idea:

* A **tab** represents an active table session (it can contain multiple orders).
* Allows orders in stages without closing the bill.
* At the end, all tab orders are consolidated into the invoice.

---

Should these rules be written directly in the database as *structural comments* or should we keep creating *stored procedures* and endpoints that implement them?
