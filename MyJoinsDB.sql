DROP database MyJoinsDB;
CREATE DATABASE MyJoinsDB;
USE MyJoinsDB;

# В 1-й таблице содержатся имена и номера телефонов сотрудников компании
CREATE TABLE Employees (
  EmployeeID INT PRIMARY KEY AUTO_INCREMENT,
  FirstName VARCHAR(50),
  LastName VARCHAR(50),
  PhoneNumber VARCHAR(20)
);
# Во 2-й таблице содержатся ведомости о зарплате и должностях сотрудников: главный директор, менеджер, рабочий.
CREATE TABLE Salaries (
  EmployeeID INT ,
  Position VARCHAR(50),
  Salary DECIMAL(10,2),
  PRIMARY KEY (EmployeeID),
  foreign key (EmployeeID) REFERENCES Employees(EmployeeID)
);

CREATE TABLE PersonalInfo (
  EmployeeID INT ,
  BirthDate DATE,
  MaritalStatus VARCHAR(10),
  Address VARCHAR(100),
  PRIMARY KEY (EmployeeID),
  foreign key (EmployeeID) REFERENCES Employees(EmployeeID)
);

Получите информацию обо всех менеджерах компании: дату рождения и номер телефона. 

INSERT INTO Employees (EmployeeID, FirstName, LastName, PhoneNumber)
VALUES (1, 'Іван', 'Сірко', '+380-97-123-45-67'),
       (2, 'Петро', 'Сагайдачний', '+380-66-789-12-34'),
       (3, 'Сергій', 'Богдан', '+380-50-901-23-45'),
       (4, 'Ольга', 'Тригуб', '+380-63-456-78-90'),
       (5, 'Наталія', 'Мосійчук', '+380-97-555-55-55');

INSERT INTO Salaries (EmployeeID, Position, Salary)
VALUES (1, 'головний директор', 100000),
       (2, 'менеджер', 50000),
       (3, 'робітник', 25000),
       (4, 'робітник', 25000),
       (5, 'робітник', 25000);
       
INSERT INTO PersonalInfo (EmployeeID, BirthDate, MaritalStatus, Address)
VALUES (1, '1980-01-01', 'одружений', 'м. Київ, вул. Леніна, 1'),
       (2, '1985-03-15', 'холостий', 'м. Львів, вул. Галицька, 20'),
       (3, '1990-05-20', 'холостий', 'м. Харків, вул. Гагаріна, 5'),
       (4, '1995-07-25', 'заміжня', 'м. Одеса, вул. Дерибасівська, 10'),
       (5, '2000-09-30', 'холостий', 'м. Дніпро, просп. Гагаріна, 15');

-- Сделайте выборку при помощи JOIN’s для таких заданий: 
-- 1) Получите контактные данные сотрудников (номера телефонов, место жительства). 

SELECT Employees.EmployeeID, Employees.FirstName, Employees.LastName, Employees.PhoneNumber, PersonalInfo.Address
FROM Employees
INNER JOIN PersonalInfo ON PersonalInfo.EmployeeID = Employees.EmployeeID;

-- 2) Получите информацию о дате рождения всех холостых сотрудников и их номера. 

SELECT Employees.EmployeeID, Employees.FirstName, Employees.LastName, Employees.PhoneNumber, PersonalInfo.BirthDate, PersonalInfo.MaritalStatus
FROM Employees 
INNER JOIN PersonalInfo ON PersonalInfo.EmployeeID = Employees.EmployeeID
WHERE PersonalInfo.MaritalStatus LIKE 'холостий';

-- 3) Получите информацию обо всех менеджерах компании: дату рождения и номер телефона. 
SELECT Employees.EmployeeID, Employees.FirstName, Employees.LastName, PersonalInfo.BirthDate, Employees.PhoneNumber, Salaries.Position
FROM Employees 
INNER JOIN PersonalInfo ON Employees.EmployeeID = PersonalInfo.EmployeeID
INNER JOIN Salaries ON Employees.EmployeeID = Salaries.EmployeeID
WHERE Salaries.Position = 'менеджер';

-- Сделайте выборку при помощи вложенных запросов для таких заданий: 1) Получите контактные данные сотрудников (номера телефонов, место жительства). 
SELECT e.EmployeeID, e.FirstName, e.LastName, e.PhoneNumber,
(SELECT p.Address FROM PersonalInfo p WHERE p.EmployeeID = e.EmployeeID) AS Address
FROM Employees e;

-- 2) Получите информацию о дате рождения всех холостых сотрудников и их номера. 
SELECT e.EmployeeID, e.FirstName, e.LastName, e.PhoneNumber,
(SELECT p.BirthDate FROM PersonalInfo p WHERE p.EmployeeID = e.EmployeeID) BirthDate,
(SELECT p.MaritalStatus FROM PersonalInfo p WHERE p.EmployeeID = e.EmployeeID ) MaritalStatus
FROM Employees e
WHERE e.EmployeeID IN (SELECT p.EmployeeID FROM PersonalInfo p WHERE p.MaritalStatus LIKE 'холостий');

-- 3) Получите информацию обо всех менеджерах компании: дату рождения и номер телефона. 
SELECT e.EmployeeID, e.FirstName, e.LastName, e.PhoneNumber,
(SELECT p.BirthDate FROM PersonalInfo p WHERE p.EmployeeID = e.EmployeeID) BirthDate,
(SELECT s.Position FROM Salaries s WHERE s.EmployeeID = e.EmployeeID) Position
FROM Employees e
INNER JOIN PersonalInfo p ON e.EmployeeID = p.EmployeeID
WHERE e.EmployeeID IN (SELECT s.EmployeeID FROM Salaries s WHERE s.Position = 'менеджер');
