-- ============================================
-- order/functions.sql
-- ============================================

create or replace function "order".create_order(
  table_id integer,
  employee_id integer,
  client_id integer default null,
  notes text default null
)
returns integer
language plpgsql
as $$
declare new_order_id integer;
begin
  insert into "order".order_main (table_id, employee_id, client_id, order_datetime, status, notes)
  values (table_id, employee_id, client_id, now(), 'Pending', notes)
  returning order_id into new_order_id;
  return new_order_id;
end;
$$;

create or replace function "order".add_order_item(
  order_id integer,
  recipe_id integer,
  quantity integer,
  base_price numeric
)
returns void
language plpgsql
as $$
begin
  if exists (
    select 1 from "order".order_item where order_id = order_id and recipe_id = recipe_id
  ) then
    update "order".order_item
    set quantity = quantity + "order".add_order_item.quantity
    where order_id = "order".add_order_item.order_id and recipe_id = "order".add_order_item.recipe_id;
  else
    insert into "order".order_item (order_id, recipe_id, quantity, base_price)
    values (order_id, recipe_id, quantity, base_price);
  end if;
end;
$$;

create or replace function "order".add_order_addition(
  order_id integer,
  recipe_id integer,
  addition_id integer,
  quantity integer
)
returns void
language plpgsql
as $$
begin
  insert into "order".order_item_addition (order_id, recipe_id, addition_id, quantity)
  values (order_id, recipe_id, addition_id, quantity);
end;
$$;

create or replace function "order".confirm_order(order_id integer)
returns void
language plpgsql
as $$
declare ing_id integer; qty numeric;
begin
  update "order".order_main set status = 'Confirmed' where order_id = confirm_order.order_id;
  for ing_id, qty in
    select ri.ingredient_id, ri.quantity * oi.quantity
    from "order".order_item oi
    join core.recipe_ingredient ri on oi.recipe_id = ri.recipe_id
    where oi.order_id = confirm_order.order_id
  loop
    update core.ingredient set stock_quantity = stock_quantity - qty where ingredient_id = ing_id;
  end loop;
  for ing_id, qty in
    select ai.ingredient_id, ai.quantity * oia.quantity
    from "order".order_item_addition oia
    join core.addition_ingredient ai on oia.addition_id = ai.addition_id
    where oia.order_id = confirm_order.order_id
  loop
    update core.ingredient set stock_quantity = stock_quantity - qty where ingredient_id = ing_id;
  end loop;
end;
$$;

create or replace function "order".cancel_order(order_id integer, restore_stock boolean default false)
returns void
language plpgsql
as $$
declare ing_id integer; qty numeric;
begin
  if restore_stock then
    for ing_id, qty in
      select ri.ingredient_id, ri.quantity * oi.quantity
      from "order".order_item oi
      join core.recipe_ingredient ri on oi.recipe_id = ri.recipe_id
      where oi.order_id = cancel_order.order_id
    loop
      update core.ingredient set stock_quantity = stock_quantity + qty where ingredient_id = ing_id;
    end loop;
    for ing_id, qty in
      select ai.ingredient_id, ai.quantity * oia.quantity
      from "order".order_item_addition oia
      join core.addition_ingredient ai on oia.addition_id = ai.addition_id
      where oia.order_id = cancel_order.order_id
    loop
      update core.ingredient set stock_quantity = stock_quantity + qty where ingredient_id = ing_id;
    end loop;
  end if;
  update "order".order_main set status = 'Canceled' where order_id = cancel_order.order_id;
end;
$$;
