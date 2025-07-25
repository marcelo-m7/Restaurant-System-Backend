-- ============================================
-- inventory/rls.sql
-- ============================================

alter table inventory.supplier enable row level security;

create policy "public read access to suppliers"
on inventory.supplier
for select
using (true);

create policy "only manager can manage suppliers"
on inventory.supplier
for all
using (auth.jwt() ->> 'role' = 'manager')
with check (auth.jwt() ->> 'role' = 'manager');
