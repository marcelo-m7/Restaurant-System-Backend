-- ============================================
-- client/tables.sql
-- ============================================

create table client.client (
    client_id serial primary key,
    name text,
    tax_id text,
    address text,
    city text,
    postal_code text,
    client_type text
);

create table client.table_seating (
    table_id serial primary key,
    number integer,
    seats integer,
    is_available boolean default true
);
