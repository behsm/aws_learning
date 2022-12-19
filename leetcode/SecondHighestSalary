SELECT MAX(Salary) as SecondHighestSalary
FROM Employee
WHERE Salary < (select max(Salary) from Employee)
