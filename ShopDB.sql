DROP database ShopDB;

CREATE DATABASE ShopDB;

USE ShopDB;


CREATE TABLE Employees
	(
		EmployeeID int NOT NULL,
		FName varchar(15) NOT NULL,
		LName varchar(15) NOT NULL,
		MName varchar(15) NOT NULL,
		Salary double NOT NULL,
		PriorSalary double NOT NULL,
		HireDate date NOT NULL,
		TerminationDate date NULL,
		ManagerEmpID int NULL
	) ;


ALTER TABLE Employees ADD 
	CONSTRAINT PK_Employees PRIMARY KEY(EmployeeID) ;


ALTER TABLE Employees ADD CONSTRAINT
	FK_Employees_Employees FOREIGN KEY(ManagerEmpID) 
	REFERENCES Employees(EmployeeID)  ;


CREATE TABLE Customers
	(
	CustomerNo int NOT NULL auto_increment,
	FName varchar(15) NOT NULL,
	LName varchar(15) NOT NULL,
	MName varchar(15) NULL,
	Address1 varchar(50) NOT NULL,
	Address2 varchar(50) NULL,
	City char(10) NOT NULL,
	Phone char(12) NOT NULL,
	DateInSystem date NULL,
    primary key(CustomerNo)
	);  

CREATE TABLE Orders
	(
	OrderID int NOT NULL auto_increment,
	CustomerNo int NULL,
	OrderDate date NOT NULL,
	EmployeeID int NULL,
    primary key(OrderID)
	);



ALTER TABLE Orders ADD CONSTRAINT
	FK_Orders_Customers FOREIGN KEY(CustomerNo) 
	REFERENCES Customers(CustomerNo) 
		ON UPDATE  CASCADE 
		ON DELETE  SET NULL ;

ALTER TABLE Orders ADD CONSTRAINT
	FK_Orders_Employees FOREIGN KEY(EmployeeID) 
	REFERENCES Employees(EmployeeID)
		ON UPDATE  CASCADE 
		ON DELETE  SET NULL ;

---
CREATE TABLE Products
	(
	ProdID int NOT NULL auto_increment,
	Description char(50) NOT NULL,
	UnitPrice double NULL,
	Weight numeric(18, 0) NULL,
	primary key(ProdID));
  



CREATE TABLE OrderDetails
	(
	OrderID int NOT NULL,
	LineItem int NOT NULL,
	ProdID int NULL,
	Qty int NOT NULL,
	UnitPrice double NOT NULL,
	TotalPrice int
	)  ;

ALTER TABLE OrderDetails ADD CONSTRAINT
	PK_OrderDetails PRIMARY KEY
	(OrderID,LineItem) ;


ALTER TABLE OrderDetails ADD CONSTRAINT
	FK_OrderDetails_Products FOREIGN KEY(ProdID) 
		REFERENCES Products(ProdID) 
		ON UPDATE  NO ACTION 
		ON DELETE  SET NULL ;

ALTER TABLE OrderDetails ADD CONSTRAINT
	FK_OrderDetails_Orders FOREIGN KEY(OrderID) 
	REFERENCES Orders(OrderID) 
	 ON UPDATE  CASCADE 
	 ON DELETE  CASCADE;
 
INSERT Employees
(EmployeeID, FName, MName, LName, Salary, PriorSalary, HireDate, TerminationDate, ManagerEmpID)
VALUES
(2,'Иван', 'Иванович', 'Белецкий', 2000, 0, '2009-11-20', NULL, NULL),
(3,'Петр', 'Григорьевич', 'Дяченко', 1000, 0, '2009-11-20', NULL, 2),
(4,'Светлана', 'Олеговна', 'Лялечкина', 800, 0, '2009-11-20', NULL, 2);


INSERT Customers 
(LName, FName, MName, Address1, Address2, City, Phone,DateInSystem)
VALUES
('Круковский','Анатолий','Петрович','Лужная 15',NULL,'Харьков','(092)3212211','2009-11-20'),
('Дурнев','Виктор','Викторович','Зелинская 10',NULL,'Киев','(067)4242132','2009-11-20'),
('Унакий','Зигмунд','Федорович','Дихтяревская 5',NULL,'Киев','(092)7612343','2009-11-20'),
('Левченко','Виталий','Викторович','Глущенка 5','Драйзера 12','Киев','(053)3456788','2009-11-20'),
('Выжлецов','Олег','Евстафьевич','Киевская 3','Одесская 8','Чернигов','(044)2134212','2009-11-20');


INSERT Products
( Description, UnitPrice, Weight )
VALUES
('LV231 Джинсы',45,0.9),
('GC111 Футболка',20,0.3),
('GC203 Джинсы',48,0.7),
('DG30 Ремень',30,0.5),
('LV12 Обувь',26,1),
('GC11 Шапка',32,0.35);


INSERT Orders
(CustomerNo, OrderDate, EmployeeID)
VALUES
(1,'2009-11-20',2),
(3,'2009-11-20',4),
(5,'2009-11-20',4);

INSERT OrderDetails
(OrderID, LineItem, ProdID, Qty, UnitPrice, TotalPrice)
VALUES
(1,1,1,5,45, 45*5),
(1,2,4,16,75, 75*16),
(1,3,5,5,25, 25*5),
(2,1,6,10,32, 32*10),
(2,2,2,15,20, 20*5),
(3,1,5,20,26, 26*20),
(3,2,6,38,32, 32*38);

SELECT * FROM Employees;
SELECT * FROM OrderDetails;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM Customers;

-- Используя JOIN’s и ShopDB получить имена покупателей и имена сотрудников у которых TotalPrice товара больше 1000
SELECT Customers.FName AS CustomerFName, Customers.MName AS CustomerMName, Customers.LName AS CustomerLName, Employees.FName AS EmployeeFName, 
Employees.MName AS EmployeeMName, Employees.LName AS EmployeeLName, Orderdetails.TotalPrice
FROM Customers 
JOIN Orders ON Customers.CustomerNo = Orders.CustomerNo
JOIN Employees ON Orders.EmployeeID = Employees.EmployeeID
JOIN Orderdetails ON Orderdetails.OrderID = Orders.OrderID
WHERE Orderdetails.TotalPrice > 1000;

/* -- Используя вложенные запросы и ShopDB получить имена покупателей и имена сотрудников у которых TotalPrice товара больше 1000
SELECT FName AS CustomerFName, MName AS CustomerMName, LName AS CustomerLName
FROM Customers
WHERE CustomerNo IN (SELECT CustomerNo FROM Orders WHERE OrderID IN (SELECT OrderID from OrderDetails Where TotalPrice>1000))
UNION
SELECT FName AS EmployeeFName, MName AS EmployeeMName, LName AS EmployeeLName
FROM Employees
WHERE EmployeeID IN (SELECT EmployeeID FROM Orders WHERE OrderID IN (SELECT OrderID from OrderDetails Where TotalPrice>1000));
*/
-- Используя вложенные запросы и ShopDB получить имена покупателей и имена сотрудников у которых TotalPrice товара больше 1000
SELECT o.OrderID,
(SELECT SUM(od.TotalPrice) FROM OrderDetails od WHERE od.orderID = o.OrderID) "Total Order",
(SELECT CONCAT(e.FName, ' ', e.MName, ' ', e.LName) FROM Employees e WHERE e.EmployeeID = o.EmployeeID) "Seller",
(SELECT CONCAT(c.FName, ' ', c.MName, ' ', c.LName) FROM Customers c WHERE c.CustomerNo = o.CustomerNo) "Customer"
FROM Orders o
WHERE (SELECT SUM(od.TotalPrice) FROM OrderDetails od WHERE od.orderID = o.orderID) > 1000;