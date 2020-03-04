--1.Table design
--******************************

CREATE DATABASE [Service]
GO

USE [Service]
GO

CREATE TABLE Users (
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Username NVARCHAR(30) NOT NULL UNIQUE,
	[Name] NVARCHAR(50),
	[Password] NVARCHAR(50) NOT NULL,
	BirthDate DATE,
	Age INT NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	CONSTRAINT CHK_UsersAge CHECK (Age>=14 AND Age<=110)
)

CREATE TABLE [Status] (
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
	Label NVARCHAR(30) NOT NULL
)

CREATE TABLE Departments (
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees (
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Birthdate DATE, 
	Age INT,
	DepartmentId INT NOT NULL FOREIGN KEY (DepartmentId) REFERENCES Departments(Id),
	CONSTRAINT CHK_EmployeeAge CHECK (Age>=18 AND Age<=110)
)

CREATE TABLE Categories (
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY, 
	[Name] NVARCHAR(50) NOT NULL, 
	DepartmentId INT NOT NULL FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
)

CREATE TABLE Reports (
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	CategoryId INT NOT NULL FOREIGN KEY (CategoryId) REFERENCES Categories(Id),
	StatusId INT NOT NULL FOREIGN KEY (StatusId) REFERENCES [Status](Id), 
	OpenDate DATE NOT NULL, 
	CloseDate DATE,
	[Description] NVARCHAR(200) NOT NULL,
	UserId INT NOT NULL FOREIGN KEY (UserId) REFERENCES Users(Id), 
	EmployeeId INT FOREIGN KEY (EmployeeId) REFERENCES Employees(Id)
)

--2.Insert
--****************************

INSERT INTO Employees (FirstName, LastName,	Birthdate, DepartmentId) VALUES
	('Marlo', 'O''Malley', '1958-9-21', 1),
	('Niki', 'Stanaghan', '1969-11-26', 4),
	('Ayrton', 'Senna', '1960-03-21', 9),
	('Ronnie', 'Peterson', '1944-02-14', 9),
	('Giovanna', 'Amati', '1959-07-20', 5)

INSERT INTO Reports (CategoryId, StatusId, OpenDate, CloseDate, [Description], UserId, EmployeeId) VALUES
	(1, 1, '2017-04-13', NULL, 'Stuck Road on Str.133', 6, 2),
	(6,	3, '2015-09-05', '2015-12-06', 'Charity trail running', 3, 5),
	(14, 2, '2015-09-07', NULL, 'Falling bricks on Str.58', 5, 2),
	(4,	3, '2017-07-03', '2017-07-06', 'Cut off streetlight on Str.11', 1, 1)

--3.Update
--*************************

UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL

--4.Delete
--*************************

DELETE FROM Reports
WHERE StatusId = 4

--5.Unassigned Reports
--*************************

SELECT r.[Description], FORMAT(r.OpenDate, 'dd-MM-yyyy') AS OpenDate
FROM Reports AS r
WHERE EmployeeId IS NULL
ORDER BY r.OpenDate ASC, r.[Description] ASC

--6.Reports & Categories
--*************************

SELECT r.[Description],	c.[Name] AS CategoryName
FROM Reports AS r
JOIN Categories AS c ON r.CategoryId = c.Id
ORDER BY r.[Description] ASC, c.[Name] ASC

--7.Most Reported Category
--*************************

SELECT TOP 5 
			c.[Name],
			COUNT(r.CategoryId) AS ReportsNumber
FROM Categories AS c
JOIN Reports AS r ON c.Id = r.CategoryId
GROUP BY r.CategoryId, 
		 c.[Name] 
ORDER BY ReportsNumber DESC, 
		 c.[Name] ASC

--8.Birthday Report
--**********************

SELECT u.Username, 
	   c.[Name] AS CategoryName
FROM Users AS u
JOIN Reports AS r ON u.Id = r.UserId
JOIN Categories AS c ON r.CategoryId = c.Id
WHERE FORMAT(u.Birthdate, 'dd-MM') = FORMAT(r.OpenDate, 'dd-MM')
ORDER BY u.Username ASC, 
		 c.[Name] ASC

--9.Users per Employee 
--************************

SELECT CONCAT(e.FirstName, ' ', e.LastName) AS FullName,
	   COUNT(u.Id) AS UsersCount
FROM Reports r
JOIN Users u ON r.UserId = u.id
RIGHT JOIN Employees e ON e.Id = r.EmployeeId
GROUP BY e.FirstName, e.LastName
ORDER BY UsersCount DESC,
	     FullName ASC

--10.Full Info
--************************

SELECT CASE
		   WHEN e.FirstName IS NULL THEN 'None'
		   ELSE CONCAT(e.FirstName, ' ', e.LastName)
	   END AS 'Employee',
	   CASE
		   WHEN d.[Name] IS NULL THEN 'None'
	   	   ELSE  d.[Name] 
	   END AS [Department],
		c.[Name] AS Category,
		r.[Description],
		FORMAT(r.OpenDate, 'dd.MM.yyyy') AS OpenDate,
		s.Label AS [Status],
		u.[Name] AS [User]
FROM Reports AS r
LEFT JOIN Employees AS e ON r.EmployeeId = e.Id
LEFT JOIN Departments AS d ON e.DepartmentId = d.Id
LEFT JOIN Categories AS c ON r.CategoryId = c.Id
LEFT JOIN [Status] AS s ON r.StatusId = s.Id
JOIN Users AS u ON r.UserId = u.Id
ORDER BY e.FirstName DESC,
		 e.LastName DESC,
		 [Department],
		 Category,
		 r.[Description],
		 OpenDate,
		 [Status],
		 [User]

--11.Hours to Complete
--**************************
USE Service
GO

CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS 
BEGIN
	DECLARE @Result INT
	IF (@StartDate = 0 OR @StartDate IS NULL)
	BEGIN
		SET @Result = 0
	END
	IF (@EndDate = 0 OR @EndDate IS NULL)
	BEGIN
		SET @Result = 0
	END 
	ELSE
	BEGIN
		SET @Result = DATEDIFF(hour, @StartDate, @EndDate)
	END
	RETURN @Result
END

GO

SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
FROM Reports

GO

--12.Assign Employee
--***************************

CREATE PROC usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
	DECLARE @EmployeeDapartment INT = (
						SELECT e.DepartmentId 
						FROM Employees AS e
						WHERE e.Id = @EmployeeId )

	DECLARE @CategoryDepartment INT = (
						SELECT c.DepartmentId
						FROM Categories AS c
						JOIN Reports AS r ON c.Id = r.CategoryId
						WHERE r.Id = @ReportId )

	IF(@EmployeeDapartment != @CategoryDepartment)
		BEGIN
			RAISERROR ('Employee doesn''t belong to the appropriate department!', 16, 1)
		END
	UPDATE Reports
		SET EmployeeId = @EmployeeId
		WHERE Id = @ReportId

GO

EXEC usp_AssignEmployeeToReport 30, 1

GO

EXEC usp_AssignEmployeeToReport 17, 2

GO
