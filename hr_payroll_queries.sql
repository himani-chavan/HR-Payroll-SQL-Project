-- HR & Payroll Management System
-- SQL Practice Project
-- Database: hr_payroll
-- SQL dialect: MySQL

USE hr_payroll;

-- 1. BASIC QUERIES

-- 1.1 List all employees
SELECT *
FROM employees;

-- 1.2 Employees hired from 1 January 2022
SELECT *
FROM employees
WHERE hire_date >= '2022-01-01';

-- 1.3 Employees in the HR department
SELECT e.emp_id, e.emp_name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'HR';


-- 2. FILTERING AND SORTING

-- 2.1 Employees with a basic salary greater than 50000
SELECT e.emp_name, s.basic_salary
FROM employees e
JOIN salaries s ON e.emp_id = s.emp_id
WHERE s.basic_salary > 50000;

-- 2.2 Order employees by hire date
SELECT *
FROM employees
ORDER BY hire_date;

-- 2.3 Employees not in the Development department
SELECT e.emp_name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_name <> 'Development';


-- 3. AGGREGATE FUNCTIONS

-- 3.1 Count employees in each department
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

-- 3.2 Average salary of developers
SELECT AVG(s.basic_salary) AS avg_salary
FROM employees e
JOIN salaries s ON e.emp_id = s.emp_id
WHERE e.job_role = 'Developer';

-- 3.3 Maximum basic salary in the company
SELECT MAX(basic_salary) AS max_salary
FROM salaries;


-- 4. GROUP BY AND HAVING

-- 4.1 Average salary per department
SELECT d.dept_name, AVG(s.basic_salary) AS avg_salary
FROM employees e
JOIN salaries s ON e.emp_id = s.emp_id
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

-- 4.2 Departments with more than two employees
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
JOIN employees e ON e.dept_id = d.dept_id
GROUP BY d.dept_name
HAVING COUNT(e.emp_id) > 2;


-- 5. JOINS

-- 5.1 Employees with their departments
SELECT e.emp_name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- 5.2 Employees with salary details
SELECT e.emp_name, s.basic_salary, s.bonus, s.deductions
FROM employees e
JOIN salaries s ON e.emp_id = s.emp_id;

-- 5.3 Projects with assigned employees
SELECT e.emp_name, p.project_name
FROM employees e
JOIN employee_projects ep ON ep.emp_id = e.emp_id
JOIN projects p ON p.project_id = ep.project_id;

-- 5.4 Departments with no employees
SELECT d.*
FROM departments d
LEFT JOIN employees e ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;

-- 5.5 FULL OUTER JOIN alternative using UNION in MySQL
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
UNION
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;


-- 6. SUBQUERIES AND NESTED QUERIES

-- 6.1 Employees whose total earnings are above the company average
SELECT e.emp_id, e.emp_name,
       s.basic_salary, s.bonus, s.deductions,
       (s.basic_salary + s.bonus - s.deductions) AS total_earnings
FROM employees e
JOIN salaries s ON e.emp_id = s.emp_id
WHERE (s.basic_salary + s.bonus - s.deductions) >
      (SELECT AVG(basic_salary + bonus - deductions)
       FROM salaries);

-- 6.2 Highest earning employee
SELECT e.emp_id, e.emp_name,
       (s.basic_salary + s.bonus - s.deductions) AS total_earnings
FROM employees e
JOIN salaries s ON e.emp_id = s.emp_id
WHERE (s.basic_salary + s.bonus - s.deductions) =
      (SELECT MAX(basic_salary + bonus - deductions)
       FROM salaries);

-- 6.3 Employees not assigned to any project
SELECT emp_id, emp_name
FROM employees
WHERE emp_id NOT IN (
    SELECT emp_id
    FROM employee_projects
);

-- 6.4 Second-highest distinct basic salary
SELECT MAX(basic_salary) AS second_highest_salary
FROM salaries
WHERE basic_salary < (
    SELECT MAX(basic_salary)
    FROM salaries
);

-- 6.5 Projects with more than two assigned employees
SELECT project_id, project_name
FROM projects
WHERE project_id IN (
    SELECT project_id
    FROM employee_projects
    GROUP BY project_id
    HAVING COUNT(emp_id) > 2
);

-- 6.6 Departments whose average basic salary is higher than Finance
SELECT d.dept_id, d.dept_name
FROM departments d
JOIN employees e ON d.dept_id = e.dept_id
JOIN salaries s ON e.emp_id = s.emp_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(s.basic_salary) > (
    SELECT AVG(s2.basic_salary)
    FROM salaries s2
    JOIN employees e2 ON s2.emp_id = e2.emp_id
    JOIN departments d2 ON e2.dept_id = d2.dept_id
    WHERE d2.dept_name = 'Finance'
);


-- 7. ADVANCED QUERIES

-- 7.1 Total payroll amount per employee
SELECT e.emp_id, e.emp_name,
       s.basic_salary, s.bonus, s.deductions,
       (s.basic_salary + s.bonus - s.deductions) AS total_payroll_cost
FROM employees e
JOIN salaries s ON e.emp_id = s.emp_id;

-- 7.2 Rank employees by basic salary
SELECT e.emp_id, e.emp_name, s.basic_salary,
       RANK() OVER (ORDER BY s.basic_salary DESC) AS salary_rank
FROM employees e
JOIN salaries s ON e.emp_id = s.emp_id;

-- 7.3 Month-wise attendance summary
SELECT YEAR(`date`) AS attendance_year,
       MONTH(`date`) AS attendance_month,
       status,
       COUNT(*) AS total_days
FROM attendance
GROUP BY YEAR(`date`), MONTH(`date`), status
ORDER BY attendance_year, attendance_month, status;


-- 8. VIEWS

-- 8.1 View of high earners
CREATE VIEW high_earners AS
SELECT emp_id, basic_salary
FROM salaries
WHERE basic_salary > 60000;

SELECT *
FROM high_earners;

-- 8.2 Department-wise salary summary view
CREATE VIEW dept_salary_summary AS
SELECT d.dept_name, AVG(s.basic_salary) AS avg_salary
FROM employees e
JOIN salaries s ON e.emp_id = s.emp_id
JOIN departments d ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

SELECT *
FROM dept_salary_summary;

-- 8.3 Employee project allocation view
CREATE VIEW employee_project_view AS
SELECT e.emp_name, p.project_name, ep.role
FROM employees e
JOIN employee_projects ep ON e.emp_id = ep.emp_id
JOIN projects p ON p.project_id = ep.project_id;

SELECT *
FROM employee_project_view;


-- 9. DML OPERATIONS
-- Run data-changing statements carefully and verify the target rows first.

-- 9.1 Update an employee's basic salary
-- UPDATE salaries
-- SET basic_salary = 70000
-- WHERE emp_id = 101;

-- 9.2 Delete attendance records marked Absent
-- DELETE FROM attendance
-- WHERE status = 'Absent';

-- 9.3 Insert a new project
-- INSERT INTO projects (project_id, project_name, start_date, end_date)
-- VALUES (101, 'Airline Management System', '2024-09-01', '2024-12-31');

-- 9.4 Transfer an employee to another department
-- UPDATE employees
-- SET dept_id = 2
-- WHERE emp_id = 103;


-- 10. CONSTRAINTS AND INDEXES
-- Check the existing table definition before applying ALTER statements.

-- 10.1 Create an index on employee email
-- CREATE INDEX idx_employee_email
-- ON employees(email);

-- 10.2 Add a minimum salary check constraint
-- ALTER TABLE salaries
-- ADD CONSTRAINT chk_min_salary
-- CHECK (basic_salary >= 10000);

-- 10.3 Add an age check constraint
-- ALTER TABLE employees
-- ADD CONSTRAINT chk_age
-- CHECK (age >= 18);

-- 10.4 Make the phone column NOT NULL
-- ALTER TABLE employees
-- MODIFY phone VARCHAR(15) NOT NULL;


-- 11. CASE STUDY QUERIES

-- 11.1 Total payroll cost of the company
SELECT SUM(basic_salary + bonus - deductions) AS total_payroll
FROM salaries;

-- 11.2 Employee working on the maximum number of projects
SELECT e.emp_id, e.emp_name, COUNT(ep.project_id) AS project_count
FROM employees e
JOIN employee_projects ep ON e.emp_id = ep.emp_id
GROUP BY e.emp_id, e.emp_name
ORDER BY project_count DESC
LIMIT 1;

-- 11.3 Department with the highest employee count
SELECT d.dept_id, d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC
LIMIT 1;

-- 11.4 Least busy project
SELECT p.project_id, p.project_name, COUNT(ep.emp_id) AS employee_count
FROM projects p
LEFT JOIN employee_projects ep ON p.project_id = ep.project_id
GROUP BY p.project_id, p.project_name
ORDER BY employee_count ASC
LIMIT 1;

-- 11.5 Employees with 100% recorded attendance marked Present
SELECT e.emp_id, e.emp_name
FROM employees e
JOIN attendance a ON e.emp_id = a.emp_id
GROUP BY e.emp_id, e.emp_name
HAVING COUNT(*) = SUM(
    CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END
);
