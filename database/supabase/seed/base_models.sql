-- ============================================
-- BotecoPro DB (Supabase-Compatible) - Tables & Business Rules
-- ============================================

-- Categories (e.g., Food, Alcohol, Soft Drink, etc.)
CREATE TABLE IF NOT EXISTS category (
    category_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- Suppliers
CREATE TABLE IF NOT EXISTS supplier (
    supplier_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    notes TEXT
);

-- Ingredients (raw materials)
CREATE TABLE IF NOT EXISTS ingredient (
    ingredient_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    unit_of_measure TEXT NOT NULL,
    cost_price NUMERIC(10,2),
    stock_quantity NUMERIC(10,2),
    stock_minimum NUMERIC(10,2),
    reorder_quantity NUMERIC(10,2),
    last_order_date DATE,
    supplier_id INTEGER REFERENCES supplier(supplier_id)
);

-- Recipes (dishes, cocktails, etc.)
CREATE TABLE IF NOT EXISTS recipe (
    recipe_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    base_price NUMERIC(10,2),
    preparation_time TIME,
    category_id INTEGER REFERENCES category(category_id),
    notes TEXT
);

-- Recipe Ingredients
CREATE TABLE IF NOT EXISTS recipe_ingredient (
    recipe_id INTEGER REFERENCES recipe(recipe_id),
    ingredient_id INTEGER REFERENCES ingredient(ingredient_id),
    quantity NUMERIC(10,2),
    PRIMARY KEY (recipe_id, ingredient_id)
);

-- Recipe Additions
CREATE TABLE IF NOT EXISTS recipe_addition (
    addition_id SERIAL PRIMARY KEY,
    recipe_id INTEGER REFERENCES recipe(recipe_id),
    name TEXT,
    extra_cost NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS addition_ingredient (
    addition_id INTEGER REFERENCES recipe_addition(addition_id),
    ingredient_id INTEGER REFERENCES ingredient(ingredient_id),
    quantity NUMERIC(10,2),
    PRIMARY KEY (addition_id, ingredient_id)
);

-- Clients
CREATE TABLE IF NOT EXISTS client (
    client_id SERIAL PRIMARY KEY,
    name TEXT,
    tax_id TEXT,
    address TEXT,
    city TEXT,
    postal_code TEXT,
    client_type TEXT
);

-- Table Seating
CREATE TABLE IF NOT EXISTS table_seating (
    table_id SERIAL PRIMARY KEY,
    number INTEGER,
    seats INTEGER,
    is_available BOOLEAN DEFAULT TRUE
);

-- Employees (required for FK in orders)
CREATE TABLE IF NOT EXISTS employee (
    employee_id SERIAL PRIMARY KEY,
    name TEXT,
    role TEXT,
    hourly_rate NUMERIC(10,2)
);

-- Orders
CREATE TABLE IF NOT EXISTS order_main (
    order_id SERIAL PRIMARY KEY,
    table_id INTEGER REFERENCES table_seating(table_id),
    employee_id INTEGER REFERENCES employee(employee_id),
    client_id INTEGER REFERENCES client(client_id),
    order_datetime TIMESTAMP DEFAULT NOW(),
    status TEXT,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS order_item (
    order_id INTEGER REFERENCES order_main(order_id),
    recipe_id INTEGER REFERENCES recipe(recipe_id),
    quantity INTEGER,
    base_price NUMERIC(10,2),
    PRIMARY KEY (order_id, recipe_id)
);

CREATE TABLE IF NOT EXISTS order_item_addition (
    order_id INTEGER,
    recipe_id INTEGER,
    addition_id INTEGER REFERENCES recipe_addition(addition_id),
    quantity INTEGER,
    PRIMARY KEY (order_id, recipe_id, addition_id),
    FOREIGN KEY (order_id, recipe_id) REFERENCES order_item(order_id, recipe_id)
);

-- Invoices
CREATE TABLE IF NOT EXISTS invoice (
    invoice_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES order_main(order_id),
    invoice_date DATE DEFAULT CURRENT_DATE,
    total_amount NUMERIC(10,2),
    tax_amount NUMERIC(10,2),
    food_tax_rate NUMERIC(5,2),
    drink_tax_rate NUMERIC(5,2)
);
