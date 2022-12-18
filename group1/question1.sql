--- Basic sql complexity is Easy. This needs to be solved first before going to question2


--1. Display all the information of the Employee table.
SELECT * 
FROM cards_ingest.emp

--2. Display unique Department names from Employee table.

--There aren't department names in the employee table
--There are in the dept table which can be accessed like so:

SELECT dname
FROM cards_ingest.dept

--But some of these could be unused so inner join with the employee table
--To get only the active departments

SELECT DISTINCT dname 
FROM cards_ingest.emp emp
INNER JOIN cards_ingest.dept dpt on emp.deptno = dpt.deptno

--3. List the details of the employees in ascending order of their salaries.

SELECT *
FROM cards_ingest.emp
ORDER BY sal

--4. List the employees who joined before 1981.

SELECT ename
FROM cards_ingest.emp
WHERE hiredate < to_date('1-1-1981', 'dd-mm-yyyy')

--This also gives adams as in data entry his year is only partially entered and 
--the database has him registered as being an employee for thousands of years
--the query is works, but the data is imperfect

--5. List the employees who are joined in the year 1981

SELECT ename
FROM cards_ingest.emp
WHERE hiredate < to_date('1-1-1982', 'dd-mm-yyyy') 
AND hiredate >= to_date('1-1-1981', 'dd-mm-yyyy')

--6. List the Empno, Ename, Sal, Daily Sal of all Employees in the ASC order of AnnSal. (Note devide sal/30 as annsal)

SELECT empno, ename, sal, sal/30 as dailysal
from cards_ingest.emp
ORDER BY dailysal

--7. List the employees who are working for the department name ACCOUNTING

SELECT ename
FROM cards_ingest.emp emp
INNER JOIN cards_ingest.dept dpt ON dpt.deptno = emp.deptno
WHERE dpt.dname = 'ACCOUNTING'

--8. List the employees who does not belong to department name ACCOUNTING

SELECT ename
FROM cards_ingest.emp emp
INNER JOIN cards_ingest.dept dpt ON dpt.deptno = emp.deptno
WHERE dpt.dname != 'ACCOUNTING'
