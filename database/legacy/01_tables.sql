-- ============================================
-- BotecoPro DB - Improved Menu & Inventory Model with Business Rules
-- ============================================
USE botecopro_app_db;
GO

-- ============================================
-- Categories (e.g., Food, Alcohol, Soft Drink, etc.)
-- Business rule: Categories classify recipes for filtering and taxation.
-- ============================================
CREATE TABLE Category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- ============================================
-- Suppliers
-- Business rule: Each ingredient is linked to a supplier. Used for restocking logic.
-- ============================================
CREATE TABLE Supplier (
    supplier_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    notes TEXT
);

-- ============================================
-- Ingredients (raw materials for recipes)
-- Business rules:
-- - Stock is reduced after each order is confirmed.
-- - Minimum stock triggers alerts for restocking.
-- ============================================
CREATE TABLE Ingredient (
    ingredient_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    unit_of_measure VARCHAR(20) NOT NULL,
    cost_price DECIMAL(10,2),
    stock_quantity DECIMAL(10,2),
    stock_minimum DECIMAL(10,2),
    reorder_quantity DECIMAL(10,2),
    last_order_date DATE,
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
);

-- ============================================
-- Recipes (used for both Dishes and Drinks)
-- Business rules:
-- - Can be of type: dish, cocktail, combo, etc.
-- - Pricing and ingredients drive dynamic cost calculation.
-- ============================================
CREATE TABLE Recipe (
    recipe_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    base_price DECIMAL(10,2),
    preparation_time TIME,
    category_id INT,
    notes TEXT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id)
);

-- ============================================
-- Recipe Ingredients
-- Business rule: Defines the cost structure and stock consumption logic.
-- ============================================
CREATE TABLE Recipe_Ingredient (
    recipe_id INT,
    ingredient_id INT,
    quantity DECIMAL(10,2),
    PRIMARY KEY (recipe_id, ingredient_id),
    FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id),
    FOREIGN KEY (ingredient_id) REFERENCES Ingredient(ingredient_id)
);

-- ============================================
-- Optional Recipe Additions (e.g., extra cheese, gin base)
-- Business rule: Increases item price and may consume extra ingredients.
-- ============================================
CREATE TABLE Recipe_Addition (
    addition_id INT IDENTITY(1,1) PRIMARY KEY,
    recipe_id INT,
    name VARCHAR(100),
    extra_cost DECIMAL(10,2),
    FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id)
);

CREATE TABLE Addition_Ingredient (
    addition_id INT,
    ingredient_id INT,
    quantity DECIMAL(10,2),
    PRIMARY KEY (addition_id, ingredient_id),
    FOREIGN KEY (addition_id) REFERENCES Recipe_Addition(addition_id),
    FOREIGN KEY (ingredient_id) REFERENCES Ingredient(ingredient_id)
);

-- ============================================
-- Clients and Table Management
-- ============================================
CREATE TABLE Client (
    client_id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100),
    tax_id VARCHAR(15),
    address VARCHAR(255),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    client_type VARCHAR(50)
);

CREATE TABLE Table_Seating (
    table_id INT IDENTITY(1,1) PRIMARY KEY,
    number INT,
    seats INT,
    is_available BIT DEFAULT 1
);

-- ============================================
-- Orders
-- Business rules:
-- - One order may have multiple items and additions.
-- - Stock is only decremented on final confirmation.
-- ============================================
CREATE TABLE Order_Main (
    order_id INT IDENTITY(1,1) PRIMARY KEY,
    table_id INT,
    employee_id INT,
    client_id INT,
    order_datetime DATETIME,
    status VARCHAR(50),
    notes TEXT,
    FOREIGN KEY (table_id) REFERENCES Table_Seating(table_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (client_id) REFERENCES Client(client_id)
);

CREATE TABLE Order_Item (
    order_id INT,
    recipe_id INT,
    quantity INT,
    base_price DECIMAL(10,2),
    PRIMARY KEY (order_id, recipe_id),
    FOREIGN KEY (order_id) REFERENCES Order_Main(order_id),
    FOREIGN KEY (recipe_id) REFERENCES Recipe(recipe_id)
);

CREATE TABLE Order_Item_Addition (
    order_id INT,
    recipe_id INT,
    addition_id INT,
    quantity INT,
    PRIMARY KEY (order_id, recipe_id, addition_id),
    FOREIGN KEY (order_id, recipe_id) REFERENCES Order_Item(order_id, recipe_id),
    FOREIGN KEY (addition_id) REFERENCES Recipe_Addition(addition_id)
);

-- ============================================
-- Invoices
-- Business rules:
-- - Consolidates all order items and additions.
-- - Applies taxes based on category.
-- ============================================
CREATE TABLE Invoice (
    invoice_id INT IDENTITY(1,1) PRIMARY KEY,
    order_id INT,
    invoice_date DATE,
    total_amount DECIMAL(10,2),
    tax_amount DECIMAL(10,2),
    food_tax_rate DECIMAL(5,2),
    drink_tax_rate DECIMAL(5,2),
    FOREIGN KEY (order_id) REFERENCES Order_Main(order_id)
);