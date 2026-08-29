-- =====================================================
-- E-Commerce Analytics Platform (solo project scope)
-- =====================================================

DROP DATABASE IF EXISTS ecommerce_analytics;
CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

-- ---------------------------------------------------
-- CUSTOMERS
-- ---------------------------------------------------
CREATE TABLE Customers (
    CustomerID      INT AUTO_INCREMENT PRIMARY KEY,
    FirstName       VARCHAR(50)  NOT NULL,
    LastName        VARCHAR(50)  NOT NULL,
    Email           VARCHAR(100) NOT NULL UNIQUE,
    Phone           VARCHAR(20),
    JoinDate        DATE NOT NULL,
    City            VARCHAR(50),
    State           VARCHAR(50)
);

-- ---------------------------------------------------
-- CATEGORIES (self referencing for subcategories)
-- ---------------------------------------------------
CREATE TABLE Categories (
    CategoryID       INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName     VARCHAR(100) NOT NULL,
    ParentCategoryID INT NULL,
    CONSTRAINT fk_category_parent FOREIGN KEY (ParentCategoryID)
        REFERENCES Categories(CategoryID) ON DELETE SET NULL
);

-- ---------------------------------------------------
-- PRODUCTS
-- ---------------------------------------------------
CREATE TABLE Products (
    ProductID       INT AUTO_INCREMENT PRIMARY KEY,
    ProductName     VARCHAR(150) NOT NULL,
    CategoryID      INT NOT NULL,
    Price           DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Description     TEXT,
    CONSTRAINT fk_product_category FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID)
);

-- ---------------------------------------------------
-- INVENTORY (1 to 1 with Products)
-- ---------------------------------------------------
CREATE TABLE Inventory (
    ProductID          INT PRIMARY KEY,
    QuantityOnHand     INT NOT NULL DEFAULT 0 CHECK (QuantityOnHand >= 0),
    ReorderThreshold   INT NOT NULL DEFAULT 10,
    LastRestocked       DATE,
    CONSTRAINT fk_inventory_product FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID) ON DELETE CASCADE
);

-- ---------------------------------------------------
-- PROMOTIONS
-- ---------------------------------------------------
CREATE TABLE Promotions (
    PromotionID     INT AUTO_INCREMENT PRIMARY KEY,
    PromoName       VARCHAR(100) NOT NULL,
    DiscountPercent DECIMAL(5,2) NOT NULL CHECK (DiscountPercent BETWEEN 0 AND 100),
    StartDate       DATE NOT NULL,
    EndDate         DATE NOT NULL,
    CHECK (EndDate >= StartDate)
);

-- ---------------------------------------------------
-- PRODUCT_PROMOTIONS (many to many junction)
-- ---------------------------------------------------
CREATE TABLE ProductPromotions (
    ProductID    INT NOT NULL,
    PromotionID  INT NOT NULL,
    PRIMARY KEY (ProductID, PromotionID),
    CONSTRAINT fk_pp_product FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID) ON DELETE CASCADE,
    CONSTRAINT fk_pp_promotion FOREIGN KEY (PromotionID)
        REFERENCES Promotions(PromotionID) ON DELETE CASCADE
);

-- ---------------------------------------------------
-- ORDERS (shipping address kept as plain fields to avoid
-- a separate Addresses entity in the solo scope)
-- ---------------------------------------------------
CREATE TABLE Orders (
    OrderID            INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID         INT NOT NULL,
    ShippingAddress    VARCHAR(150) NOT NULL,
    ShippingCity       VARCHAR(50)  NOT NULL,
    ShippingState      VARCHAR(50)  NOT NULL,
    OrderDate          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Status             ENUM('Pending','Processing','Shipped','Delivered','Cancelled') NOT NULL DEFAULT 'Pending',
    TotalAmount        DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_order_customer FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID)
);

-- ---------------------------------------------------
-- ORDER_ITEMS (weak entity, depends on Orders)
-- ---------------------------------------------------
CREATE TABLE OrderItems (
    OrderItemID     INT AUTO_INCREMENT PRIMARY KEY,
    OrderID         INT NOT NULL,
    ProductID       INT NOT NULL,
    Quantity        INT NOT NULL CHECK (Quantity > 0),
    UnitPrice       DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_oi_order FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID) ON DELETE CASCADE,
    CONSTRAINT fk_oi_product FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);

-- ---------------------------------------------------
-- REVIEWS (rating stays relational, free text review lives in MongoDB)
-- ---------------------------------------------------
CREATE TABLE Reviews (
    ReviewID        INT AUTO_INCREMENT PRIMARY KEY,
    ProductID       INT NOT NULL,
    CustomerID      INT NOT NULL,
    Rating          TINYINT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    ReviewDate      DATE NOT NULL,
    CONSTRAINT fk_review_product FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID) ON DELETE CASCADE,
    CONSTRAINT fk_review_customer FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

-- ---------------------------------------------------
-- INDEXES
-- ---------------------------------------------------
CREATE INDEX idx_orders_customer_date ON Orders(CustomerID, OrderDate);
CREATE INDEX idx_orderitems_product ON OrderItems(ProductID);
CREATE INDEX idx_products_category ON Products(CategoryID);
CREATE INDEX idx_reviews_product ON Reviews(ProductID);
