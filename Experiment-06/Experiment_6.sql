-- 1. Selecting the Database

USE EmployeeManagement;

-- 2. Stored Procedure: transfer_employee

DROP PROCEDURE IF EXISTS transfer_employee;

DELIMITER //

CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_employee_count INT DEFAULT 0;
    DECLARE v_department_count INT DEFAULT 0;
    DECLARE v_current_dept INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred. Transaction rolled back.' AS message;
    END;

    START TRANSACTION;

    -- Check whether employee exists
    SELECT COUNT(*)
    INTO v_employee_count
    FROM Employee
    WHERE emp_id = p_emp_id;

    IF v_employee_count = 0 THEN
        ROLLBACK;
        SELECT 'Error: Employee does not exist.' AS message;
    ELSE
        -- Check whether department exists
        SELECT COUNT(*)
        INTO v_department_count
        FROM Department
        WHERE dept_id = p_new_dept_id;

        IF v_department_count = 0 THEN
            ROLLBACK;
            SELECT 'Error: Department does not exist.' AS message;
        ELSE
            -- Get current department
            SELECT dept_id
            INTO v_current_dept
            FROM Employee
            WHERE emp_id = p_emp_id;

            -- Check whether employee is already in the department
            IF v_current_dept = p_new_dept_id THEN
                ROLLBACK;
                SELECT 'Error: Employee is already in this department.'
                    AS message;
            ELSE
                -- Transfer employee
                UPDATE Employee
                SET dept_id = p_new_dept_id
                WHERE emp_id = p_emp_id;

                COMMIT;

                SELECT 'Employee transferred successfully.' AS message;
            END IF;
        END IF;
    END IF;
END //

DELIMITER ;

-- 3. Testing the Stored Procedure

SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
WHERE e.emp_id = 101;

CALL transfer_employee(101, 3);

SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name
FROM Employee e
JOIN Department d ON e.dept_id = d.dept_id
WHERE e.emp_id = 101;

--4. Edge Case: Employee Does Not Exist

CALL transfer_employee(999, 3);

-- 5. Edge Case: Department Does Not Exist

CALL transfer_employee(101, 99);

-- 6. Edge Case: Employee Already in the Same Department

CALL transfer_employee(101, 3);

-- 7. Salary Validation Trigger

DROP TRIGGER IF EXISTS validate_employee_salary;

DELIMITER //

CREATE TRIGGER validate_employee_salary
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary < 15000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be at least 15000';
    END IF;
END //

DELIMITER ;

-- 8. Testing Invalid Salary

INSERT INTO Employee
(emp_id, emp_name, gender, salary, hire_date, dept_id)
VALUES
(131, 'Test Employee', 'M', 10000, '2026-09-25', 1);

-- 9. Testing Valid Salary

INSERT INTO Employee
(emp_id, emp_name, gender, salary, hire_date, dept_id)
VALUES
(131, 'Test Employee', 'M', 30000, '2026-09-25', 1);

SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id = 131;

-- 10. Salary Validation for UPDATE

DROP TRIGGER IF EXISTS validate_employee_salary_update;

DELIMITER //

CREATE TRIGGER validate_employee_salary_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary < 15000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be at least 15000';
    END IF;
END //

DELIMITER ;

-- 11. Testing Invalid Salary Update

UPDATE Employee
SET salary = 5000
WHERE emp_id = 131;

SELECT emp_id, emp_name, salary
FROM Employee
WHERE emp_id = 131;

-- 12. Creating the Audit Table

CREATE TABLE IF NOT EXISTS Salary_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(30)
);

-- 13. Audit Logging Trigger

DROP TRIGGER IF EXISTS salary_audit_trigger;

DELIMITER //

CREATE TRIGGER salary_audit_trigger
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO Salary_Audit (
            emp_id,
            old_salary,
            new_salary,
            action
        )
        VALUES (
            NEW.emp_id,
            OLD.salary,
            NEW.salary,
            'SALARY UPDATED'
        );
    END IF;
END //

DELIMITER ;

-- 14. Testing the Audit Trigger

UPDATE Employee
SET salary = 35000
WHERE emp_id = 131;

SELECT *
FROM Salary_Audit;

-- 15. Testing Multiple Salary Changes

UPDATE Employee
SET salary = 40000
WHERE emp_id = 131;

UPDATE Employee
SET salary = 45000
WHERE emp_id = 131;

SELECT
    audit_id,
    emp_id,
    old_salary,
    new_salary,
    action
FROM Salary_Audit
WHERE emp_id = 131;

-- 16. Edge Case: Salary Unchanged

UPDATE Employee
SET salary = 45000
WHERE emp_id = 131;

SELECT *
FROM Salary_Audit
WHERE emp_id = 131;

-- 17. Edge Case: NULL Salary

DROP TRIGGER validate_employee_salary;

DELIMITER //

CREATE TRIGGER validate_employee_salary
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary IS NULL OR NEW.salary < 15000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Salary cannot be NULL and must be at least 15000';
    END IF;
END //

DELIMITER ;

INSERT INTO Employee
(emp_id, emp_name, gender, salary, hire_date, dept_id)
VALUES
(132, 'Null Salary', 'F', NULL, '2026-09-25', 1);

-- 18. Checking All Triggers

SHOW TRIGGERS;

-- 19. Checking the Stored Procedure

SHOW PROCEDURE STATUS
WHERE Db = 'EmployeeManagement';
