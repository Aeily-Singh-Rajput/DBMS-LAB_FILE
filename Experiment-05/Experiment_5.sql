-- 1. Selecting the Database

USE EmployeeManagement;

-- 2. Department Salary Summary View

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

-- 3. Querying the View

-- Find departments with an average salary greater than 75000
SELECT dept_name, average_salary
FROM Department_Salary_Summary
WHERE average_salary > 75000;

-- 4. Adding Manager Information

ALTER TABLE Employee
ADD manager_id INT NULL;

ALTER TABLE Employee
ADD CONSTRAINT fk_employee_manager
FOREIGN KEY (manager_id)
REFERENCES Employee(emp_id);

-- 5. Assigning Managers to Employees

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

-- 6. Employee Hierarchy View

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

-- 7. Testing Updatability of a Simple View

CREATE VIEW Employee_Basic AS
SELECT emp_id, emp_name, salary, dept_id
FROM Employee;

SELECT *
FROM Employee_Basic
WHERE emp_id = 101;

-- 8. Updating Data Through the View

UPDATE Employee_Basic
SET salary = 78000
WHERE emp_id = 101;

SELECT *
FROM Employee
WHERE emp_id = 101;

-- 9. Testing Non-Updatability of the Department Salary View

UPDATE Department_Salary_Summary
SET average_salary = 80000
WHERE dept_id = 1;

-- 10. Recursive CTE for Employee Reporting Chains

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

-- 11. Recursive CTE for One Employee's Management Chain

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
