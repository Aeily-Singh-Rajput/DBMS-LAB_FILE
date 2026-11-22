-- Experiment 7: Functional Dependencies and Database Normalization
-- DBMS: MySQL
-- Aim: Normalize a denormalized Sales table from UNF to 3NF and verify BCNF,
-- lossless join, and dependency preservation.

CREATE DATABASE IF NOT EXISTS SalesDB;
USE SalesDB;

-- Clean up objects so the script can be executed again.
DROP TABLE IF EXISTS OrderDetails;
DROP TABLE IF EXISTS Orders_3NF;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Sales_1NF;
DROP TABLE IF EXISTS Sales_UNF;

-- 1. Create the denormalized table (UNF).
CREATE TABLE Sales_UNF (
    OrderID INT,
    OrderDate DATE,
    CustomerID INT,
    CustomerName VARCHAR(50),
    ProductID VARCHAR(100),
    ProductName VARCHAR(200),
    Quantity VARCHAR(100),
    Price VARCHAR(100)
);

INSERT INTO Sales_UNF VALUES
(101, '2026-01-10', 1, 'Arjun Mehta',
 'P1,P2', 'Laptop,Mouse', '1,2', '50000,500'),
(102, '2026-01-11', 2, 'Kavya Sharma',
 'P2,P3', 'Mouse,Keyboard', '1,1', '500,1000'),
(103, '2026-01-12', 3, 'Ishita Verma',
 'P3', 'Keyboard', '2', '1000');

SELECT * FROM Sales_UNF;

-- 2. Functional dependencies:
-- order_id -> order_date, customer_id
-- customer_id -> customer_name
-- product_id -> product_name, price
-- (order_id, product_id) -> quantity
-- Candidate key of the order-details relation: (order_id, product_id).

-- 3. Convert UNF to 1NF.
-- Each product is stored in a separate row and all attributes are atomic.
CREATE TABLE Sales_1NF (
    order_id INT,
    order_date DATE,
    customer_id INT,
    customer_name VARCHAR(50),
    product_id VARCHAR(10),
    product_name VARCHAR(50),
    quantity INT,
    price DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO Sales_1NF VALUES
(101, '2026-01-10', 1, 'Arjun Mehta', 'P1', 'Laptop', 1, 50000),
(101, '2026-01-10', 1, 'Arjun Mehta', 'P2', 'Mouse', 2, 500),
(102, '2026-01-11', 2, 'Kavya Sharma', 'P2', 'Mouse', 1, 500),
(102, '2026-01-11', 2, 'Kavya Sharma', 'P3', 'Keyboard', 1, 1000),
(103, '2026-01-12', 3, 'Ishita Verma', 'P3', 'Keyboard', 2, 1000);

SELECT * FROM Sales_1NF;

-- 4. Convert 1NF to 2NF.
-- Remove partial dependencies on order_id and product_id.
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    customer_name VARCHAR(50)
);

CREATE TABLE Products (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE OrderDetails (
    order_id INT,
    product_id VARCHAR(10),
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

INSERT INTO Orders VALUES
(101, '2026-01-10', 1, 'Arjun Mehta'),
(102, '2026-01-11', 2, 'Kavya Sharma'),
(103, '2026-01-12', 3, 'Ishita Verma');

INSERT INTO Products VALUES
('P1', 'Laptop', 50000),
('P2', 'Mouse', 500),
('P3', 'Keyboard', 1000);

INSERT INTO OrderDetails VALUES
(101, 'P1', 1),
(101, 'P2', 2),
(102, 'P2', 1),
(102, 'P3', 1),
(103, 'P3', 2);

SELECT * FROM Orders;
SELECT * FROM Products;
SELECT * FROM OrderDetails;

-- 5. Convert 2NF to 3NF.
-- Remove the transitive dependency:
-- order_id -> customer_id -> customer_name.
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50)
);

INSERT INTO Customers VALUES
(1, 'Arjun Mehta'),
(2, 'Kavya Sharma'),
(3, 'Ishita Verma');

CREATE TABLE Orders_3NF (
    order_id INT PRIMARY KEY,
    order_date DATE,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

INSERT INTO Orders_3NF VALUES
(101, '2026-01-10', 1),
(102, '2026-01-11', 2),
(103, '2026-01-12', 3);

SELECT * FROM Customers;
SELECT * FROM Orders_3NF;

-- 6. Reconstruct and verify the normalized data using joins.
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_name,
    od.quantity,
    p.price
FROM Orders_3NF o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
JOIN Products p ON od.product_id = p.product_id
ORDER BY o.order_id, p.product_id;

-- 7. Lossless-join verification.
-- The join above reconstructs the original 1NF sales rows.
-- Compare the number of rows in the original 1NF relation and reconstruction.
SELECT COUNT(*) AS original_1nf_rows
FROM Sales_1NF;

SELECT COUNT(*) AS reconstructed_rows
FROM Orders_3NF o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
JOIN Products p ON od.product_id = p.product_id;

-- Check for original 1NF rows missing from the reconstructed relation.
SELECT s.*
FROM Sales_1NF s
WHERE NOT EXISTS (
    SELECT 1
    FROM Orders_3NF o
    JOIN Customers c ON o.customer_id = c.customer_id
    JOIN OrderDetails od ON o.order_id = od.order_id
    JOIN Products p ON od.product_id = p.product_id
    WHERE o.order_id = s.order_id
      AND o.order_date = s.order_date
      AND c.customer_id = s.customer_id
      AND c.customer_name = s.customer_name
      AND p.product_id = s.product_id
      AND p.product_name = s.product_name
      AND od.quantity = s.quantity
      AND p.price = s.price
);

-- 8. Dependency-preservation checks.
-- Each query should return no rows if the stated dependency holds.
-- order_id -> order_date, customer_id
SELECT order_id
FROM Orders_3NF
GROUP BY order_id
HAVING COUNT(DISTINCT order_date) > 1
    OR COUNT(DISTINCT customer_id) > 1;

-- customer_id -> customer_name
SELECT customer_id
FROM Customers
GROUP BY customer_id
HAVING COUNT(DISTINCT customer_name) > 1;

-- product_id -> product_name, price
SELECT product_id
FROM Products
GROUP BY product_id
HAVING COUNT(DISTINCT product_name) > 1
    OR COUNT(DISTINCT price) > 1;

-- (order_id, product_id) -> quantity
SELECT order_id, product_id
FROM OrderDetails
GROUP BY order_id, product_id
HAVING COUNT(DISTINCT quantity) > 1;

-- 9. BCNF verification.
-- In each final relation, every determinant in the stated non-trivial
-- functional dependencies is a candidate key:
-- Customers: customer_id -> customer_name
-- Orders_3NF: order_id -> order_date, customer_id
-- Products: product_id -> product_name, price
-- OrderDetails: (order_id, product_id) -> quantity
-- Therefore, all final relations satisfy BCNF under the stated FDs.
