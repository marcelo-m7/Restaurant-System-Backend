-- ============================================
-- inventory/tables.sql
-- ============================================

create table inventory.supplier (
    supplier_id serial primary key,
    name text not null,
    email text,
    phone text,
    notes text
);
