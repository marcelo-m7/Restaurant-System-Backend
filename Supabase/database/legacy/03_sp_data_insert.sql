-- ============================================
-- Stored Procedures for Data Registration (CRUD - Insert Operations)
-- ============================================

-- Insert Category
CREATE PROCEDURE sp_InsertCategory
    @name VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Category (name)
    VALUES (@name);
    PRINT 'sp_InsertCategory executed: Category ' + @name + ' inserted.';
END
GO

-- Insert Supplier
CREATE PROCEDURE sp_InsertSupplier
    @name VARCHAR(100),
    @email VARCHAR(100) = NULL,
    @phone VARCHAR(20) = NULL,
    @notes TEXT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Supplier (name, email, phone, notes)
    VALUES (@name, @email, @phone, @notes);
    PRINT 'sp_InsertSupplier executed: Supplier ' + @name + ' inserted.';
END
GO

-- Insert Ingredient
CREATE PROCEDURE sp_InsertIngredient
    @name VARCHAR(100),
    @unit_of_measure VARCHAR(20),
    @cost_price DECIMAL(10,2),
    @stock_quantity DECIMAL(10,2),
    @stock_minimum DECIMAL(10,2),
    @reorder_quantity DECIMAL(10,2),
    @last_order_date DATE = NULL,
    @supplier_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Ingredient (name, unit_of_measure, cost_price, stock_quantity,
                             stock_minimum, reorder_quantity, last_order_date, supplier_id)
    VALUES (@name, @unit_of_measure, @cost_price, @stock_quantity,
            @stock_minimum, @reorder_quantity, @last_order_date, @supplier_id);
    PRINT 'sp_InsertIngredient executed: Ingredient ' + @name + ' inserted.';
END
GO

-- Insert Recipe
CREATE PROCEDURE sp_InsertRecipe
    @name VARCHAR(100),
    @type VARCHAR(50),
    @base_price DECIMAL(10,2),
    @preparation_time TIME,
    @category_id INT = NULL,
    @notes TEXT = NULL,
    @recipe_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Recipe (name, type, base_price, preparation_time, category_id, notes)
    VALUES (@name, @type, @base_price, @preparation_time, @category_id, @notes);
    SET @recipe_id = SCOPE_IDENTITY();
    PRINT 'sp_InsertRecipe executed: Recipe ID ' + CAST(@recipe_id AS VARCHAR(10)) + ' inserted.';
END
GO

-- Insert Recipe Ingredient
CREATE PROCEDURE sp_InsertRecipeIngredient
    @recipe_id INT,
    @ingredient_id INT,
    @quantity DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Recipe_Ingredient (recipe_id, ingredient_id, quantity)
    VALUES (@recipe_id, @ingredient_id, @quantity);
    PRINT 'sp_InsertRecipeIngredient executed: Ingredient ' + CAST(@ingredient_id AS VARCHAR(10)) +
          ' added to Recipe ' + CAST(@recipe_id AS VARCHAR(10));
END
GO

-- Insert Recipe Addition
CREATE PROCEDURE sp_InsertRecipeAddition
    @recipe_id INT,
    @name VARCHAR(100),
    @extra_cost DECIMAL(10,2),
    @addition_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Recipe_Addition (recipe_id, name, extra_cost)
    VALUES (@recipe_id, @name, @extra_cost);
    SET @addition_id = SCOPE_IDENTITY();
    PRINT 'sp_InsertRecipeAddition executed: Addition ID ' + CAST(@addition_id AS VARCHAR(10)) + ' inserted.';
END
GO

-- Insert Addition Ingredient
CREATE PROCEDURE sp_InsertAdditionIngredient
    @addition_id INT,
    @ingredient_id INT,
    @quantity DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Addition_Ingredient (addition_id, ingredient_id, quantity)
    VALUES (@addition_id, @ingredient_id, @quantity);
    PRINT 'sp_InsertAdditionIngredient executed: Ingredient ' + CAST(@ingredient_id AS VARCHAR(10)) +
          ' added to Addition ' + CAST(@addition_id AS VARCHAR(10));
END
GO

-- Insert Client
CREATE PROCEDURE sp_InsertClient
    @name VARCHAR(100),
    @tax_id VARCHAR(15) = NULL,
    @address VARCHAR(255) = NULL,
    @city VARCHAR(100) = NULL,
    @postal_code VARCHAR(20) = NULL,
    @client_type VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Client (name, tax_id, address, city, postal_code, client_type)
    VALUES (@name, @tax_id, @address, @city, @postal_code, @client_type);
    PRINT 'sp_InsertClient executed: Client ' + @name + ' inserted.';
END
GO

-- Insert Table Seating
CREATE PROCEDURE sp_InsertTableSeating
    @number INT,
    @seats INT,
    @is_available BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Table_Seating (number, seats, is_available)
    VALUES (@number, @seats, @is_available);
    PRINT 'sp_InsertTableSeating executed: Table ' + CAST(@number AS VARCHAR(10)) + ' inserted.';
END
GO
