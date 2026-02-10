# Domain Model

This document summarizes the core domain entities, relationships, and V1 business rules for the multi-tenant restaurant system.

## Core Entities

- **Tenant**: isolation boundary for all data and operations.
- **Unit**: branch/location (`name`, `timezone`, `service_fee_enabled`, `service_fee_percent`).
- **Area**: physical section in a unit (`unit_id`, `name`, `sort_order`).
- **Table**: dine-in table (`unit_id`, `area_id`, `capacity`).
- **User**: actor metadata (`name`, `email`, `status`, `roles`).
- **Tab**: customer bill session with aggregated financial totals.
- **Order**: draft/sent order attached to a tab.
- **OrderItem**: immutable snapshot line item (`product_name_snapshot`, `unit_price_snapshot`, `quantity`, `status`).
- **Product** and **Category**: catalog.
- **Payment**: pending/paid payment attached to tab.

## Golden Rules

1. **Single open tab per table**.
2. **Tab totals are derived** from non-void items of sent orders.
3. **Order item snapshots are immutable** and independent of future product changes.
4. **Sent orders are immutable** (only item voids/new orders can adjust totals).
5. **Closed tabs are immutable** for order and payment creation.
6. **Tenant isolation is mandatory** on every endpoint.

## Workflow Endpoints

- `POST /tabs/open` – open tab for a table if no open tab exists.
- `POST /orders` – create a draft order for a tab.
- `POST /order-items` – add an item to a draft order with product snapshots.
- `POST /orders/{order_id}/send` – send only non-empty draft orders.
- `POST /order-items/{item_id}/void` – void a sent-order item.
- `POST /tabs/{tab_id}/recalculate` – recompute financial totals.
- `POST /payments` – create pending payment (must not exceed due).
- `POST /payments/{payment_id}/confirm` – confirm payment and recompute tab totals.
- `POST /tabs/{tab_id}/close` – close tab when `due_amount == 0` and no draft orders.

## Financial Model

- `subtotal_amount`: sum of active order items from `sent` orders.
- `service_fee_amount`: optional percentage over subtotal based on unit settings.
- `total_amount`: `subtotal_amount + service_fee_amount`.
- `paid_amount`: sum of payments with status `paid`.
- `due_amount`: `max(total_amount - paid_amount, 0)`.
