# Relational Algebra Expressions

For this project I picked 5 queries that actually get used in the app (they match the stored procedures I wrote), and worked out the relational algebra for each one before writing the SQL. Below is both versions side by side so it's easy to see how the algebra maps to the actual query.

---

### 1. Find products that are low on stock

This is what powers the `sp_low_stock_alert()` procedure. I need product info combined with inventory numbers, then filtered down to just the ones running low.

Relational Algebra:

σ QuantityOnHand ≤ ReorderThreshold ( Products ⋈ Inventory )

Steps in plain English: join Products and Inventory on ProductID, then select only the rows where the quantity on hand has dropped to or below the reorder threshold.

SQL:
```sql
SELECT p.ProductID, p.ProductName, i.QuantityOnHand, i.ReorderThreshold
FROM Inventory i
JOIN Products p ON i.ProductID = p.ProductID
WHERE i.QuantityOnHand <= i.ReorderThreshold;
```

---

### 2. Find all orders placed by one customer

Basic selection query, but it's the base of a lot of other things (like customer lifetime value).

Relational Algebra:

σ CustomerID = X ( Orders )

Steps in plain English: just a straight selection on the Orders table, no join needed since CustomerID already lives there.

SQL:
```sql
SELECT * FROM Orders WHERE CustomerID = 1;
```

---

### 3. Get product names along with their category names

Used this one to double check the self-referencing Category relationship was actually working right.

Relational Algebra:

π ProductName, CategoryName ( Products ⋈ Categories )

Steps in plain English: join Products to Categories on CategoryID, then project down to just the two columns I actually want to see.

SQL:
```sql
SELECT p.ProductName, c.CategoryName
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID;
```

---

### 4. Find customers who have never placed an order

Wanted to be able to see who's basically dead weight in the customer list (no orders at all).

Relational Algebra:

π CustomerID ( Customers ) − π CustomerID ( Orders )

Steps in plain English: take the set of all customer IDs, subtract out the set of customer IDs that show up in Orders. Whatever's left over are customers with zero orders.

SQL:
```sql
SELECT CustomerID FROM Customers
WHERE CustomerID NOT IN (SELECT CustomerID FROM Orders);
```

---

### 5. Total revenue per category, for a given month

This is the one behind `sp_monthly_revenue_by_category()`. It's the most involved one since it needs three joins.

Relational Algebra:

γ CategoryName; SUM(Quantity × UnitPrice) ( Orders ⋈ OrderItems ⋈ Products ⋈ Categories )

Steps in plain English: join all four tables together (Orders to OrderItems to Products to Categories), then group by category name and sum up quantity times unit price for the revenue total. The γ symbol here is the aggregation/grouping operator.

SQL:
```sql
SELECT
    c.CategoryName,
    SUM(oi.Quantity * oi.UnitPrice) AS Revenue,
    COUNT(DISTINCT o.OrderID) AS OrderCount
FROM Orders o
JOIN OrderItems oi ON o.OrderID = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE YEAR(o.OrderDate) = 2026 AND MONTH(o.OrderDate) = 8
GROUP BY c.CategoryName
ORDER BY Revenue DESC;
```

---
