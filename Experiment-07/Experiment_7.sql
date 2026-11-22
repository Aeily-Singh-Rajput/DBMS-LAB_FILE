-- DATABASE CREATING

CREATE DATABASE SalesDB;

USE SalesDB;


-- CREATE A DENORMALIZED SALES TABLE

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

-- OUTPUT:
SELECT * FROM Sales_UNF;


-- FUNCTIONAL DEPENDENCIES
-- The assumed functional dependencies are:
-- order_id -> order_date, customer_id
-- customer_id -> customer_name
-- product_id -> product_name
-- (order_id, product_id) -> quantity
-- The candidate key for the normalized order-details relation is (order_id, product_id).


-- CONVERT TO 1NF

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
(101, '2026-01-10', 1, 'Arjun Mehta', 'P1', 'Laptop', 1,50000),
(101, '2026-01-10', 1, 'Arjun Mehta', 'P2', 'Mouse', 2, 500),
(102, '2026-01-11', 2, 'Kavya Sharma', 'P2', 'Mouse', 1, 500),
(102, '2026-01-11', 2, 'Kavya Sharma', 'P3', 'Keyboard', 1, 1000),
(103, '2026-01-12', 3, 'Ishita Verma', 'P3', 'Keyboard', 2, 1000);

-- OUTPUT:
SELECT * FROM Sales_1NF;


-- CONVERT TO 2NF

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

-- OUTPUT:
SELECT * FROM Orders;
SELECT * FROM Products;
SELECT * FROM OrderDetails;


-- CONVERT TO 3NF

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

-- OUTPUT:
SELECT * FROM Customers;
SELECT * FROM Orders_3NF;


-- VERIFY THE NORMALIZED DATA

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
JOIN Customers c
    ON o.customer_id = c.customer_id
JOIN OrderDetails od
    ON o.order_id = od.order_id
JOIN Products p
    ON od.product_id = p.product_id
ORDER BY o.order_id, p.product_id;


-- VERIFY LOSSLESS JOIN AND DEPENDENCY PRESERVATION

-- LOSSLESS JOIN:

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
JOIN Customers c
    ON o.customer_id = c.customer_id
JOIN OrderDetails od
    ON o.order_id = od.order_id
JOIN Products p
    ON od.product_id = p.product_id
ORDER BY o.order_id, p.product_id;


-- DEPENDENCY PRESERVATION:

-- order_id -> order_date, customer_id
SELECT order_id, COUNT(DISTINCT order_date), COUNT(DISTINCT customer_id)
FROM Orders_3NF
GROUP BY order_id;

-- customer_id -> customer_name
SELECT customer_id, COUNT(DISTINCT customer_name)
FROM Customers
GROUP BY customer_id;

-- product_id -> product_name, price
SELECT product_id, COUNT(DISTINCT product_name), COUNT(DISTINCT price)
FROM Products
GROUP BY product_id;

-- (order_id, product_id) -> quantity
SELECT order_id, product_id, COUNT(DISTINCT quantity)
FROM OrderDetails
GROUP BY order_id, product_id;
