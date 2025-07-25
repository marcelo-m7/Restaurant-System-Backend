-- ============================================
-- Stored Procedures for Order Handling
-- ============================================

-- 1. sp_CreateOrder: Inserts a new order with items and additions
CREATE PROCEDURE sp_CreateOrder
    @table_id INT,
    @employee_id INT,
    @client_id INT = NULL,
    @notes NVARCHAR(MAX) = NULL,
    @order_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Order_Main (table_id, employee_id, client_id, order_datetime, status, notes)
    VALUES (@table_id, @employee_id, @client_id, GETDATE(), 'Pending', @notes);
    SET @order_id = SCOPE_IDENTITY();
    PRINT 'sp_CreateOrder executed successfully. New Order ID: ' + CAST(@order_id AS VARCHAR(10));
END
GO

-- 2. sp_AddOrderItem: Adds or updates an item in an existing order
CREATE PROCEDURE sp_AddOrderItem
    @order_id INT,
    @recipe_id INT,
    @quantity INT,
    @base_price DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM Order_Item WHERE order_id = @order_id AND recipe_id = @recipe_id)
    BEGIN
        UPDATE Order_Item
        SET quantity = quantity + @quantity
        WHERE order_id = @order_id AND recipe_id = @recipe_id;
        PRINT 'sp_AddOrderItem: Quantity updated for Order ' + CAST(@order_id AS VARCHAR(10)) + ', Recipe ' + CAST(@recipe_id AS VARCHAR(10));
    END
    ELSE
    BEGIN
        INSERT INTO Order_Item (order_id, recipe_id, quantity, base_price)
        VALUES (@order_id, @recipe_id, @quantity, @base_price);
        PRINT 'sp_AddOrderItem: New item added for Order ' + CAST(@order_id AS VARCHAR(10)) + ', Recipe ' + CAST(@recipe_id AS VARCHAR(10));
    END
END
GO

-- 3. sp_AddOrderAddition: Adds an addition to a specific order item
CREATE PROCEDURE sp_AddOrderAddition
    @order_id INT,
    @recipe_id INT,
    @addition_id INT,
    @quantity INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Order_Item_Addition (order_id, recipe_id, addition_id, quantity)
    VALUES (@order_id, @recipe_id, @addition_id, @quantity);
    PRINT 'sp_AddOrderAddition: Addition ' + CAST(@addition_id AS VARCHAR(10)) + ' added to Order ' + CAST(@order_id AS VARCHAR(10));
END
GO

-- 4. sp_ConfirmOrder: Marks order confirmed and updates stock
CREATE PROCEDURE sp_ConfirmOrder
    @order_id INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Order_Main SET status = 'Confirmed' WHERE order_id = @order_id;

    -- Decrement stock for each recipe ingredient
    DECLARE @ing_id INT, @qty DECIMAL(10,2);
    DECLARE ingred_cursor CURSOR FOR
        SELECT ri.ingredient_id, ri.quantity * oi.quantity
        FROM Order_Item oi
        JOIN Recipe_Ingredient ri ON oi.recipe_id = ri.recipe_id
        WHERE oi.order_id = @order_id;
    OPEN ingred_cursor;
    FETCH NEXT FROM ingred_cursor INTO @ing_id, @qty;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE Ingredient
        SET stock_quantity = stock_quantity - @qty
        WHERE ingredient_id = @ing_id;
        FETCH NEXT FROM ingred_cursor INTO @ing_id, @qty;
    END;
    CLOSE ingred_cursor;
    DEALLOCATE ingred_cursor;

    -- Decrement stock for addition ingredients
    DECLARE add_cursor CURSOR FOR
        SELECT ai.ingredient_id, ai.quantity * oia.quantity
        FROM Order_Item_Addition oia
        JOIN Addition_Ingredient ai ON oia.addition_id = ai.addition_id
        WHERE oia.order_id = @order_id;
    OPEN add_cursor;
    FETCH NEXT FROM add_cursor INTO @ing_id, @qty;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        UPDATE Ingredient
        SET stock_quantity = stock_quantity - @qty
        WHERE ingredient_id = @ing_id;
        FETCH NEXT FROM add_cursor INTO @ing_id, @qty;
    END;
    CLOSE add_cursor;
    DEALLOCATE add_cursor;

    PRINT 'sp_ConfirmOrder executed: Order ' + CAST(@order_id AS VARCHAR(10)) + ' confirmed and stock updated.';
END
GO

-- 5. sp_CancelOrder: Cancels an order and optionally restores stock
CREATE PROCEDURE sp_CancelOrder
    @order_id INT,
    @restore_stock BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    -- Optionally restore stock before canceling
    IF @restore_stock = 1
    BEGIN
        DECLARE @temp_id INT, @temp_qty DECIMAL(10,2);
        DECLARE restore_ing CURSOR FOR
            SELECT ri.ingredient_id, ri.quantity * oi.quantity
            FROM Order_Item oi
            JOIN Recipe_Ingredient ri ON oi.recipe_id = ri.recipe_id
            WHERE oi.order_id = @order_id;
        OPEN restore_ing;
        FETCH NEXT FROM restore_ing INTO @temp_id, @temp_qty;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE Ingredient
            SET stock_quantity = stock_quantity + @temp_qty
            WHERE ingredient_id = @temp_id;
            FETCH NEXT FROM restore_ing INTO @temp_id, @temp_qty;
        END;
        CLOSE restore_ing;
        DEALLOCATE restore_ing;

        DECLARE restore_add CURSOR FOR
            SELECT ai.ingredient_id, ai.quantity * oia.quantity
            FROM Order_Item_Addition oia
            JOIN Addition_Ingredient ai ON oia.addition_id = ai.addition_id
            WHERE oia.order_id = @order_id;
        OPEN restore_add;
        FETCH NEXT FROM restore_add INTO @temp_id, @temp_qty;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE Ingredient
            SET stock_quantity = stock_quantity + @temp_qty
            WHERE ingredient_id = @temp_id;
            FETCH NEXT FROM restore_add INTO @temp_id, @temp_qty;
        END;
        CLOSE restore_add;
        DEALLOCATE restore_add;

        PRINT 'sp_CancelOrder: Stock restored for Order ' + CAST(@order_id AS VARCHAR(10));
    END

    UPDATE Order_Main SET status = 'Canceled' WHERE order_id = @order_id;
    PRINT 'sp_CancelOrder executed: Order ' + CAST(@order_id AS VARCHAR(10)) + ' canceled.';
END
GO

-- ============================================
-- SP: Generate Invoice
-- Calculates total + tax, and inserts into Invoice table
-- ============================================
CREATE PROCEDURE sp_GenerateInvoice
    @order_id INT,
    @food_tax_rate DECIMAL(5,2),
    @drink_tax_rate DECIMAL(5,2),
    @invoice_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @total_food DECIMAL(10,2) = 0;
    DECLARE @total_drink DECIMAL(10,2) = 0;
    DECLARE @tax_amount DECIMAL(10,2);
    DECLARE @total_amount DECIMAL(10,2);

    -- Total base price of recipes, grouped by category
    SELECT
        @total_food = SUM(oi.quantity * oi.base_price)
    FROM Order_Item oi
    JOIN Recipe r ON oi.recipe_id = r.recipe_id
    JOIN Category c ON r.category_id = c.category_id
    WHERE oi.order_id = @order_id AND c.name = 'Food';

    SELECT
        @total_drink = SUM(oi.quantity * oi.base_price)
    FROM Order_Item oi
    JOIN Recipe r ON oi.recipe_id = r.recipe_id
    JOIN Category c ON r.category_id = c.category_id
    WHERE oi.order_id = @order_id AND c.name = 'Drink';

    SET @tax_amount = (@total_food * @food_tax_rate / 100) + (@total_drink * @drink_tax_rate / 100);
    SET @total_amount = @total_food + @total_drink + @tax_amount;

    INSERT INTO Invoice (order_id, invoice_date, total_amount, tax_amount, food_tax_rate, drink_tax_rate)
    VALUES (@order_id, GETDATE(), @total_amount, @tax_amount, @food_tax_rate, @drink_tax_rate);

    SET @invoice_id = SCOPE_IDENTITY();
    PRINT 'sp_GenerateInvoice executed: Invoice ' + CAST(@invoice_id AS VARCHAR(10)) + ' created.';
END
GO

-- ============================================
-- VIEW: Ingredients Below Minimum Stock
-- ============================================
CREATE VIEW vw_IngredientesAbaixoEstoqueMinimo AS
SELECT
    i.ingredient_id,
    i.name,
    i.stock_quantity,
    i.stock_minimum,
    (i.stock_minimum - i.stock_quantity) AS shortage,
    s.name AS supplier_name
FROM Ingredient i
LEFT JOIN Supplier s ON i.supplier_id = s.supplier_id
WHERE i.stock_quantity < i.stock_minimum;
GO
