USE SoftUni
GO

--Problem 1.Employees with Salary Above 35000
--***********************************************

CREATE PROC usp_GetEmployeesSalaryAbove35000 
AS
	SELECT e.FirstName AS [First Name],	
		   e.LastName AS [Last Name]
	FROM Employees AS e
	WHERE e.Salary > 35000
GO

EXEC usp_GetEmployeesSalaryAbove35000
GO

--Problem 2.Employees with Salary Above Number
--***********************************************

CREATE PROC usp_GetEmployeesSalaryAboveNumber(@number DECIMAL(18,4))
AS
	SELECT e.FirstName AS [First Name],	
		   e.LastName AS [Last Name]
	FROM Employees AS e
	WHERE e.Salary >= @number
GO

EXEC usp_GetEmployeesSalaryAboveNumber 48100
GO

--Problem 3.Town Names Starting With
--********************************************

ALTER PROC usp_GetTownsStartingWith(@startsWith NVARCHAR(MAX))
AS
	SELECT t.[Name] AS Town
	FROM Towns AS t
	WHERE t.[Name] LIKE(@startsWith + '%')
GO

EXEC usp_GetTownsStartingWith b
GO

--Problem 4.Employees from Town
--****************************************

CREATE PROC usp_GetEmployeesFromTown(@town VARCHAR(50))
AS
	SELECT e.FirstName AS [First Name],	
		   e.LastName AS [Last Name]
	FROM Employees AS e
	JOIN Addresses AS a ON e.AddressID = a.AddressID
	JOIN Towns AS t ON a.TownID = t.TownID
	WHERE t.[Name] = @town 
GO

EXEC usp_GetEmployeesFromTown Sofia
GO

--Problem 5.Salary Level Function
--***********************************

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4)) 
RETURNS NVARCHAR(10)
AS
BEGIN
	 DECLARE @salaryLevel NVARCHAR(10)
	 IF (@salary < 30000)
		 BEGIN
			SET @salaryLevel = 'Low'
		 END
	 ELSE IF (@salary <= 50000)
		 BEGIN
			SET @salaryLevel = 'Average'
		 END
	 ELSE
		 BEGIN
			SET @salaryLevel = 'High'
		 END
	RETURN @salaryLevel
END
GO

SELECT e.Salary, 
		dbo.ufn_GetSalaryLevel(e.Salary)
	   AS [Salary Level]
FROM Employees AS e
GO

--Problem 6.Employees by Salary Level
--*******************************************

CREATE PROC usp_EmployeesBySalaryLevel(@levelOfSalary NVARCHAR(10))
AS 
	SELECT e.FirstName AS [First Name],	
		   e.LastName AS [Last Name]
	FROM Employees AS e
	WHERE dbo.ufn_GetSalaryLevel(e.Salary) = @levelOfSalary
GO

--Problem 7.Define Function
--*********************************
							       
CREATE FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(MAX), @word NVARCHAR(MAX)) 
RETURNS INT
	BEGIN
		DECLARE @counter INT = 1
		WHILE (@counter <= LEN(@word))
			BEGIN
				DECLARE @currentLetter CHAR = SUBSTRING(@word, @counter, 1)
				IF (CHARINDEX(@currentLetter, @setOfLetters) <= 0)
				  BEGIN
					RETURN 0
				  END
				  SET @counter += 1
			END
			RETURN 1
	END

--Problem 9.Find Full Name
--******************************
				       
USE Bank
GO

CREATE PROC usp_GetHoldersFullName 
AS
	BEGIN
		SELECT CONCAT(ah.FirstName, ' ', ah.LastName) AS [Full Name]
		FROM AccountHolders AS ah
	END
GO

EXEC usp_GetHoldersFullName
GO
				       
--Problem 10.People with Balance Higher Than
--*************************************************
				       
CREATE PROC usp_GetHoldersWithBalanceHigherThan(@number MONEY)
AS
	BEGIN
		SELECT ah.FirstName,
			   ah.LastName
		FROM AccountHolders AS ah
		JOIN Accounts AS a ON ah.Id = a.AccountHolderId
		GROUP BY ah.FirstName, ah.LastName
		HAVING SUM(a.Balance) > @number
		ORDER BY ah.FirstName,
				 ah.LastName
	END
GO

EXEC usp_GetHoldersWithBalanceHigherThan 20.5
GO

--Problem 11. Future Value Function
--***************************************
				       
CREATE FUNCTION ufn_CalculateFutureValue (@initialSum MONEY, @yearlyInterestRate FLOAT, @numberOfYears INT)
RETURNS MONEY
	BEGIN
		DECLARE @futureValue DECIMAL(10,4) =
		        @initialSum * POWER((1 + @yearlyInterestRate), @numberOfYears)
		RETURN @futureValue
	END
GO

--Problem 12. Calculating Interest
--*****************************************
										
CREATE PROC usp_CalculateFutureValueForAccount (@accountId INT, @yearlyInterestRate FLOAT)
AS
	BEGIN
		SELECT a.Id AS [Account Id],
			   ah.FirstName AS [First Name],
			   ah.LastName AS [Last Name],
			   a.Balance AS [Current Balance],
			   dbo.ufn_CalculateFutureValue(a.Balance, @yearlyInterestRate, 5) AS [Balance in 5 years]
		FROM AccountHolders AS ah
		JOIN Accounts AS a ON ah.Id = a.AccountHolderId
		WHERE a.Id = @accountId
	END
GO

EXEC usp_CalculateFutureValueForAccount 1, 0.1
GO

--Problem 14.Create Table Logs
--**********************************
										
USE Bank
										
GO

CREATE TABLE Logs (
		   LogId INT NOT NULL IDENTITY(1, 1) PRIMARY KEY, 
		   AccountId INT NOT NULL FOREIGN KEY (AccountId) REFERENCES Accounts(Id), 
		   OldSum MONEY NOT NULL, 
		   NewSum MONEY NOT NULL			  
)
										
GO

CREATE TRIGGER tr_AccountsLogsAfterUpdate 
ON Accounts
FOR UPDATE
AS
   BEGIN
         INSERT INTO Logs
			 VALUES
			 (
				 (SELECT Id
				  FROM deleted),
				 (SELECT Balance
				  FROM deleted),
				 (SELECT Balance
				  FROM inserted)
			 )
   END
GO	

--Problem 15. Create Table Emails
--************************************
										
CREATE TABLE NotificationEmails (
	Id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Recipient INT NOT NULL FOREIGN KEY (Recipient) REFERENCES Accounts(Id),
	[Subject] NVARCHAR(MAX) NOT NULL, 
	Body NVARCHAR(MAX) NOT NULL
)
										
GO

CREATE TRIGGER tr_AddNewEmailWhenNewRegordsIsMakeIntoLogsLable
ON Logs
FOR INSERT
AS 
	BEGIN
		INSERT INTO NotificationEmails 
		VALUES(
			   (SELECT AccountId
				FROM inserted),
		        CONCAT('Balance change for account: ', 
			       (SELECT AccountId FROM inserted)),
		        CONCAT('On ', 
			       FORMAT(GETDATE(), 'dd-MM-yyyy HH:mm'), 		
			       'your balance was changed from ', 
				(SELECT OldSum FROM Logs), 
				'to ', 
				(SELECT NewSum FROM Logs),
				'.')
		      )
	END

