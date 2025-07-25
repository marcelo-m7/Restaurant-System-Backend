-- ============================================
-- order/rls.sql
-- ============================================

alter table "order".order_main enable row level security;
alter table "order".order_item enable row level security;
alter table "order".order_item_addition enable row level security;

create policy "staff can view own orders"
on "order".order_main
for select
using (
  auth.jwt() ->> 'role' = 'waiter' and employee_id = cast(auth.uid() as integer)
);

create policy "waiter can insert orders"
on "order".order_main
for insert
with check (
  auth.jwt() ->> 'role' = 'waiter' and employee_id = cast(auth.uid() as integer)
);

create policy "view items of own orders"
on "order".order_item
for select
using (
  exists (
    select 1 from "order".order_main m
    where m.order_id = order_item.order_id
    and m.employee_id = cast(auth.uid() as integer)
  )
);

create policy "insert items into own orders"
on "order".order_item
for insert
with check (
  exists (
    select 1 from "order".order_main m
    where m.order_id = order_item.order_id
    and m.employee_id = cast(auth.uid() as integer)
  )
);

create policy "view additions of own orders"
on "order".order_item_addition
for select
using (
  exists (
    select 1 from "order".order_main m
    where m.order_id = order_item_addition.order_id
    and m.employee_id = cast(auth.uid() as integer)
  )
);

create policy "insert additions into own orders"
on "order".order_item_addition
for insert
with check (
  exists (
    select 1 from "order".order_main m
    where m.order_id = order_item_addition.order_id
    and m.employee_id = cast(auth.uid() as integer)
  )
);
