USE Gringotts

GO

--Problem 1.Records’ Count
--******************************

SELECT COUNT(w.Id) AS [Count]
FROM WizzardDeposits AS w

--Problem 2.Longest Magic Wand
--**********************************

SELECT MAX(w.MagicWandSize) AS [LongestMagicWand]
FROM WizzardDeposits AS w

--Problem 3.Longest Magic Wand per Deposit Groups
--**************************************************

SELECT w.DepositGroup,
       MAX(w.MagicWandSize) AS [LongestMagicWand]
FROM WizzardDeposits AS w
GROUP BY w.DepositGroup

--Problem 4.*Smallest Deposit Group per Magic Wand Size
--******************************************************

SELECT TOP 1 WITH TIES w.DepositGroup
FROM WizzardDeposits AS w
GROUP BY w.DepositGroup
ORDER BY AVG(w.MagicWandSize) 

--Problem 5.Deposits Sum
--**************************************

SELECT w.DepositGroup, 
       SUM(w.DepositAmount) AS [TotalSum]
FROM WizzardDeposits AS w
GROUP BY w.DepositGroup

--Problem 6.Deposits Sum for Ollivander Family
--************************************************

SELECT w.DepositGroup,
       SUM(w.DepositAmount) AS [TotalSum]
FROM WizzardDeposits AS w
WHERE w.MagicWandCreator = 'Ollivander family'
GROUP BY w.DepositGroup

--Problem 7.Deposits Filter
--*******************************

SELECT w.DepositGroup, 
       SUM(w.DepositAmount) AS [TotalSum]
FROM WizzardDeposits AS w
WHERE w.MagicWandCreator = 'Ollivander family'
GROUP BY w.DepositGroup
HAVING SUM(w.DepositAmount) < 150000
ORDER BY TotalSum DESC

--Problem 8.Deposit Charge
--**********************************

SELECT w.DepositGroup, 
       w.MagicWandCreator,
       MIN(w.DepositCharge) AS [MinDepositCharge]
FROM WizzardDeposits AS w
GROUP BY w.DepositGroup, w.MagicWandCreator

--Problem 9.Age Groups
--************************************

SELECT 
	CASE
		WHEN w.Age BETWEEN 0 AND 10
		THEN '[0-10]'
		WHEN w.Age BETWEEN 11 AND 20
		THEN '[11-20]'
		WHEN w.Age BETWEEN 21 AND 30
		THEN '[21-30]'
		WHEN w.Age BETWEEN 31 AND 40
		THEN '[31-40]'
		WHEN w.Age BETWEEN 41 AND 50
		THEN '[41-50]'
		WHEN w.Age BETWEEN 51 AND 60
		THEN '[51-60]'
		WHEN w.Age > 60
		THEN '[61+]'
		ELSE 'N\A'
	END AS [AgeGroup],
	COUNT(*) AS [WizardCount]
FROM WizzardDeposits AS w
GROUP BY CASE
             WHEN w.Age BETWEEN 0 AND 10
             THEN '[0-10]'
             WHEN w.Age BETWEEN 11 AND 20
             THEN '[11-20]'
             WHEN w.Age BETWEEN 21 AND 30
             THEN '[21-30]'
             WHEN w.Age BETWEEN 31 AND 40
             THEN '[31-40]'
             WHEN w.Age BETWEEN 41 AND 50
             THEN '[41-50]'
             WHEN w.Age BETWEEN 51 AND 60
             THEN '[51-60]'
             WHEN w.Age > 60
             THEN '[61+]'
             ELSE 'N\A'
         END

--Problem 10.First Letter
--*****************************

SELECT LEFT(w.FirstName, 1) AS [FirstLetter]
FROM WizzardDeposits AS w
WHERE w.DepositGroup = 'Troll Chest'
GROUP BY LEFT(w.FirstName, 1)
ORDER BY LEFT(w.FirstName, 1)

--Problem 11.Average Interest 
--**********************************

SELECT w.DepositGroup,
       w.IsDepositExpired, 
       AVG(w.DepositInterest) AS [AverageInterest]
FROM WizzardDeposits AS w
WHERE w.DepositStartDate > '01/01/1985'
GROUP BY w.DepositGroup, 
	     w.IsDepositExpired
ORDER BY w.DepositGroup DESC, 
		 w.IsDepositExpired ASC

--Problem 13.Departments Total Salaries
--**************************************

USE SoftUni

GO

SELECT e.DepartmentID,
       SUM(e.Salary) AS [TotalSalary]
FROM Employees AS e
GROUP BY e.DepartmentID

--Problem 14.Employees Minimum Salaries
--****************************************

SELECT e.DepartmentID,
       MIN(e.Salary) AS [MinimumSalary]
FROM Employees AS e
WHERE e.HireDate > '2000-01-01'
GROUP BY e.DepartmentID
HAVING e.DepartmentID IN (2, 5, 7)

--Problem 15.Employees Average Salaries
--*******************************************

SELECT *
INTO NewTable
FROM Employees 
WHERE Salary > 30000 

DELETE 
FROM NewTable 
WHERE ManagerID = 42

UPDATE NewTable
SET Salary += 5000
WHERE DepartmentID = 1

SELECT n.DepartmentID,
       AVG(n.Salary) AS [AverageSalary]
FROM NewTable AS n
GROUP BY n.DepartmentID

--Problem 16.Employees Maximum Salaries
--*****************************************

SELECT e.DepartmentID,
       MAX(e.Salary) AS [MaxSalary]
FROM Employees AS e
GROUP BY e.DepartmentID
HAVING MAX(e.Salary) NOT BETWEEN 30000 AND 70000

--Problem 17.Employees Count Salaries
--***************************************

SELECT COUNT(e.EmployeeID) AS [Count]
FROM Employees AS e
WHERE e.ManagerID IS NULL

--Problem 19.**Salary Challenge
--**************************************

SELECT TOP (10) 
              FirstName,
              LastName,
              DepartmentID
FROM Employees AS e
WHERE Salary >
(
    SELECT AVG(Salary)
    FROM Employees AS em
    WHERE e.DepartmentID = em.DepartmentID
)
