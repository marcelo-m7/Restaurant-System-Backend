-- ============================================
-- invoice/rls.sql
-- ============================================

alter table invoice.invoice enable row level security;

create policy "manager or order author can read invoices"
on invoice.invoice
for select
using (
  auth.jwt() ->> 'role' = 'manager'
  or exists (
    select 1 from "order".order_main o
    where o.order_id = invoice.order_id
    and o.employee_id = cast(auth.uid() as integer)
  )
);

create policy "only manager can insert invoices"
on invoice.invoice
for insert
with check (
  auth.jwt() ->> 'role' = 'manager'
);
