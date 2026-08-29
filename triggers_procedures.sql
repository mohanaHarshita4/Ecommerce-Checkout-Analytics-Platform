USE ecommerce_analytics;

-- =====================================================
-- TRIGGERS
-- =====================================================

-- 1) Decrement inventory automatically when an order item is inserted
DELIMITER $$
CREATE TRIGGER trg_decrement_inventory
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    UPDATE Inventory
    SET QuantityOnHand = QuantityOnHand - NEW.Quantity
    WHERE ProductID = NEW.ProductID;
END$$
DELIMITER ;

-- 2) Prevent an order item from being inserted if it would oversell stock
DELIMITER $$
CREATE TRIGGER trg_block_oversell
BEFORE INSERT ON OrderItems
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;
    SELECT QuantityOnHand INTO current_stock
    FROM Inventory WHERE ProductID = NEW.ProductID;

    IF current_stock < NEW.Quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient inventory for this product';
    END IF;
END$$
DELIMITER ;

-- 3) Recalculate Orders.TotalAmount whenever an order item is added
DELIMITER $$
CREATE TRIGGER trg_update_order_total
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET TotalAmount = (
        SELECT SUM(Quantity * UnitPrice) FROM OrderItems WHERE OrderID = NEW.OrderID
    )
    WHERE OrderID = NEW.OrderID;
END$$
DELIMITER ;

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- 1) Monthly revenue rollup by category
DELIMITER $$
CREATE PROCEDURE sp_monthly_revenue_by_category(IN in_year INT, IN in_month INT)
BEGIN
    SELECT
        c.CategoryName,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue,
        COUNT(DISTINCT o.OrderID) AS OrderCount
    FROM Orders o
    JOIN OrderItems oi ON o.OrderID = oi.OrderID
    JOIN Products p ON oi.ProductID = p.ProductID
    JOIN Categories c ON p.CategoryID = c.CategoryID
    WHERE YEAR(o.OrderDate) = in_year AND MONTH(o.OrderDate) = in_month
    GROUP BY c.CategoryName
    ORDER BY Revenue DESC;
END$$
DELIMITER ;

-- 2) Customer lifetime value
DELIMITER $$
CREATE PROCEDURE sp_customer_lifetime_value(IN in_customer_id INT)
BEGIN
    SELECT
        cu.CustomerID,
        cu.FirstName,
        cu.LastName,
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        COALESCE(SUM(o.TotalAmount), 0) AS LifetimeValue
    FROM Customers cu
    LEFT JOIN Orders o ON cu.CustomerID = o.CustomerID
    WHERE cu.CustomerID = in_customer_id
    GROUP BY cu.CustomerID, cu.FirstName, cu.LastName;
END$$
DELIMITER ;

-- 3) Low stock alert list
DELIMITER $$
CREATE PROCEDURE sp_low_stock_alert()
BEGIN
    SELECT p.ProductID, p.ProductName, i.QuantityOnHand, i.ReorderThreshold
    FROM Inventory i
    JOIN Products p ON i.ProductID = p.ProductID
    WHERE i.QuantityOnHand <= i.ReorderThreshold;
END$$
DELIMITER ;

-- =====================================================
-- TRANSACTION / CONCURRENCY DEMO
-- Simulates two customers racing to buy the last units of stock.
-- Run this block, then in a second session run the same block
-- concurrently to see row locking behavior in action.
-- =====================================================

START TRANSACTION;

SELECT QuantityOnHand FROM Inventory WHERE ProductID = 5 FOR UPDATE;

-- Application checks in code: is QuantityOnHand >= requested quantity?
-- If yes:
INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice)
VALUES (3, 5, 2, 199.99);

COMMIT;
-- If the check fails, issue ROLLBACK instead of COMMIT.

-- =====================================================
-- Sample queries to demo for the class / report
-- =====================================================

-- Call the procedures
-- CALL sp_monthly_revenue_by_category(2026, 8);
-- CALL sp_customer_lifetime_value(1);
-- CALL sp_low_stock_alert();
