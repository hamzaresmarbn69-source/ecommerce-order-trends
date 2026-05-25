-- ==============================
-- DATABASE
-- ==============================
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'e_commerce_order_trends')
BEGIN
    DROP DATABASE e_commerce_order_trends;
END
GO

CREATE DATABASE e_commerce_order_trends;
GO

USE e_commerce_order_trends;
GO

-- ==============================
-- TABLES
-- ==============================

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    Address NVARCHAR(MAX)
);

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    Stock INT
);

CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2),
    Status VARCHAR(20) CHECK (Status IN ('Pending','Shipped','Delivered','Cancelled')),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    Price DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

CREATE TABLE Coupons (
    CouponID INT IDENTITY(1,1) PRIMARY KEY,
    Code VARCHAR(50),
    DiscountPercentage DECIMAL(5,2)
);

CREATE TABLE OrderCoupons (
    OrderCouponID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    CouponID INT,
    DiscountAmount DECIMAL(10,2),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (CouponID) REFERENCES Coupons(CouponID)
);

CREATE TABLE ProductReviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    CustomerID INT,
    Rating INT,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

CREATE TABLE Shipments (
    ShipmentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    Carrier VARCHAR(100),
    Status VARCHAR(50),
    ShippedDate DATE NULL,       
    DeliveredDate DATE NULL,     
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
GO

-- ==============================
-- INSERT DATA
-- ==============================

INSERT INTO Customers (Name, Email, Phone, Address) VALUES
('John Doe','john@example.com','1234567890','NY'),
('Jane Smith','jane@example.com','9876543210','CA'),
('Alice Brown','alice@example.com','1112223333','TX'),
('Bob White','bob@example.com','4445556666','FL');

INSERT INTO Products (ProductName, Category, Price, Stock) VALUES
('Laptop','Electronics',1000,20),
('Headphones','Accessories',50,100),
('Smartphone','Electronics',800,30),
('Backpack','Accessories',40,50),
('Gaming Console','Electronics',500,15),
('Mouse','Accessories',25,200),
('Smartwatch','Electronics',300,40);

INSERT INTO Orders (CustomerID, TotalAmount, Status, OrderDate) VALUES
(1,1050,'Shipped','2024-12-01'),
(2,850,'Delivered','2024-11-28'),
(3,525,'Delivered','2024-11-30'),
(4,325,'Shipped','2024-12-05');

INSERT INTO OrderDetails (OrderID, ProductID, Quantity, Price) VALUES
(1,1,1,1000),
(1,2,1,50),
(2,3,1,800),
(2,4,1,40),
(3,5,1,500),
(3,6,1,25),
(4,7,1,300);

INSERT INTO Coupons (Code, DiscountPercentage) VALUES
('WELCOME10',10),
('FESTIVE20',20),
('HOLIDAY15',15);

INSERT INTO OrderCoupons (OrderID, CouponID, DiscountAmount) VALUES
(1,1,100),
(2,2,170),
(3,3,78.75);

INSERT INTO ProductReviews (ProductID, CustomerID, Rating) VALUES
(1,1,5),
(2,2,4),
(5,3,5),
(6,4,4);

INSERT INTO Shipments (OrderID, Carrier, Status, ShippedDate, DeliveredDate) VALUES
(1,'FedEx','In Transit', '2024-12-02', NULL),
(2,'UPS','Delivered', '2024-11-29', '2024-12-02'),
(3,'DHL','Delivered', '2024-12-01', '2024-12-05'),
(4,'FedEx','In Transit', '2024-12-06', NULL);
GO

-- ==============================
-- QUERIES & OBJECTS
-- ==============================

-- Q1: Average prices > 100
SELECT Category, AVG(Price) AS AvgPrice
FROM Products
GROUP BY Category
HAVING AVG(Price) > 100;

-- Q2: Top 5 best-selling products (Uses TOP instead of LIMIT)
SELECT TOP 5 p.ProductName, SUM(od.Quantity) AS TotalSold
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY TotalSold DESC;
GO

-- Q3: Trigger for updating stock
CREATE TRIGGER update_stock_after_order
ON OrderDetails
AFTER INSERT
AS
BEGIN
    UPDATE Products
    SET Stock = Products.Stock - i.Quantity
    FROM Products
    JOIN inserted i ON Products.ProductID = i.ProductID;
END;
GO

-- Q4: 5-star reviews
SELECT p.ProductName, COUNT(*) AS Total_5_Star_Reviews
FROM ProductReviews r
JOIN Products p ON r.ProductID = p.ProductID
WHERE r.Rating = 5
GROUP BY p.ProductName;

-- Q5: Discounts applied
SELECT OrderID, DiscountAmount
FROM OrderCoupons;

-- Q6: Orders per month (Uses MONTH function)
SELECT MONTH(OrderDate) AS OrderMonth, COUNT(*) AS TotalOrders
FROM Orders
GROUP BY MONTH(OrderDate);
GO

-- Q7: Create and query View
CREATE VIEW customer_orders_view AS
SELECT o.OrderID, c.Name AS CustomerName, o.Status
FROM Orders o
JOIN Customers c ON o.CustomerID = c.CustomerID;
GO

SELECT * FROM customer_orders_view WHERE Status = 'Shipped';

-- Q8: Top spending customers
SELECT c.Name, SUM(o.TotalAmount) AS TotalSpent
FROM Orders o 
JOIN Customers c ON o.CustomerID = c.CustomerID
GROUP BY c.Name
ORDER BY TotalSpent DESC;

-- Q9: Average ratings
SELECT p.ProductName, AVG(CAST(r.Rating AS DECIMAL(3,2))) AS AvgRating, COUNT(r.ReviewID) AS TotalReviews
FROM Products p
JOIN ProductReviews r ON p.ProductID = r.ProductID
GROUP BY p.ProductName;

-- Q10: Carrier shipment count
SELECT Carrier, COUNT(*) AS TotalShipments 
FROM Shipments 
GROUP BY Carrier;

-- Q11: Orders placed in 2024 (Uses YEAR function)
SELECT OrderID, OrderDate FROM Orders WHERE YEAR(OrderDate) = 2024;

-- Q12: Window Function Rank
SELECT c.Name,
       SUM(o.TotalAmount) AS TotalSpent,
       RANK() OVER (ORDER BY SUM(o.TotalAmount) DESC) AS RankPosition
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.Name;

-- Q13: Delivery time calculation (Fixed DATEDIFF syntax)
SELECT 
    s.OrderID,
    DATEDIFF(day, s.ShippedDate, s.DeliveredDate) AS DeliveryDays
FROM
    Shipments s
WHERE
    s.Status = 'Delivered';

-- Q14: Case statement pricing categories
SELECT 
    ProductName,
    CASE
        WHEN Price < 100 THEN 'Low'
        WHEN Price BETWEEN 100 AND 500 THEN 'Medium'
        ELSE 'High'
    END AS Category
FROM
    Products;

-- Q15: Unique delivered orders per customer
SELECT c.Name, COUNT(DISTINCT o.OrderID) AS UniqueDeliveredOrders
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.Status = 'Delivered'
GROUP BY c.Name;