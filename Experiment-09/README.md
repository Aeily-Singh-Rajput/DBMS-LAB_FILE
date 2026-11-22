# Experiment 9: Indexing and Query Performance Benchmarking

## Aim
To create a Railway Booking table containing at least 5,000 records and benchmark query performance before and after creating single and composite indexes. To use the EXPLAIN command to compare query execution plans and analyze the performance improvement.

## Description
This experiment creates a Railway Booking table and inserts 5,000 records. Query performance is examined before indexing, after creating a single-column index on Train_No, and after creating a composite index on Train_No and Journey_Date. The EXPLAIN command is used to inspect the query execution plans.

## Database Table
`Railway_Booking`

## Source Code

### 1. Create Railway Booking Table

```sql
CREATE TABLE Railway_Booking (
    Booking_ID INT PRIMARY KEY,
    Passenger_Name VARCHAR(50),
    Train_No INT,
    Journey_Date DATE,
    From_City VARCHAR(50),
    To_City VARCHAR(50),
    Seat_No INT
);
```

**Output:** Creates the Railway_Booking table with columns for booking ID, passenger name, train number, journey date, source city, destination city, and seat number.

### 2. Insert 5,000 Records

```sql
INSERT INTO Railway_Booking
(Booking_ID, Passenger_Name, Train_No,
 Journey_Date, From_City, To_City, Seat_No)

SELECT
    n + 1,
    CONCAT('Passenger', n + 1),
    1000 + MOD(n, 50),
    DATE_ADD('2026-01-01', INTERVAL MOD(n, 30) DAY),
    'Delhi',
    'Mumbai',
    1 + MOD(n, 100)
FROM (
    SELECT
        d0.d + d1.d * 10 + d2.d * 100 + d3.d * 1000 +
        d4.d * 10000 AS n
    FROM
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
         UNION ALL SELECT 3 UNION ALL SELECT 4
         UNION ALL SELECT 5 UNION ALL SELECT 6
         UNION ALL SELECT 7 UNION ALL SELECT 8
         UNION ALL SELECT 9) d0
    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
         UNION ALL SELECT 3 UNION ALL SELECT 4
         UNION ALL SELECT 5 UNION ALL SELECT 6
         UNION ALL SELECT 7 UNION ALL SELECT 8
         UNION ALL SELECT 9) d1
    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
         UNION ALL SELECT 3 UNION ALL SELECT 4
         UNION ALL SELECT 5 UNION ALL SELECT 6
         UNION ALL SELECT 7 UNION ALL SELECT 8
         UNION ALL SELECT 9) d2
    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
         UNION ALL SELECT 3 UNION ALL SELECT 4
         UNION ALL SELECT 5 UNION ALL SELECT 6
         UNION ALL SELECT 7 UNION ALL SELECT 8
         UNION ALL SELECT 9) d3
    CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
         UNION ALL SELECT 3 UNION ALL SELECT 4
         UNION ALL SELECT 5 UNION ALL SELECT 6
         UNION ALL SELECT 7 UNION ALL SELECT 8
         UNION ALL SELECT 9) d4
) AS numbers
WHERE n < 5000;
```

**Output:** Inserts 5,000 generated railway booking records into the table.

### 3. Verify Total Records

```sql
SELECT COUNT(*) AS Total_Records
FROM Railway_Booking;
```

**Output:** Displays the total number of records in the Railway_Booking table. The expected count is 5,000.

### 4. Check Query Performance Before Indexing

```sql
EXPLAIN
SELECT * FROM Railway_Booking
WHERE Train_No = 1005;

SELECT COUNT(*) AS Total_Bookings
FROM Railway_Booking
WHERE Train_No = 1005;
```

**Output:** EXPLAIN displays the query execution plan before creating the Train_No index. The COUNT query displays the number of bookings for train number 1005.

### 5. Create Single Index

```sql
CREATE INDEX idx_train_no
ON Railway_Booking(Train_No);
```

**Output:** Creates a single-column index on Train_No to support searches using the train number.

### 6. Check Performance After Single Index

```sql
EXPLAIN
SELECT * FROM Railway_Booking
WHERE Train_No = 1005;
```

**Output:** Displays the execution plan for the same Train_No query after the single-column index has been created.

### 7. Create Composite Index

```sql
CREATE INDEX idx_train_date
ON Railway_Booking(Train_No, Journey_Date);
```

**Output:** Creates a composite index using Train_No and Journey_Date.

### 8. Check Performance After Composite Index

```sql
EXPLAIN
SELECT * FROM Railway_Booking
WHERE Train_No = 1005
AND Journey_Date = '2026-01-06';

SELECT COUNT(*) AS Total_Bookings
FROM Railway_Booking
WHERE Train_No = 1005
AND Journey_Date = '2026-01-06';
```

**Output:** EXPLAIN displays the execution plan for a query filtering by both Train_No and Journey_Date. The COUNT query displays the number of bookings matching both conditions.

## Conclusion
The experiment demonstrated how single-column and composite indexes can be created to improve data retrieval. The EXPLAIN command was used to compare query execution plans before and after indexing and to study the effect of indexes on query performance.
