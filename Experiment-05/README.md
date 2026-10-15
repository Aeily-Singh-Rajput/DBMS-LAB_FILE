# Experiment 5: SQL Views and Recursive CTE

## Aim
To create and manipulate SQL views for department salary summary and employee hierarchy, test the updatability of views, and implement a recursive CTE to display employee reporting chains.

## Description
This experiment uses the EmployeeManagement database created in Experiment 3. It creates views for department salary summaries and employee hierarchy, tests view updatability, and uses recursive Common Table Expressions (CTEs) to display reporting relationships.

## Database Used
`EmployeeManagement` — created in Experiment 3.

## Source Code

### 1. Selecting the Database

```sql
USE EmployeeManagement;
```

### 2. Department Salary Summary View

```sql
CREATE VIEW Department_Salary_Summary AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS total_employees,
    SUM(e.salary) AS total_salary,
    AVG(e.salary) AS average_salary,
    MAX(e.salary) AS highest_salary,
    MIN(e.salary) AS lowest_salary
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT *
FROM Department_Salary_Summary;
```

**Output:** Displays each department's employee count, total salary, average salary, highest salary, and lowest salary.

### 3. Querying the View

```sql
-- Find departments with an average salary greater than 75000
SELECT dept_name, average_salary
FROM Department_Salary_Summary
WHERE average_salary > 75000;
```

**Output:** Displays departments whose average salary is greater than 75000.

### 4. Adding Manager Information

```sql
ALTER TABLE Employee
ADD manager_id INT NULL;

ALTER TABLE Employee
ADD CONSTRAINT fk_employee_manager
FOREIGN KEY (manager_id)
REFERENCES Employee(emp_id);
```

**Output:** Adds a `manager_id` column to Employee to represent the reporting relationship.

### 5. Assigning Managers to Employees

```sql
-- Set department heads as top-level managers
UPDATE Employee
SET manager_id = NULL
WHERE emp_id IN (105, 112, 114, 122, 125);

-- IT department
UPDATE Employee SET manager_id = 105 WHERE emp_id IN (103, 104);
UPDATE Employee SET manager_id = 103 WHERE emp_id IN (101, 102);
UPDATE Employee SET manager_id = 104 WHERE emp_id = 106;

-- HR department
UPDATE Employee SET manager_id = 112 WHERE emp_id IN (107, 108, 109);
UPDATE Employee SET manager_id = 107 WHERE emp_id = 110;
UPDATE Employee SET manager_id = 108 WHERE emp_id = 111;

-- Finance department
UPDATE Employee SET manager_id = 114 WHERE emp_id IN (115, 116, 117, 118);

-- Marketing department
UPDATE Employee SET manager_id = 122 WHERE emp_id IN (119, 120, 121, 123, 124);

-- Research department
UPDATE Employee SET manager_id = 125 WHERE emp_id IN (126, 127, 128);
UPDATE Employee SET manager_id = 126 WHERE emp_id = 129;
UPDATE Employee SET manager_id = 128 WHERE emp_id = 130;
```

**Output:** Assigns managers to employees to establish a reporting hierarchy.

### 6. Employee Hierarchy View

```sql
CREATE VIEW Employee_Hierarchy AS
SELECT
    e.emp_id,
    e.emp_name AS employee_name,
    e.manager_id,
    m.emp_name AS manager_name,
    e.salary,
    e.dept_id
FROM Employee e
LEFT JOIN Employee m
    ON e.manager_id = m.emp_id;

SELECT *
FROM Employee_Hierarchy;
```

**Output:** Displays each employee's details and the name of their manager. Employees without a manager show NULL as the manager name.

### 7. Testing Updatability of a Simple View

```sql
CREATE VIEW Employee_Basic AS
SELECT emp_id, emp_name, salary, dept_id
FROM Employee;

SELECT *
FROM Employee_Basic
WHERE emp_id = 101;
```

**Output:** Displays the basic details of employee 101 through the view.

### 8. Updating Data Through the View

```sql
UPDATE Employee_Basic
SET salary = 78000
WHERE emp_id = 101;

SELECT *
FROM Employee
WHERE emp_id = 101;
```

**Output:** Updates employee 101's salary through the view and displays the updated record from the original Employee table.

### 9. Testing Non-Updatability of the Department Salary View

```sql
UPDATE Department_Salary_Summary
SET average_salary = 80000
WHERE dept_id = 1;
```

**Output:** MySQL normally rejects this update because the view contains aggregate functions and a GROUP BY clause.

### 10. Recursive CTE for Employee Reporting Chains

```sql
WITH RECURSIVE EmployeeChain AS (
    -- Anchor member
    SELECT
        emp_id,
        emp_name,
        manager_id,
        0 AS level,
        CAST(emp_name AS CHAR(500)) AS reporting_chain
    FROM Employee
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        ec.level + 1,
        CONCAT(ec.reporting_chain, ' -> ', e.emp_name)
    FROM Employee e
    INNER JOIN EmployeeChain ec
        ON e.manager_id = ec.emp_id
)
SELECT
    emp_id,
    emp_name,
    manager_id,
    level,
    reporting_chain
FROM EmployeeChain
ORDER BY reporting_chain;
```

**Output:** Displays employees, their hierarchy levels, and the reporting chain from the top-level manager to each employee.

### 11. Recursive CTE for One Employee's Management Chain

```sql
WITH RECURSIVE ReportingChain AS (
    SELECT
        emp_id,
        emp_name,
        manager_id,
        0 AS level
    FROM Employee
    WHERE emp_id = 101

    UNION ALL

    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        rc.level + 1
    FROM Employee e
    JOIN ReportingChain rc
        ON e.emp_id = rc.manager_id
)
SELECT
    emp_id,
    emp_name,
    manager_id,
    level
FROM ReportingChain;
```

## Conclusion
The experiment demonstrates how SQL views can summarize and display data, how simple views can support updates, and how recursive CTEs can be used to retrieve employee reporting hierarchies.
