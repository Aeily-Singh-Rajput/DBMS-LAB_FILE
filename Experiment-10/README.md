# Experiment 10: Query Optimization and Performance Analysis

## Aim
To generate a dataset containing at least 10,000 rows. To write five slow queries, analyze their performance using EXPLAIN, optimize them using indexing and query rewriting, and compare execution time before and after optimization.

## Description
This experiment creates a Sales_Records table and generates 10,000 records. Five queries are analyzed using EXPLAIN before optimization. Indexes are then created on Customer_ID, Sale_Date, the combination of City and Category, and Product_ID. The queries are executed again, with the date search rewritten as a range condition. Query execution plans and the recorded execution times are compared.

## Database Table
`Sales_Records`

## Source Code

### 1. Create Sales Records Table

```sql
CREATE TABLE Sales_Records (
    Sale_ID INT PRIMARY KEY,
    Customer_ID INT,
    Product_ID INT,
    Category VARCHAR(50),
    Sale_Date DATE,
    Quantity INT,
    Unit_Price DECIMAL(10,2),
    City VARCHAR(50)
);
```

**Output:** Creates the Sales_Records table with columns for sale ID, customer ID, product ID, category, sale date, quantity, unit price, and city.

### 2. Generate Dataset with 10,000 Rows

```sql
INSERT INTO Sales_Records
(Sale_ID, Customer_ID, Product_ID, Category,
 Sale_Date, Quantity, Unit_Price, City)

SELECT
    n + 1,
    1 + MOD(n, 1000),
    1 + MOD(n, 100),
    CASE
        WHEN MOD(n, 4) = 0 THEN 'Electronics'
        WHEN MOD(n, 4) = 1 THEN 'Clothing'
        WHEN MOD(n, 4) = 2 THEN 'Furniture'
        ELSE 'Books'
    END,
    DATE_ADD('2025-01-01', INTERVAL MOD(n, 730) DAY),
    1 + MOD(n, 10),
    100 + MOD(n, 500),
    CASE
        WHEN MOD(n, 5) = 0 THEN 'Delhi'
        WHEN MOD(n, 5) = 1 THEN 'Mumbai'
        WHEN MOD(n, 5) = 2 THEN 'Kanpur'
        WHEN MOD(n, 5) = 3 THEN 'Lucknow'
        ELSE 'Jaipur'
    END
FROM (
    SELECT
        d0.d + d1.d * 10 + d2.d * 100
        + d3.d * 1000 AS n
    FROM
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
         UNION ALL SELECT 3 UNION ALL SELECT 4
         UNION ALL SELECT 5 UNION ALL SELECT 6
         UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d0
    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
         UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
         UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
         UNION ALL SELECT 9) d1
    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
         UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
         UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
         UNION ALL SELECT 9) d2
    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
         UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
         UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
         UNION ALL SELECT 9) d3
) AS numbers;
```

**Output:** Generates and inserts 10,000 sales records into the Sales_Records table.

### 3. Verify Total Number of Rows

```sql
SELECT COUNT(*) AS Total_Records
FROM Sales_Records;
```

**Output:** Displays the total number of records. The expected count is 10,000.

### 4. Write Five Slow Queries Before Optimization

**1. Search Customer Records**

```sql
EXPLAIN
SELECT *
FROM Sales_Records
WHERE Customer_ID = 106;
```

**Output:** Displays the execution plan for searching sales records belonging to customer 106 before indexing.

**2. Search Sales by Year**

```sql
EXPLAIN
SELECT *
FROM Sales_Records
WHERE YEAR(Sale_Date) = 2025;
```

**Output:** Displays the execution plan for retrieving sales made during the year 2025 using the YEAR() function.

**3. Search City and Category**

```sql
EXPLAIN
SELECT *
FROM Sales_Records
WHERE City = 'Delhi'
AND Category = 'Electronics';
```

**Output:** Displays the execution plan for searching sales records matching the specified city and category.

**4. Group Sales by Product**

```sql
EXPLAIN
SELECT Product_ID, COUNT(*) AS Total_Sales
FROM Sales_Records
GROUP BY Product_ID;
```

**Output:** Displays the execution plan for grouping sales records by product ID and counting the sales in each group.

**5. Display Latest Sales**

```sql
EXPLAIN
SELECT *
FROM Sales_Records
ORDER BY Sale_Date DESC
LIMIT 10;
```

**Output:** Displays the execution plan for retrieving the ten most recent sales records.

### 5. Optimize Queries Using Indexing

```sql
CREATE INDEX idx_customer
ON Sales_Records(Customer_ID);

CREATE INDEX idx_date
ON Sales_Records(Sale_Date);

CREATE INDEX idx_city_category
ON Sales_Records(City, Category);

CREATE INDEX idx_product
ON Sales_Records(Product_ID);
```

**Output:** Creates indexes on Customer_ID, Sale_Date, City and Category (composite index), and Product_ID.

### 6. Execute Optimized Queries

**1. Optimized Customer Search**

```sql
EXPLAIN
SELECT *
FROM Sales_Records
WHERE Customer_ID = 106;
```

**Output:** Displays the execution plan for the customer search after creating the Customer_ID index.

**2. Optimized Sales by Year**

```sql
EXPLAIN
SELECT *
FROM Sales_Records
WHERE Sale_Date >= '2025-01-01'
AND Sale_Date < '2026-01-01';
```

**Output:** Uses a date range condition instead of applying YEAR() to Sale_Date, allowing the database to consider the Sale_Date index.

**3. Optimized City and Category Search**

```sql
EXPLAIN
SELECT *
FROM Sales_Records
WHERE City = 'Delhi'
AND Category = 'Electronics';
```

**Output:** Displays the execution plan for the city and category search after creating the composite index.

**4. Optimized Product Grouping**

```sql
EXPLAIN
SELECT Product_ID, COUNT(*) AS Total_Sales
FROM Sales_Records
GROUP BY Product_ID;
```

**Output:** Displays the execution plan for product-wise grouping after creating the Product_ID index.

**5. Optimized Latest Sales**

```sql
EXPLAIN
SELECT *
FROM Sales_Records
ORDER BY Sale_Date DESC
LIMIT 10;
```

**Output:** Displays the execution plan for retrieving the ten latest sales after creating the Sale_Date index.

### 7. Comparison of Query Execution Plans

| S. No. | Query | Before Optimization | After Optimization |
|---|---|---|---|
| 1 | Customer ID Search | ALL (Full Table Scan) | ref (Index Used) |
| 2 | Sale Date Search | ALL (Full Table Scan) | ALL (Index Not Used) |
| 3 | City and Category Search | ALL (Full Table Scan) | ref (Composite Index Used) |
| 4 | Product-wise Grouping | ALL (Full Table Scan) | index (Index Used) |
| 5 | Latest 10 Sales | ALL (Full Table Scan) | index (Backward Index Scan) |

### 8. Comparison of Execution Time

| S. No. | Query | Before Optimization | After Optimization |
|---|---|---:|---:|
| 1 | Customer ID Search | 179 ms | 247 ms |
| 2 | Sale Date Search | 221 ms | 257 ms |
| 3 | City and Category Search | 174 ms | 209 ms |
| 4 | Product-wise Grouping | 165 ms | 276 ms |
| 5 | Latest 10 Sales | 185 ms | 277 ms |

**Observation:** The execution times recorded in the supplied results are higher after optimization for all five queries. The execution plans show index use for some queries, but index use does not guarantee a lower measured time in every run. Actual timings can vary with database configuration, caching, data distribution, and measurement conditions.

## Conclusion
The experiment demonstrated the generation of a 10,000-row sales dataset, analysis of five queries using EXPLAIN, and optimization through indexing and query rewriting. The execution plans and recorded execution times were compared to study how indexes and query structure affect query performance.
