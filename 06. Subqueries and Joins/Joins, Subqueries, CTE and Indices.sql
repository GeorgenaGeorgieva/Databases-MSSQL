USE SoftUni

GO

--Problem 1.Employee Address
--*********************************

SELECT TOP 5
	   e.EmployeeId, 
	   e.JobTitle, 
	   e.AddressId, 
	   a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
ORDER BY e.AddressID

--Problem 2.Addresses with Towns
--************************************

SELECT TOP 50
       e.FirstName,
       e.LastName,
       t.[Name] AS Town,
       a.AddressText
FROM Employees AS e
JOIN Addresses AS a ON e.AddressID = a.AddressID
JOIN Towns AS t ON a.TownID = t.TownID
ORDER BY  e.FirstName, e.LastName

--Problem 3.Sales Employee
--***************************************

SELECT e.EmployeeID, 
       e.FirstName, 
       e.LastName, 
       d.[Name] AS DepartmentName
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE d.[Name] = 'Sales'
ORDER BY e.EmployeeID

--Problem 4.Employee Departments
--*********************************

SELECT TOP 5 
	e.EmployeeID,
	e.FirstName,
	e.Salary,
	d.[Name] AS DepartmentName
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID
WHERE e.Salary > 15000
ORDER BY d.DepartmentID

--Problem 5.Employees Without Project
--*****************************************

SELECT TOP 3
	e.EmployeeID,
	e.FirstName
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
WHERE ep.ProjectID IS NULL
ORDER BY e.EmployeeID

--Problem 6.Employees Hired After
--****************************************

SELECT e.FirstName, 
       e.LastName,
       e.HireDate,
       d.[Name] AS DeptName
FROM Employees AS e
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID 
					  AND d.[Name] IN ('Sales', 'Finance')
WHERE e.HireDate > '1999-01-01'
ORDER BY e.HireDate

--Problem 7.Employees with Project
--***************************************

SELECT TOP 5
	e.EmployeeID,
	e.FirstName,
	p.[Name] AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '2002-08-13' AND p.EndDate IS NULL
ORDER BY e.EmployeeID

--Problem 8.Employee 24
--********************************

SELECT  e.EmployeeID,
	e.FirstName,
	CASE
           WHEN p.StartDate > '2005'
           THEN NULL
           ELSE p.[Name]
        END AS ProjectName
FROM Employees AS e
JOIN EmployeesProjects AS ep ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p ON ep.ProjectID = p.ProjectID 
WHERE e.EmployeeID = 24 

--Problem 9.Employee Manager

SELECT e.EmployeeID,
	   e.FirstName,
	   e.ManagerID,
	   em.FirstName AS ManagerName
FROM Employees AS e
JOIN Employees AS em ON e.ManagerID = em.EmployeeID
WHERE e.ManagerID IN (3, 7)
ORDER BY e.EmployeeID

--Problem 10.Employee Summary
--*************************************

SELECT TOP 50
       e.EmployeeID,
	   CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
	   CONCAT(m.FirstName, ' ', m.LastName) AS ManagerName,
	   d.[Name] AS DepartmentName
FROM Employees AS e
JOIN Employees AS m ON e.ManagerID = m.EmployeeID
JOIN Departments AS d ON e.DepartmentID = d.DepartmentID 
ORDER BY e.EmployeeID

--Problem 11.Min Average Salary
--************************************
SELECT MIN(m.AverageSalary) AS MinAverageSalary
FROM (
	  SELECT AVG(e.Salary) AS AverageSalary
	  FROM Employees AS e
	  GROUP BY e.DepartmentID
	 ) AS m
		
--Problem 12.Highest Peaks in Bulgaria
--****************************************

USE [Geography]

GO

SELECT  
	mc.CountryCode,
	m.MountainRange,
	p.PeakName,
	p.Elevation
FROM Mountains AS m
JOIN MountainsCountries AS mc ON m.Id = mc.MountainId
JOIN Peaks AS p ON m.Id = p.MountainId
WHERE mc.CountryCode = 'BG'
   AND p.Elevation > 2835
ORDER BY p.Elevation DESC

--Problem 13.Count Mountain Ranges
--*************************************

SELECT c.CountryCode,
       COUNT(m.MountainRange) AS MountainRanges
FROM Mountains AS m
JOIN MountainsCountries AS c ON m.Id = c.MountainId
WHERE c.CountryCode IN ('BG', 'RU', 'US')
GROUP BY c.CountryCode

--Problem 14.Countries with Rivers
--***************************************

SELECT TOP 5
	c.CountryName,
	r.RiverName
FROM Countries AS c
LEFT JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers AS r ON cr.RiverId = r.Id
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName

--Problem 16.Countries without any Mountains
--*******************************************

SELECT COUNT(g.MountainCount) as [Count]
FROM ( 
		SELECT c.CountryName,
               COUNT(m.MountainId) AS MountainCount
        FROM Countries AS c
        LEFT JOIN MountainsCountries AS m ON c.CountryCode = m.CountryCode
        GROUP BY c.CountryName 
	 ) AS g
WHERE g.MountainCount = 0

--Problem 17.Highest Peak and Longest River by Country
--********************************************************
SELECT TOP 5
       c.CountryName,
	   MAX(p.Elevation) AS HighestPeakElevation,
	   MAX(r.[Length]) AS LongestRiverLength
FROM Countries AS c 
FULL JOIN MountainsCountries AS m ON c.CountryCode = m.CountryCode
FULL JOIN Peaks AS p ON m.MountainId = p.MountainId
FULL JOIN CountriesRivers AS cr ON c.CountryCode = cr.CountryCode
FULL JOIN Rivers AS r ON cr.RiverId = r.Id
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC,
         LongestRiverLength DESC,
		 c.CountryName ASC

--






SELECT * FROM Countries
