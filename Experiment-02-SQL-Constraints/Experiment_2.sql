-- 1. Create Database and Customer Table

CREATE DATABASE e_commerce;
USE e_commerce;

CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50)
);

CREATE TABLE Customer_Email (
    CustomerID INT NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (CustomerID, Email),
    FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
        ON DELETE CASCADE
);


-- 2. Customer Phone and Address Tables

CREATE TABLE Customer_Phone (
    CustomerID INT NOT NULL,
    PhoneNo VARCHAR(15) NOT NULL UNIQUE,
    PRIMARY KEY (CustomerID, PhoneNo),
    FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
        ON DELETE CASCADE
);

CREATE TABLE Address (
    AddressNo INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    HouseNo VARCHAR(50) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50) NOT NULL,
    PINCode INT NOT NULL,
    PRIMARY KEY (CustomerID, HouseNo),
    FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
        ON DELETE CASCADE
);

CREATE TABLE Address_Landmark (
    HouseNo VARCHAR(50) NOT NULL,
    Landmark VARCHAR(150) NOT NULL,
    PRIMARY KEY (HouseNo, Landmark),
    FOREIGN KEY (HouseNo)
        REFERENCES Address(HouseNo)
        ON DELETE CASCADE
);

-- 3. Order and Payment Tables

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    HouseNo VARCHAR(50) NULL,
    OrderDate DATE NOT NULL,
    Status VARCHAR(30) NOT NULL,
    FOREIGN KEY (CustomerID)
        REFERENCES Customer(CustomerID)
        ON DELETE CASCADE,
    FOREIGN KEY (HouseNo)
        REFERENCES Address(HouseNo)
        ON DELETE SET NULL
);

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentDate DATE NOT NULL,
    Method VARCHAR(30) NOT NULL,
    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE
);

-- 4. Delivery, Category and Product Tables

sql
CREATE TABLE Delivery (
    DeliveryID INT PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    HouseNo INT NULL,
    DeliveryDate DATE,
    DeliveryStatus VARCHAR(30) NOT NULL,
    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,
    FOREIGN KEY (HouseNo)
        REFERENCES Address(HouseNo)
        ON DELETE SET NULL
);

CREATE TABLE Category (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description VARCHAR(255)
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY,
    CategoryID INT NULL,
    Name VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL,
    FOREIGN KEY (CategoryID)
        REFERENCES Category(CategoryID)
        ON DELETE SET NULL
);


-- 5. Order_Item Table and View

CREATE TABLE Order_Item (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
        ON DELETE CASCADE,
    FOREIGN KEY (ProductID)
        REFERENCES Product(ProductID)
        ON DELETE CASCADE
);

CREATE VIEW Order_Item_View AS
SELECT
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    UnitPrice * 0.05 AS Discount
FROM Order_Item;

-- 6. Seller Tables

CREATE TABLE Seller (
    SellerID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    MiddleName VARCHAR(50),
    LastName VARCHAR(50) NOT NULL,
    Phone VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE Seller_Email (
    SellerID INT NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (SellerID, Email),
    FOREIGN KEY (SellerID)
        REFERENCES Seller(SellerID)
        ON DELETE CASCADE
);

CREATE TABLE Seller_Category (
    SellerID INT NOT NULL,
    CategoryID INT NOT NULL,
    PRIMARY KEY (SellerID, CategoryID),
    FOREIGN KEY (SellerID)
        REFERENCES Seller(SellerID)
        ON DELETE CASCADE,
    FOREIGN KEY (CategoryID)
        REFERENCES Category(CategoryID)
        ON DELETE CASCADE
);

-- 7. Insert Sample Records

INSERT INTO Customer
    (CustomerID, FirstName, MiddleName, LastName)
VALUES
    (1, 'Aisha', 'K', 'Sharma'),
    (2, 'Rahul', NULL, 'Verma'),
    (3, 'Neha', 'R', 'Singh');

INSERT INTO Customer_Email (CustomerID, Email)
VALUES
    (1, 'aisha@gmail.com'),
    (2, 'rahul@gmail.com'),
    (3, 'neha@gmail.com');

INSERT INTO Customer_Phone (CustomerID, PhoneNo)
VALUES
    (1, '9876543210'),
    (2, '9876543211'),
    (3, '9876543212');

INSERT INTO Address
    (AddressID, CustomerID, HouseNo, City, State, PINCode)
VALUES
    (101, 1, '12A', 'Kanpur', 'Uttar Pradesh', 208001),
    (102, 2, '45B', 'Delhi', 'Delhi', 110001),
    (103, 3, '78C', 'Lucknow', 'Uttar Pradesh', 226001);

-- 8. Display Records

SELECT * FROM Customer;

SELECT * FROM Product;

SELECT * FROM Orders;

SELECT * FROM Order_Item;

SELECT * FROM Order_Item_View;

-- 9. Referential Integrity Violations

--Violation 1: Inserting an order with a non-existent CustomerID

INSERT INTO Orders
    (OrderID, CustomerID, HouseNo, OrderDate, Status)
VALUES
    (404, 999, NULL, '2026-10-03', 'Placed');

-- Violation 2: Inserting an order item with a non-existent ProductID

INSERT INTO Order_Item
    (OrderID, ProductID, Quantity, UnitPrice)
VALUES
    (401, 999, 1, 1000.00);

-- Violation 3: Inserting a duplicate primary key

INSERT INTO Customer
    (CustomerID, FirstName, MiddleName, LastName)
VALUES
    (1, 'Nail', NULL, 'Sharma');

-- Violation 4: Inserting NULL into a NOT NULL column

INSERT INTO Customer
    (CustomerID, FirstName, MiddleName, LastName)
VALUES
    (4, NULL, NULL, 'Gupta');
