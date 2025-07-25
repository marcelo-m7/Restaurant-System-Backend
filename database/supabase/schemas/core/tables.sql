-- ============================================
-- core/tables.sql
-- ============================================

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
    supplier_id integer references inventory.supplier(supplier_id)
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
