# Experiment 7: Functional Dependencies and Database Normalization

## Aim
To identify functional dependencies in a denormalized Sales table and normalize it step-by-step from UNF to 3NF and BCNF. To verify lossless join and dependency preservation using SQL queries.

## Description
This experiment demonstrates how a denormalized Sales table can be normalized to reduce data redundancy and avoid insertion, update, and deletion anomalies. The table is converted from Unnormalized Form (UNF) to First Normal Form (1NF), Second Normal Form (2NF), and Third Normal Form (3NF). The final relations are checked against the stated functional dependencies to verify BCNF.

## Database Used
`SalesDB`

## Functional Dependencies
The functional dependencies used in this experiment are:

- `order_id → order_date, customer_id`
- `customer_id → customer_name`
- `product_id → product_name, price`
- `(order_id, product_id) → quantity`

The candidate key for the order-details relation is `(order_id, product_id)`.

## Normalization Steps

### 1. Unnormalized Form (UNF)
The `Sales_UNF` table stores multiple product IDs, product names, quantities, and prices as comma-separated values in a single row. These repeating groups make the data non-atomic.

### 2. First Normal Form (1NF)
The `Sales_1NF` table stores one product per row. All attributes contain atomic values, and the composite primary key is `(order_id, product_id)`.

### 3. Second Normal Form (2NF)
The relation is decomposed into:

- `Orders`: stores order details.
- `Products`: stores product details.
- `OrderDetails`: stores the products and quantities associated with each order.

This removes partial dependencies on parts of the composite key.

### 4. Third Normal Form (3NF)
The transitive dependency `order_id → customer_id → customer_name` is removed by creating a separate `Customers` table. The `Orders_3NF` table stores the customer ID as a foreign key.

## Source Code
The complete MySQL source code is available in [Experiment_7.sql](Experiment_7.sql). It includes database and table creation, sample data insertion, normalization steps, reconstruction joins, lossless-join checks, dependency-preservation checks, and BCNF verification.

## Output
Run the SELECT statements in the SQL file to view:

- The original denormalized Sales table.
- The 1NF table with one product per row.
- The 2NF relations: Orders, Products, and OrderDetails.
- The 3NF relations: Customers and Orders_3NF.
- The reconstructed sales data after joining the normalized relations.
- The row counts and missing-row check used for lossless-join verification.
- The dependency checks, which should return no violating rows for the sample data.

The SQL queries display the outputs in the MySQL/ByteXL SQL editor.

## Verification

### Lossless Join
The normalized relations are joined using their primary-key and foreign-key relationships to reconstruct the sales records. The original and reconstructed row counts are compared, and a query checks whether any original 1NF row is missing from the reconstructed result.

### Dependency Preservation
Grouped queries check that each determinant maps to only one corresponding dependent value. The verification queries should return no rows when the dependencies hold for the stored data.

### BCNF
In the final relations, each determinant in the stated non-trivial functional dependencies is a candidate key:

- Customers: `customer_id → customer_name`
- Orders_3NF: `order_id → order_date, customer_id`
- Products: `product_id → product_name, price`
- OrderDetails: `(order_id, product_id) → quantity`

Therefore, all final relations satisfy Boyce-Codd Normal Form (BCNF) under the stated functional dependencies. No further decomposition is required.

## Conclusion
The denormalized Sales table was normalized from UNF to 1NF, 2NF, and 3NF by separating repeating groups, partial dependencies, and the transitive dependency involving customer details. The final relations were checked for lossless reconstruction, dependency preservation, and BCNF under the stated functional dependencies.
