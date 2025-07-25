-- ============================================
-- inventory/functions.sql
-- ============================================
create or replace function inventory.get_supplier_details(supplier_id integer)
returns table (
    supplier_id integer,
    name text,
    email text,
    phone text,
    notes text
)
language plpgsql
as $$
begin
    return query
    select supplier_id, name, email, phone, notes
    from inventory.supplier
    where supplier_id = supplier_id;
end;
$$;