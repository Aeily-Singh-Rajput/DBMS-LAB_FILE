-- 1. INNER JOIN

SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id;

--    2. LEFT JOIN

SELECT
    d.dept_id,
    d.dept_name,
    e.emp_name
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id;

--    3. SELF JOIN

SELECT
    e1.emp_name AS Employee1,
    e2.emp_name AS Employee2,
    e1.dept_id
FROM Employee e1
JOIN Employee e2
    ON e1.dept_id = e2.dept_id
    AND e1.emp_id < e2.emp_id;

-- 4. 3-WAY JOIN: Employee, Department and Project Assignment

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

-- 5. JOIN: Employee, Department and Project

SELECT
    e.emp_name,
    d.dept_name,
    e.salary
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
JOIN Project p
    ON d.dept_id = p.dept_id;

-- 6. Correlated Subquery

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

-- 7. EXISTS

SELECT
    e.emp_id,
    e.emp_name
FROM Employee e
WHERE EXISTS (
    SELECT 1
    FROM Employee_Project ep
    WHERE ep.emp_id = e.emp_id
);

-- 8. Simulated INTERSECT

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

-- 9. Simulated EXCEPT

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

-- 10. EXPLAIN – INNER JOIN

EXPLAIN
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id;

-- 11. EXPLAIN – LEFT JOIN

EXPLAIN
SELECT
    d.dept_name,
    e.emp_name
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id;

-- 12. EXPLAIN – Correlated Subquery

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

-- 13. EXPLAIN – EXISTS

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

