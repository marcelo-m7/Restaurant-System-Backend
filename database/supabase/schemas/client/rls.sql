-- ============================================
-- client/rls.sql
-- ============================================

alter table client.client enable row level security;
alter table client.table_seating enable row level security;

create policy "public read access to clients"
on client.client
for select
using (true);

create policy "only manager can manage clients"
on client.client
for all
using (auth.jwt() ->> 'role' = 'manager')
with check (auth.jwt() ->> 'role' = 'manager');

create policy "public read access to tables"
on client.table_seating
for select
using (true);

create policy "only manager can manage tables"
on client.table_seating
for all
using (auth.jwt() ->> 'role' = 'manager')
with check (auth.jwt() ->> 'role' = 'manager');
