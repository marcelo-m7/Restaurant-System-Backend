-- ============================================
-- BotecoPro Supabase - Schema-based Setup
-- ============================================

-- 🏁 Etapa 1: Criação dos Schemas
create schema if not exists core;
create schema if not exists order;
create schema if not exists invoice;
create schema if not exists staff;
create schema if not exists client;
create schema if not exists inventory;
create schema if not exists auth;

-- ============================================
-- 🧱 Etapa 2: Tabelas no Schema `core`
create table core.category (
    category_id serial primary key,
    name text not null
);

create table core.recipe (
    recipe_id serial primary key,
    name text not null,
    type text not null,
    base_price numeric(10,2),
    preparation_time time,
    category_id integer references core.category(category_id),
    notes text
);

create table core.ingredient (
    ingredient_id serial primary key,
    name text not null,
    unit_of_measure text not null,
    cost_price numeric(10,2),
    stock_quantity numeric(10,2),
    stock_minimum numeric(10,2),
    reorder_quantity numeric(10,2),
    last_order_date date,
    supplier_id integer -- referência futura para inventory.supplier
);

create table core.recipe_ingredient (
    recipe_id integer references core.recipe(recipe_id),
    ingredient_id integer references core.ingredient(ingredient_id),
    quantity numeric(10,2),
    primary key (recipe_id, ingredient_id)
);

create table core.recipe_addition (
    addition_id serial primary key,
    recipe_id integer references core.recipe(recipe_id),
    name text,
    extra_cost numeric(10,2)
);

create table core.addition_ingredient (
    addition_id integer references core.recipe_addition(addition_id),
    ingredient_id integer references core.ingredient(ingredient_id),
    quantity numeric(10,2),
    primary key (addition_id, ingredient_id)
);

-- ============================================
-- 🪑 Etapa 3: Schema `client`
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

-- ============================================
-- 👤 Etapa 4: Schema `staff`
create table staff.employee (
    employee_id serial primary key,
    name text,
    role text,
    hourly_rate numeric(10,2)
);

-- ============================================
-- 📦 Etapa 5: Schema `inventory`
create table inventory.supplier (
    supplier_id serial primary key,
    name text not null,
    email text,
    phone text,
    notes text
);

alter table core.ingredient
    add constraint fk_supplier
    foreign key (supplier_id) references inventory.supplier(supplier_id);

-- ============================================
-- 🧾 Etapa 6: Schema `order`
create table "order".order_main (
    order_id serial primary key,
    table_id integer references client.table_seating(table_id),
    employee_id integer references staff.employee(employee_id),
    client_id integer references client.client(client_id),
    order_datetime timestamp default now(),
    status text,
    notes text
);

create table "order".order_item (
    order_id integer references "order".order_main(order_id),
    recipe_id integer references core.recipe(recipe_id),
    quantity integer,
    base_price numeric(10,2),
    primary key (order_id, recipe_id)
);

create table "order".order_item_addition (
    order_id integer,
    recipe_id integer,
    addition_id integer references core.recipe_addition(addition_id),
    quantity integer,
    primary key (order_id, recipe_id, addition_id),
    foreign key (order_id, recipe_id) references "order".order_item(order_id, recipe_id)
);

-- ============================================
-- 💸 Etapa 7: Schema `invoice`
create table invoice.invoice (
    invoice_id serial primary key,
    order_id integer references "order".order_main(order_id),
    invoice_date date default current_date,
    total_amount numeric(10,2),
    tax_amount numeric(10,2),
    food_tax_rate numeric(5,2),
    drink_tax_rate numeric(5,2)
);
