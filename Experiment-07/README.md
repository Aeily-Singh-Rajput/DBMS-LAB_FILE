# Experiment 7: Functional Dependencies and Database Normalization

## Aim
To identify functional dependencies in a denormalized Sales table and normalize it step-by-step from UNF to 3NF and BCNF. To verify lossless join and dependency preservation using SQL queries.

## Description
This experiment uses a denormalized Sales table containing order, customer, and product information. The data is transformed into First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF). SQL JOIN queries are used to display the normalized data together, and grouped queries are used to examine the stated functional dependencies.

## Database Used
`SalesDB`

## Functional Dependencies
The assumed functional dependencies used in the practical are:

- `order_id → order_date, customer_id`
- `customer_id → customer_name`
- `product_id → product_name`
- `(order_id, product_id) → quantity`

The candidate key for the normalized order-details relation is `(order_id, product_id)`.

The Products relation also stores `price` against `product_id`, as shown in the source code.

## Normalization Steps

### 1. Unnormalized Form (UNF)
The `Sales_UNF` table stores multiple product IDs, product names, quantities, and prices as comma-separated values in a single row.

### 2. First Normal Form (1NF)
The `Sales_1NF` table stores one product per row. The values are atomic, and the composite primary key is `(order_id, product_id)`.

### 3. Second Normal Form (2NF)
The data is separated into three tables:

- `Orders`
- `Products`
- `OrderDetails`

This separates order-level information, product-level information, and the quantity of each product in an order.

### 4. Third Normal Form (3NF)
A separate `Customers` table is created to store customer details. The `Orders_3NF` table references the customer using `customer_id`.

## Source Code
The SQL source code is available in [Experiment_7.sql](Experiment_7.sql). It follows the practical's sequence: database creation, UNF table, functional dependencies, 1NF, 2NF, 3NF, normalized-data verification, lossless-join query, dependency-preservation queries, and BCNF verification.

## Output
Run the SELECT statements in the SQL file in the ByteXL/MySQL editor to display:

- The denormalized `Sales_UNF` table.
- The `Sales_1NF` table.
- The `Orders`, `Products`, and `OrderDetails` tables.
- The `Customers` and `Orders_3NF` tables.
- The reconstructed normalized sales data using JOIN operations.
- The results of the lossless-join and dependency-preservation queries.

The output screenshots can be added alongside the practical if required by the lab submission.

## BCNF Verification
The practical states that every determinant in the final relations is a candidate key:

- Customers: `customer_id → customer_name`
- Orders_3NF: `order_id → order_date, customer_id`
- Products: `product_id → product_name, price`
- OrderDetails: `(order_id, product_id) → quantity`

Therefore, the final relations are stated to satisfy Boyce-Codd Normal Form (BCNF) under the functional dependencies used in the practical.

## Conclusion
The denormalized Sales table was transformed into 1NF, 2NF, and 3NF relations. JOIN queries were used to reconstruct and display the normalized sales information. The practical also includes SQL queries for lossless-join and dependency-preservation checks, followed by BCNF verification.
