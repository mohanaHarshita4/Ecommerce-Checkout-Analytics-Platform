USE ecommerce_analytics;

-- Customers
INSERT INTO Customers (FirstName, LastName, Email, Phone, JoinDate, City, State) VALUES
('Ana','Ruiz','ana.ruiz@mail.com','617-555-0101','2024-01-15','Boston','MA'),
('Ben','Carter','ben.carter@mail.com','215-555-0102','2024-02-20','Philadelphia','PA'),
('Chen','Wu','chen.wu@mail.com','617-555-0103','2024-03-05','Boston','MA'),
('Diana','Lopez','diana.lopez@mail.com','215-555-0104','2024-04-10','Philadelphia','PA'),
('Evan','Shah','evan.shah@mail.com','617-555-0105','2024-05-22','Boston','MA');

-- Categories (with one subcategory to demonstrate self reference)
INSERT INTO Categories (CategoryName, ParentCategoryID) VALUES
('Electronics', NULL),
('Headphones', 1),
('Home Goods', NULL),
('Kitchen', 3);

-- Products
INSERT INTO Products (ProductName, CategoryID, Price, Description) VALUES
('Wireless Earbuds', 2, 59.99, 'Bluetooth 5.2 earbuds with charging case'),
('Noise Cancelling Headphones', 2, 129.99, 'Over ear ANC headphones'),
('Smart Speaker', 1, 49.99, 'Voice controlled smart speaker'),
('Ceramic Knife Set', 4, 34.99, '5 piece ceramic knife set'),
('Stand Mixer', 4, 199.99, '6 quart stand mixer');

-- Inventory
INSERT INTO Inventory (ProductID, QuantityOnHand, ReorderThreshold, LastRestocked) VALUES
(1, 150, 20, '2026-08-01'),
(2, 40, 10, '2026-08-05'),
(3, 5, 15, '2026-07-20'),
(4, 80, 20, '2026-08-10'),
(5, 12, 5, '2026-08-15');

-- Promotions
INSERT INTO Promotions (PromoName, DiscountPercent, StartDate, EndDate) VALUES
('Back to School', 15.00, '2026-08-15', '2026-09-15'),
('Flash Sale', 25.00, '2026-08-25', '2026-08-31');

INSERT INTO ProductPromotions (ProductID, PromotionID) VALUES
(1, 1), (2, 1), (3, 2);

-- Orders (shipping address stored directly, no separate Addresses table)
INSERT INTO Orders (CustomerID, ShippingAddress, ShippingCity, ShippingState, OrderDate, Status, TotalAmount) VALUES
(1, '12 Beacon St', 'Boston', 'MA', '2026-08-20 10:15:00', 'Delivered', 59.99),
(2, '45 Market St', 'Philadelphia', 'PA', '2026-08-22 14:30:00', 'Shipped', 129.99),
(3, '88 Boylston St', 'Boston', 'MA', '2026-08-24 09:00:00', 'Processing', 84.98);

-- Order Items
INSERT INTO OrderItems (OrderID, ProductID, Quantity, UnitPrice) VALUES
(1, 1, 1, 59.99),
(2, 2, 1, 129.99),
(3, 1, 1, 59.99),
(3, 4, 1, 34.99);

-- Reviews
INSERT INTO Reviews (ProductID, CustomerID, Rating, ReviewDate) VALUES
(1, 1, 5, '2026-08-23'),
(2, 2, 4, '2026-08-25');
