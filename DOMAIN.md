# Domain Model

This document summarizes the core domain entities, relationships, and V1 business rules for the multi-tenant restaurant system.

## Core Entities and Responsibilities

- **Tenant**: isolation boundary for all data and operations.
- **Unit**: operational branch/location within a tenant.
- **User**: actor that opens tabs, creates orders, and records payments.
- **Area**: physical section of a unit (for example, hall or terrace).
- **Table**: dine-in table where tabs are opened.
- **Tab**: customer bill/session; aggregates financial totals.
- **Order**: set of requested items attached to a tab.
- **OrderItem**: line item with quantity and immutable price snapshot.
- **Product**: sellable item.
- **Category**: product grouping.
- **Payment**: payment transaction attached to a tab.

## Cardinalities (Conceptual)

- Tenant `1 -> N` Unit, User, Product, Category.
- Unit `1 -> N` Area, Table, Tab.
- Area `1 -> N` Table.
- Table `1 -> N` Tab (**at most one open tab at a time**).
- Tab `1 -> N` Order, Payment.
- Order `1 -> N` OrderItem.
- Product `1 -> N` OrderItem.
- User `1 -> N` Tab (openedBy), Order (createdBy), Payment (createdBy).

## Golden Rules

1. **Single open tab per table**: a table cannot have more than one tab in `open` status.
2. **Tab is the financial aggregator**: tab tracks subtotal, fees, total, paid, and due.
3. **Order items keep immutable snapshots**: each `OrderItem` stores product price/name snapshots used at sale time.
4. **Sent orders are not edited**: corrections are made by voiding items or creating new orders.
5. **Closed tabs are immutable**: no new orders/items/payments can be added.
6. **Tenant isolation is mandatory**: all reads/writes are tenant-scoped.

## V1 Use Cases

- Open tab.
- Create draft order.
- Add item to order.
- Void order item (auditable correction).
- Send order.
- Recalculate tab totals.
- Create payment.
- Confirm payment.
- Close tab.

## Financial Rules

Recommended calculation model:

- `subtotal`: sum of active items from sent orders.
- `service_fee`: optional percentage over subtotal.
- `total`: `subtotal + service_fee`.
- `paid`: sum of confirmed payments.
- `due`: `max(total - paid, 0)`.

## Audit Expectations

Every relevant state change should preserve:

- `who` (user id)
- `when` (timestamp)
- `why` (optional reason)

This creates a traceable event trail and supports future integrations.
