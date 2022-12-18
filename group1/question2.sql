--1.SQL Query to print the number of employees per department in the organization

SELECT dpt.dname, count(empno)
FROM cards_ingest.emp emp
INNER JOIN cards_ingest.dept dpt on emp.deptno = dpt.deptno
GROUP BY dpt.dname

--2.SQL Query to find the employee details who got second maximum salary

SELECT *
FROM cards_ingest.emp
WHERE sal = (
	SELECT MAX(sal)
	FROM cards_ingest.emp
);
	
--3.SQL Query to find the employee details who got second maximum salary in each department

SELECT *
FROM cards_ingest.emp
WHERE sal IN (
	SELECT sal
	FROM cards_ingest.emp
	ORDER BY sal DESC LIMIT 2
) 
OFFSET 1

--4.SQL Query to find the employee who got minimum salary in 2019

--In a professional setting you'd likely want a employee number
--with this data for identification purposes

SELECT ename, sal
FROM cards_ingest.emp
WHERE sal IN (
	SELECT min(sal)
	FROM cards_ingest.emp
)
ORDER BY sal ASC;

--5.SQL query to select the employees getting salary greater than the average salary of the department that are working in

SELECT ename 
FROM cards_ingest.emp
INNER JOIN (
	SELECT deptno, AVG(sal) as avg_sal
	FROM cards_ingest.emp
	GROUP BY deptno
	) AS inq
ON inq.deptno = emp.deptno and sal > avg_sal

--6.SQL query to compute the group salary of all the employees.

Select SUM(sal) as GroupSalary
FROM cards_ingest.emp

--7.SQL query to list the employees and name of employees reporting to each person.

--Note: Employees without supervisors or subordinates do not show up in this table
SELECT emp1.ename as Supervisor, emp2.ename as Employee
FROM cards_ingest.emp emp1
INNER JOIN cards_ingest.emp emp2 
ON emp1.empno = emp2.mgr

--8.SQL query to find the department with highest number of employees.

SELECT dpt.dname
FROM cards_ingest.emp emp
INNER JOIN cards_ingest.dept dpt on emp.deptno = dpt.deptno
GROUP BY dpt.dname
ORDER BY count(empno) DESC LIMIT 1
