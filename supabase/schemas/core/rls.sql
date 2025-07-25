-- ============================================
-- core/rls.sql
-- ============================================

alter table core.recipe enable row level security;
alter table core.ingredient enable row level security;
alter table core.category enable row level security;
alter table core.recipe_ingredient enable row level security;
alter table core.recipe_addition enable row level security;
alter table core.addition_ingredient enable row level security;

create policy "public read access"
on core.recipe
for select
using (true);

create policy "only manager can insert or update recipes"
on core.recipe
for all
using (auth.jwt() ->> 'role' = 'manager')
with check (auth.jwt() ->> 'role' = 'manager');

create policy "public read access"
on core.ingredient
for select
using (true);

create policy "only manager can write"
on core.ingredient
for all
using (auth.jwt() ->> 'role' = 'manager')
with check (auth.jwt() ->> 'role' = 'manager');

create policy "read categories"
on core.category
for select
using (true);

create policy "only manager can manage categories"
on core.category
for all
using (auth.jwt() ->> 'role' = 'manager')
with check (auth.jwt() ->> 'role' = 'manager');

create policy "view composition"
on core.recipe_ingredient
for select
using (true);

create policy "manage composition"
on core.recipe_ingredient
for all
using (auth.jwt() ->> 'role' = 'manager')
with check (auth.jwt() ->> 'role' = 'manager');

create policy "view additions"
on core.recipe_addition
for select
using (true);

create policy "manage additions"
on core.recipe_addition
for all
using (auth.jwt() ->> 'role' = 'manager')
with check (auth.jwt() ->> 'role' = 'manager');

create policy "view addition ingredients"
on core.addition_ingredient
for select
using (true);

create policy "manage addition ingredients"
on core.addition_ingredient
for all
using (auth.jwt() ->> 'role' = 'manager')
with check (auth.jwt() ->> 'role' = 'manager');
