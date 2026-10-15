# Experiment 4: SQL Joins, Subqueries and Execution Plans

## Aim
To perform and analyze SQL queries using INNER JOIN, LEFT JOIN, SELF JOIN, 3-way JOIN, correlated subqueries, EXISTS, and simulated INTERSECT and EXCEPT operations on the Employee–Department–Project database, and to compare their execution plans using EXPLAIN.

## Description
This experiment uses the EmployeeManagement database created in Experiment 3. Different SQL joins and subqueries are used to retrieve related information from tables. The EXPLAIN command is used to examine the execution plans of selected queries.

## Database Used
`EmployeeManagement` — created in Experiment 3.

## Source Code

### Selecting the Database

```sql
USE EmployeeManagement;
```

### 1. INNER JOIN

Displays employee IDs, employee names, and their department names.

```sql
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id;
```

**Output:** Displays employees along with their corresponding departments.

### 2. LEFT JOIN

Displays all departments and their employees, including departments without employees.

```sql
SELECT
    d.dept_id,
    d.dept_name,
    e.emp_name
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id;
```

**Output:** Displays all departments and their matching employees. If a department has no employees, the employee name appears as NULL.

### 3. SELF JOIN

Displays pairs of employees working in the same department.

```sql
SELECT
    e1.emp_name AS Employee1,
    e2.emp_name AS Employee2,
    e1.dept_id
FROM Employee e1
JOIN Employee e2
    ON e1.dept_id = e2.dept_id
    AND e1.emp_id < e2.emp_id;
```

**Output:** Displays employee pairs from the same department without repeating a pair in reverse order.

### 4. 3-WAY JOIN: Employee, Department and Project Assignment

Displays employees, their departments, and the projects they are assigned to.

```sql
SELECT
    e.emp_name,
    d.dept_name,
    p.project_name
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
JOIN Employee_Project ep
    ON e.emp_id = ep.emp_id
JOIN Project p
    ON ep.project_id = p.project_id;
```

**Output:** Displays employee names, department names, and assigned project names.

### 5. JOIN: Employee, Department and Project

Displays employee names, department names, and salaries for departments associated with projects.

```sql
SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
JOIN Project p
    ON d.dept_id = p.dept_id;
```

**Output:** Displays employees alongside their department and salary. Employees may appear more than once if their department has multiple projects.

### 6. Correlated Subquery

Displays employees whose salaries are greater than the average salary of their respective departments.

```sql
SELECT
    e.emp_id,
    e.emp_name,
    e.salary,
    e.dept_id
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);
```

**Output:** Displays employees earning more than their department's average salary.

### 7. EXISTS

Displays employees who are assigned to at least one project.

```sql
SELECT
    e.emp_id,
    e.emp_name
FROM Employee e
WHERE EXISTS (
    SELECT 1
    FROM Employee_Project ep
    WHERE ep.emp_id = e.emp_id
);
```

**Output:** Displays employees who have at least one project assignment.

### 8. Simulated INTERSECT

Displays employees who belong to department 1 and are assigned to project 201.

```sql
SELECT
    e.emp_id,
    e.emp_name
FROM Employee e
WHERE e.dept_id = 1
AND EXISTS (
    SELECT 1
    FROM Employee_Project ep
    WHERE ep.emp_id = e.emp_id
      AND ep.project_id = 201
);
```

**Output:** Displays employees who satisfy both conditions.

### 9. Simulated EXCEPT

Displays employees who belong to department 1 but are not assigned to project 201.

```sql
SELECT
    e.emp_id,
    e.emp_name
FROM Employee e
WHERE e.dept_id = 1
AND NOT EXISTS (
    SELECT 1
    FROM Employee_Project ep
    WHERE ep.emp_id = e.emp_id
      AND ep.project_id = 201
);
```

**Output:** Displays employees from department 1 who are not assigned to project 201.

## Comparing Execution Plans Using EXPLAIN

### 10. EXPLAIN – INNER JOIN

```sql
EXPLAIN
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id;
```

**Output:** Shows the execution plan, including the tables accessed and the join method selected by MySQL.

### 11. EXPLAIN – LEFT JOIN

```sql
EXPLAIN
SELECT
    d.dept_name,
    e.emp_name
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id;
```

**Output:** Shows how MySQL plans to retrieve departments and their matching employees.

### 12. EXPLAIN – Correlated Subquery

```sql
EXPLAIN
SELECT
    e.emp_name,
    e.salary
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);
```

**Output:** Shows the execution plan for the salary comparison and correlated subquery.

### 13. EXPLAIN – EXISTS

```sql
EXPLAIN
SELECT
    e.emp_id,
    e.emp_name
FROM Employee e
WHERE EXISTS (
    SELECT 1
    FROM Employee_Project ep
    WHERE ep.emp_id = e.emp_id
);
```

## Conclusion
The experiment demonstrates the use of SQL joins, correlated subqueries, EXISTS, simulated INTERSECT and EXCEPT operations, and EXPLAIN. These queries help retrieve related records and understand how MySQL plans query execution.
