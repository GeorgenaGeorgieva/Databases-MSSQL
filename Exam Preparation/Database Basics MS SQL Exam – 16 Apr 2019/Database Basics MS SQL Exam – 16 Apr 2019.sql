--1.Database Design
--**************************

CREATE DATABASE Airport
GO

USE Airport
GO

CREATE TABLE Planes (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Name] VARCHAR(30) NOT NULL,
	Seats INT NOT NULL,
	[Range] INT NOT NULL
	)

CREATE TABLE Flights (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	DepartureTime DATETIME,
	ArrivalTime DATETIME,
	Origin VARCHAR(50) NOT NULL,
	Destination VARCHAR(50) NOT NULL,
	PlaneId INT NOT NULL FOREIGN KEY (PlaneId) REFERENCES Planes(Id)
	)

CREATE TABLE LuggageTypes (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	[Type] VARCHAR(30)
	)

CREATE TABLE Passengers (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Age INT NOT NULL,
	[Address] VARCHAR(30) NOT NULL,
	PassportId CHAR(11) NOT NULL 
	)

CREATE TABLE Luggages (
	Id INT IDENTITY(1,1) PRIMARY KEY,
	LuggageTypeId INT NOT NULL FOREIGN KEY (LuggageTypeId) REFERENCES LuggageTypes(Id),
	PassengerId INT NOT NULL FOREIGN KEY (PassengerId) REFERENCES Passengers(Id)
	)

CREATE TABLE Tickets
(
	Id INT IDENTITY(1,1) PRIMARY KEY,
	PassengerId INT NOT NULL FOREIGN KEY (PassengerId) REFERENCES Passengers(Id),
	FlightId INT NOT NULL FOREIGN  KEY (FlightId) REFERENCES Flights(Id),
	LuggageId INT NOT NULL FOREIGN KEY (LuggageId) REFERENCES Luggages(Id),
	Price DECIMAL(15,2) NOT NULL
)

--2.Insert
--**************************
USE Airport
GO

INSERT INTO Planes ([Name], Seats, [Range]) VALUES
	('Airbus 336', 112, 5132),
	('Airbus 330', 432, 5325),
	('Boeing 369', 231, 2355),
	('Stelt 297', 254, 2143),
	('Boeing 338', 165, 5111),
	('Airbus 558', 387, 1342),
	('Boeing 128', 345, 5541)

INSERT INTO LuggageTypes ([Type]) VALUES
	('Crossbody Bag'),
	('School Backpack'),
	('Shoulder Bag')

--3.Update
--*******************************

UPDATE Tickets
SET Price *= 1.13
WHERE FlightId = (SELECT TOP 1 Id 
				  FROM Flights 
				  WHERE Destination = 'Carlsbad')

--4.Delete
--*****************************

DELETE 
FROM Tickets
WHERE FlightId = (SELECT TOP 1 Id 
				  FROM Flights 
				  WHERE Destination = 'Ayn Halagim')

DELETE FROM Flights 
WHERE Destination = 'Ayn Halagim'

--5.Trips
--**************************

SELECT Origin, Destination
FROM Flights
ORDER BY Origin, Destination

--6.The "Tr" Planes
--****************************

SELECT *
FROM Planes
WHERE [Name] LIKE '%tr%'
ORDER BY Id, [Name], Seats, [Range]

--7.Flight Profits
--****************************

SELECT FlightId, SUM(Price) AS Price
FROM Tickets
GROUP BY FlightId
ORDER BY Price DESC, FlightId

--8.Passengers and Prices
--****************************

SELECT TOP 10
		p.FirstName,
		p.LastName,
		t.Price
FROM Passengers AS p	
JOIN Tickets AS t ON p.Id = t.PassengerId
ORDER BY t.Price DESC,
	     p.FirstName,
		 p.LastName
		
--9.Most Used Luggage's
--****************************

SELECT lt.[Type], COUNT(lu.LuggageTypeId) AS MostUsedLuggage
FROM Luggages as lu
JOIN LuggageTypes AS lt ON lu.LuggageTypeId = lt.Id
GROUP BY lt.[Type]
ORDER BY COUNT(lu.LuggageTypeId) DESC, lt.[Type]

--10.Passenger Trips
--****************************

SELECT CONCAT(p.FirstName, ' ', p.LastName) AS [Full Name], 
	   Origin, 
	   Destination
FROM Passengers AS p
JOIN Tickets AS t ON p.Id = t.PassengerId
JOIN Flights AS f ON t.FlightId = f.Id
ORDER BY [Full Name], 
	     Origin, 
		 Destination

--11.Non Adventures People
--*****************************

SELECT p.FirstName AS [First Name],
	   p.LastName AS [Last Name],
	   p.Age
FROM Passengers AS p
LEFT JOIN Tickets AS t ON p.Id = t.PassengerId
WHERE t.PassengerId IS NULL
ORDER BY p.Age DESC,
		 p.FirstName,
		 p.LastName

--12.Lost Luggage's
--*************************

SELECT p.PassportId AS [Passport Id],
	   p.[Address]
FROM Passengers AS p
LEFT JOIN Luggages AS lu ON p.Id = lu.PassengerId
WHERE lu.PassengerId IS NULL
ORDER BY p.PassportId,
		 p.[Address]		 
		 
--13.Count of Trips
--*************************

SELECT p.FirstName AS [First Name],
	   p.LastName AS [Last Name],
	   COUNT(t.Id) AS [Total Trips]
FROM Passengers AS p
LEFT JOIN Tickets AS t ON p.Id = t.PassengerId
GROUP BY p.FirstName, p.LastName
ORDER BY COUNT(t.Id) DESC,
		 p.FirstName,
		 p.LastName

--14.Full Info
--***************************
USE Airport
GO

SELECT CONCAT(p.FirstName, ' ', p.LastName) AS [Full Name],
	pl.[Name] AS [Plane Name],
	CONCAT(f.Origin, ' - ', f.Destination) AS [Trip],
	lt.[Type]   AS [Luggage Type]
FROM Passengers AS p
JOIN Tickets AS t ON p.Id = t.PassengerId
JOIN Flights AS f ON t.FlightId = f.Id
JOIN Planes AS pl ON f.PlaneId = pl.Id
JOIN Luggages AS lu ON t.LuggageId = lu.Id
JOIN LuggageTypes AS lt ON lu.LuggageTypeId = lt.Id
ORDER BY [Full Name],
		pl.[Name],
		f.Origin,
		f.Destination,
		lt.[Type]

--15.Most Expensive Trips
--******************************

SELECT k.FirstName, 
	   k.LastName,
	   k.Destination, 
	   k.Price
  FROM (
		  SELECT p.FirstName,
		         p.LastName, 
			 f.Destination,
		         t.Price,
			 DENSE_RANK() OVER(PARTITION BY p.FirstName, p.LastName ORDER BY t.Price DESC) AS PriceRank
          FROM Passengers AS p
		  JOIN Tickets AS t ON t.PassengerId = p.Id
		  JOIN Flights AS f ON f.Id = t.FlightId
        ) AS k 
  WHERE k.PriceRank = 1
  ORDER BY k.Price DESC, 
		   k.FirstName, 
		   k.LastName, 
		   k.Destination

--16.Destinations Info	
--******************************

SELECT f.Destination,
       COUNT(t.FlightId) AS FilesCount
FROM Flights AS f
LEFT JOIN Tickets AS t ON f.Id = t.FlightId
GROUP BY f.Destination
ORDER BY COUNT(t.FlightId) DESC, 
		 f.Destination

--17.PSP

SELECT p.[Name],
	   p.Seats,
	   COUNT(t.PassengerId) AS [Passengers Count]
FROM Planes AS p 
LEFT JOIN Flights AS f ON p.Id = f.PlaneId
LEFT JOIN Tickets AS t ON f.Id = t.FlightId
GROUP BY p.[Name],
		 p.Seats
ORDER BY [Passengers Count] DESC,
		 p.[Name],
		 p.Seats

--18.Vacation

GO 

CREATE FUNCTION udf_CalculateTickets(@origin VARCHAR(50), @destination VARCHAR(50), @peopleCount INT) 
RETURNS VARCHAR(50)
BEGIN
	IF (@peopleCount <= 0)
	BEGIN
		RETURN 'Invalid people count!'
	END

	DECLARE @flight INT = (SELECT f.Id
			       FROM Flights AS f
			       JOIN Tickets AS t ON f.Id = t.FlightId
			       WHERE f.Destination = @destination AND f.Origin = @origin)

	IF (@flight IS NULL)
	BEGIN 
		RETURN 'Invalid flight!'
	END 

	DECLARE @price DECIMAL(15,2) = (SELECT t.Price
					FROM Tickets AS t
					JOIN Flights AS f ON t.FlightId = f.Id
					WHERE f.Destination = @destination AND f.Origin = @origin)

	DECLARE @totalPrice DECIMAL(15,2) = @peopleCount * @price

	RETURN 'Total price' + ' ' + CAST(@totalPrice as VARCHAR(30))
END

GO

SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', 33)

GO

--19.Wrong Data
--************************

CREATE PROC usp_CancelFlights
AS
BEGIN
	UPDATE Flights
	SET ArrivalTime = NULL, DepartureTime = NULL
	WHERE ArrivalTime > DepartureTime
END

GO

EXEC usp_CancelFlights

GO

--20.Deleted Planes
--************************

CREATE TABLE DeletedPlanes (Id INT,
			    [Name] VARCHAR(30),
			    Seats INT, 
		            [Range] INT)

GO

CREATE TRIGGER tr_DeletedPlanes ON Planes
AFTER DELETE AS 
	INSERT INTO DeletedPlanes (Id, [Name], Seats, [Range]) 
      (SELECT Id, [Name], Seats, [Range] FROM deleted)

GO

DELETE Tickets
WHERE FlightId IN (SELECT Id FROM Flights WHERE PlaneId = 8)

DELETE FROM Flights
WHERE PlaneId = 8

DELETE FROM Planes
WHERE Id = 8

