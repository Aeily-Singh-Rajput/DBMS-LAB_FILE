# Experiment 8: Transaction Management and Concurrency Control

## Aim
To implement banking-style transactions using BEGIN, COMMIT, ROLLBACK, and SAVEPOINT. To simulate partial transaction failures and demonstrate isolation levels and concurrency anomalies using two sessions.

## Description
This experiment demonstrates transaction management in a banking-style database. It uses transaction control statements such as BEGIN, COMMIT, ROLLBACK, and SAVEPOINT. It also demonstrates transaction isolation levels and concurrency using two database sessions.

## Database Table
`Bank_Account`

## Source Code

### 1. Create Banking Table

```sql
CREATE TABLE Bank_Account (
    Account_No INT PRIMARY KEY,
    Account_Holder VARCHAR(50),
    Balance DECIMAL(10,2)
);

INSERT INTO Bank_Account VALUES
(101, 'Aman', 10000),
(102, 'Rahul', 8000),
(103, 'Priya', 12000);

SELECT * FROM Bank_Account;
```

**Output:** Displays the bank account details with account numbers, account holders, and initial balances.

### 2. BEGIN and COMMIT Transaction

```sql
BEGIN;

UPDATE Bank_Account
SET Balance = Balance - 2000
WHERE Account_No = 101;

UPDATE Bank_Account
SET Balance = Balance + 2000
WHERE Account_No = 102;

COMMIT;

SELECT * FROM Bank_Account;
```

**Output:** Transfers 2000 from account 101 to account 102 and commits the transaction.

### 3. ROLLBACK Transaction

```sql
BEGIN;

UPDATE Bank_Account
SET Balance = Balance - 1000
WHERE Account_No = 101;

ROLLBACK;

SELECT * FROM Bank_Account;
```

**Output:** Cancels the update and restores the account balance to its value before the transaction.

### 4. SAVEPOINT and Partial Rollback

```sql
BEGIN;

UPDATE Bank_Account
SET Balance = Balance - 1000
WHERE Account_No = 101;

SAVEPOINT sp1;

UPDATE Bank_Account
SET Balance = Balance + 1000
WHERE Account_No = 103;

ROLLBACK TO SAVEPOINT sp1;

COMMIT;

SELECT * FROM Bank_Account;
```

**Output:** Rolls back the update made after savepoint sp1 while retaining and committing the earlier deduction.

### 5. Demonstrate Isolation Levels

**1. READ UNCOMMITTED**

```sql
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

START TRANSACTION;

SELECT * FROM Bank_Account;

COMMIT;
```

**2. READ COMMITTED**

```sql
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT * FROM Bank_Account;

COMMIT;
```

**3. REPEATABLE READ**

```sql
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

START TRANSACTION;

SELECT * FROM Bank_Account;

COMMIT;
```

**4. SERIALIZABLE**

```sql
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

START TRANSACTION;

SELECT * FROM Bank_Account;

COMMIT;
```

**Output:** Executes a SELECT statement under each specified transaction isolation level.

### 6. Demonstrate Concurrency Using Two Sessions

**SESSION 1:**

```sql
BEGIN;

UPDATE Bank_Account
SET Balance = Balance - 500
WHERE Account_No = 101;
```

**SESSION 2:**

```sql
BEGIN;

SELECT * FROM Bank_Account
WHERE Account_No = 101;

COMMIT;
```

**SESSION 1:**

```sql
COMMIT;
```

**Output:** Demonstrates how a second session reads an account while the first session has an uncommitted update. The observed result depends on the database isolation level and session timing.

### 7. Simulate Partial Failure

```sql
BEGIN;

UPDATE Bank_Account
SET Balance = Balance - 500
WHERE Account_No = 101;

SAVEPOINT transfer_point;

UPDATE Bank_Account
SET Balance = Balance + 500
WHERE Account_No = 102;

ROLLBACK TO SAVEPOINT transfer_point;

COMMIT;

SELECT * FROM Bank_Account;
```

**Output:** Rolls back the update after the savepoint and commits the earlier deduction.

## Conclusion
The experiment demonstrated transaction control using BEGIN, COMMIT, ROLLBACK, and SAVEPOINT. Different isolation levels and a two-session concurrency example were used to understand transaction behavior and partial transaction failures.
