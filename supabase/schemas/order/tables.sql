-- ============================================
-- order/tables.sql
-- ============================================

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
