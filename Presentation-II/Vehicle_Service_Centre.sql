-- FOR A FRESH DATABASE ONLY. Do not run if your database already exists.
CREATE DATABASE VehicleServiceCentre;
USE VehicleServiceCentre;


-- 1. CUSTOMER
CREATE TABLE CUSTOMER (
    Customer_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Phone VARCHAR(15) NOT NULL UNIQUE,
    Email VARCHAR(100) UNIQUE
);

INSERT INTO CUSTOMER VALUES
(1, 'Ravi', '9876543210', 'ravi@gmail.com'),
(2, 'Anu', '9876543211', 'anu@gmail.com'),
(3, 'Arun', '9876543212', 'arun@gmail.com'),
(4, 'Priya', '9876543213', 'priya@gmail.com'),
(5, 'Kiran', '9876543214', 'kiran@gmail.com'),
(6, 'Sneha', '9876543215', 'sneha@gmail.com'),
(7, 'Rahul', '9876543216', 'rahul@gmail.com'),
(8, 'Meena', '9876543217', 'meena@gmail.com'),
(9, 'Vijay', '9876543218', 'vijay@gmail.com'),
(10, 'Pooja', '9876543219', 'pooja@gmail.com');


-- 2. VEHICLE
CREATE TABLE VEHICLE (
    Vehicle_ID INT PRIMARY KEY,
    Registration_No VARCHAR(20) NOT NULL UNIQUE,
    Model VARCHAR(50) NOT NULL,
    Customer_ID INT NOT NULL,
    FOREIGN KEY (Customer_ID) REFERENCES CUSTOMER(Customer_ID)
);

INSERT INTO VEHICLE VALUES
(101, 'TS09AB1234', 'Creta', 1),
(102, 'TS10CD5678', 'Swift', 2),
(103, 'TS08EF9012', 'City', 3),
(104, 'TS11GH3456', 'Nexon', 4),
(105, 'TS12IJ7890', 'Glanza', 5),
(106, 'TS13KL2468', 'Seltos', 6),
(107, 'TS14MN1357', 'i20', 7),
(108, 'TS15OP8642', 'Amaze', 8),
(109, 'TS16QR9753', 'Harrier', 9),
(110, 'TS17ST6420', 'Baleno', 10);


-- 3. SERVICE_BOOKING
CREATE TABLE SERVICE_BOOKING (
    Booking_ID INT PRIMARY KEY,
    Service_Date DATE NOT NULL,
    Status VARCHAR(30) NOT NULL DEFAULT 'Booked',
    Vehicle_ID INT NOT NULL,
    FOREIGN KEY (Vehicle_ID) REFERENCES VEHICLE(Vehicle_ID),
    CHECK (Status IN ('Booked', 'In Progress', 'Completed', 'Cancelled'))
);

INSERT INTO SERVICE_BOOKING VALUES
(201, '2026-09-10', 'Completed', 101),
(202, '2026-09-12', 'In Progress', 102),
(203, '2026-09-14', 'Booked', 103),
(204, '2026-09-08', 'Completed', 104),
(205, '2026-09-15', 'In Progress', 105),
(206, '2026-09-16', 'Booked', 106),
(207, '2026-09-17', 'Booked', 107),
(208, '2026-09-18', 'Booked', 108),
(209, '2026-09-11', 'Completed', 109),
(210, '2026-09-13', 'Completed', 110);


-- 4. JOB_CARD
CREATE TABLE JOB_CARD (
    Job_Card_ID INT PRIMARY KEY,
    Created_Date DATE NOT NULL,
    Job_Status VARCHAR(30) NOT NULL DEFAULT 'Open',
    Booking_ID INT NOT NULL UNIQUE,
    FOREIGN KEY (Booking_ID) REFERENCES SERVICE_BOOKING(Booking_ID),
    CHECK (Job_Status IN ('Open', 'In Progress', 'Completed', 'Cancelled'))
);

INSERT INTO JOB_CARD VALUES
(301, '2026-09-10', 'Completed', 201),
(302, '2026-09-12', 'In Progress', 202),
(303, '2026-09-14', 'Open', 203),
(304, '2026-09-08', 'Completed', 204),
(305, '2026-09-15', 'In Progress', 205),
(306, '2026-09-16', 'Open', 206),
(307, '2026-09-17', 'Open', 207),
(308, '2026-09-18', 'Open', 208),
(309, '2026-09-11', 'Completed', 209),
(310, '2026-09-13', 'Completed', 210);


-- 5. TASK
CREATE TABLE TASK (
    Task_ID INT PRIMARY KEY,
    Description VARCHAR(150) NOT NULL,
    Labour_Charge DECIMAL(10,2) NOT NULL,
    Job_Card_ID INT NOT NULL,
    FOREIGN KEY (Job_Card_ID) REFERENCES JOB_CARD(Job_Card_ID),
    CHECK (Labour_Charge >= 0)
);

INSERT INTO TASK VALUES
(401, 'Oil Change', 800.00, 301),
(402, 'Brake Check', 500.00, 301),
(403, 'AC Service', 1200.00, 302),
(404, 'Wheel Alignment', 600.00, 303),
(405, 'Engine Service', 1500.00, 304),
(406, 'Battery Check', 300.00, 305),
(407, 'Brake Repair', 1000.00, 306),
(408, 'General Check', 400.00, 307),
(409, 'Filter Change', 500.00, 308),
(410, 'Engine Tune', 1300.00, 309),
(411, 'Tyre Check', 450.00, 310),
(412, 'AC Check', 700.00, 310);


-- 6. MECHANIC
CREATE TABLE MECHANIC (
    Mechanic_ID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Specialization VARCHAR(100),
    Phone VARCHAR(15) UNIQUE
);

INSERT INTO MECHANIC VALUES
(501, 'Ram', 'Engine', '9000000001'),
(502, 'Raj', 'Brakes', '9000000002'),
(503, 'Sam', 'AC', '9000000003'),
(504, 'Ajay', 'General', '9000000004'),
(505, 'Amit', 'Electrical', '9000000005'),
(506, 'Ravi', 'Engine', '9000000006'),
(507, 'Kiran', 'Brakes', '9000000007'),
(508, 'Vijay', 'General', '9000000008');


-- 7. ASSIGNMENT
CREATE TABLE ASSIGNMENT (
    Assignment_ID INT PRIMARY KEY,
    Start_Time DATETIME NOT NULL,
    End_Time DATETIME NOT NULL,
    Task_ID INT NOT NULL,
    Mechanic_ID INT NOT NULL,
    FOREIGN KEY (Task_ID) REFERENCES TASK(Task_ID),
    FOREIGN KEY (Mechanic_ID) REFERENCES MECHANIC(Mechanic_ID),
    CHECK (End_Time > Start_Time)
);

INSERT INTO ASSIGNMENT VALUES
(601, '2026-09-10 09:00:00', '2026-09-10 10:00:00', 401, 501),
(602, '2026-09-10 10:15:00', '2026-09-10 11:00:00', 402, 502),
(603, '2026-09-12 09:30:00', '2026-09-12 11:00:00', 403, 503),
(604, '2026-09-14 10:00:00', '2026-09-14 11:00:00', 404, 504),
(605, '2026-09-08 09:00:00', '2026-09-08 11:00:00', 405, 506),
(606, '2026-09-15 09:00:00', '2026-09-15 10:00:00', 406, 505),
(607, '2026-09-16 09:00:00', '2026-09-16 10:30:00', 407, 507),
(608, '2026-09-17 09:00:00', '2026-09-17 10:00:00', 408, 508),
(609, '2026-09-18 09:30:00', '2026-09-18 10:30:00', 409, 504),
(610, '2026-09-11 09:00:00', '2026-09-11 10:30:00', 410, 501),
(611, '2026-09-13 10:00:00', '2026-09-13 11:00:00', 411, 508),
(612, '2026-09-13 11:15:00', '2026-09-13 12:00:00', 412, 503);


-- 8. INSPECTION
CREATE TABLE INSPECTION (
    Inspection_ID INT PRIMARY KEY,
    Inspection_Date DATE NOT NULL,
    Findings VARCHAR(255),
    Job_Card_ID INT NOT NULL,
    FOREIGN KEY (Job_Card_ID) REFERENCES JOB_CARD(Job_Card_ID)
);

INSERT INTO INSPECTION VALUES
(701, '2026-09-10', 'Oil checked', 301),
(702, '2026-09-12', 'AC needs service', 302),
(703, '2026-09-14', 'Alignment needed', 303),
(704, '2026-09-08', 'Engine normal', 304),
(705, '2026-09-15', 'Battery low', 305),
(706, '2026-09-16', 'Brake pads worn', 306),
(707, '2026-09-17', 'Vehicle checked', 307),
(708, '2026-09-18', 'Filter needs change', 308),
(709, '2026-09-11', 'Engine needs tune', 309),
(710, '2026-09-13', 'Tyres checked', 310);


-- 9. SPARE_PART
CREATE TABLE SPARE_PART (
    Part_ID INT PRIMARY KEY,
    Part_Name VARCHAR(100) NOT NULL,
    Stock_Quantity INT NOT NULL DEFAULT 0,
    Unit_Price DECIMAL(10,2) NOT NULL,
    CHECK (Stock_Quantity >= 0),
    CHECK (Unit_Price >= 0)
);

INSERT INTO SPARE_PART VALUES
(801, 'Oil Filter', 20, 450.00),
(802, 'Brake Pad', 10, 1800.00),
(803, 'Air Filter', 15, 700.00),
(804, 'Spark Plug', 25, 350.00),
(805, 'Battery', 8, 4500.00),
(806, 'Engine Oil', 30, 650.00),
(807, 'AC Filter', 12, 900.00),
(808, 'Brake Fluid', 18, 500.00),
(809, 'Coolant', 20, 400.00),
(810, 'Drive Belt', 10, 1200.00);


-- 10. PART_USAGE
CREATE TABLE PART_USAGE (
    Usage_ID INT PRIMARY KEY,
    Quantity INT NOT NULL,
    Job_Card_ID INT NOT NULL,
    Part_ID INT NOT NULL,
    FOREIGN KEY (Job_Card_ID) REFERENCES JOB_CARD(Job_Card_ID),
    FOREIGN KEY (Part_ID) REFERENCES SPARE_PART(Part_ID),
    CHECK (Quantity > 0)
);

INSERT INTO PART_USAGE VALUES
(901, 1, 301, 801),
(902, 1, 301, 803),
(903, 1, 302, 807),
(904, 1, 304, 802),
(905, 4, 304, 804),
(906, 1, 305, 805),
(907, 1, 306, 802),
(908, 1, 307, 806),
(909, 1, 308, 803),
(910, 1, 309, 806),
(911, 1, 310, 809),
(912, 1, 310, 807);


-- 11. INVOICE
CREATE TABLE INVOICE (
    Invoice_ID INT PRIMARY KEY,
    Invoice_Date DATE NOT NULL,
    Total_Amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    Job_Card_ID INT NOT NULL UNIQUE,
    FOREIGN KEY (Job_Card_ID) REFERENCES JOB_CARD(Job_Card_ID),
    CHECK (Total_Amount >= 0)
);

INSERT INTO INVOICE VALUES
(1001, '2026-09-10', 2450.00, 301),
(1002, '2026-09-08', 4700.00, 304),
(1003, '2026-09-11', 1950.00, 309),
(1004, '2026-09-13', 2650.00, 310);


-- 12. PAYMENT
CREATE TABLE PAYMENT (
    Payment_ID INT PRIMARY KEY,
    Payment_Date DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Payment_Mode VARCHAR(30) NOT NULL,
    Invoice_ID INT NOT NULL,
    FOREIGN KEY (Invoice_ID) REFERENCES INVOICE(Invoice_ID),
    CHECK (Amount > 0),
    CHECK (Payment_Mode IN ('Cash', 'Card', 'UPI', 'Online'))
);

INSERT INTO PAYMENT VALUES
(1101, '2026-09-10', 2450.00, 'UPI', 1001),
(1102, '2026-09-08', 4700.00, 'Card', 1002),
(1103, '2026-09-11', 1950.00, 'Cash', 1003),
(1104, '2026-09-13', 2650.00, 'Online', 1004);


-- CHECK TABLES
SHOW TABLES;

SELECT * FROM CUSTOMER;
SELECT * FROM VEHICLE;
SELECT * FROM SERVICE_BOOKING;
SELECT * FROM JOB_CARD;
SELECT * FROM TASK;
SELECT * FROM MECHANIC;
SELECT * FROM ASSIGNMENT;
SELECT * FROM INSPECTION;
SELECT * FROM SPARE_PART;
SELECT * FROM PART_USAGE;
SELECT * FROM INVOICE;
SELECT * FROM PAYMENT;


-- QUERIES

-- 1. Completed jobs
SELECT * FROM JOB_CARD
WHERE Job_Status = 'Completed';


-- 2. Customer and vehicle details
SELECT c.Name, v.Registration_No, v.Model
FROM CUSTOMER c
JOIN VEHICLE v
ON c.Customer_ID = v.Customer_ID;


-- 3. Complete service details
SELECT c.Name, v.Registration_No, v.Model,
       sb.Service_Date, jc.Job_Status
FROM CUSTOMER c
JOIN VEHICLE v
ON c.Customer_ID = v.Customer_ID
JOIN SERVICE_BOOKING sb
ON v.Vehicle_ID = sb.Vehicle_ID
JOIN JOB_CARD jc
ON sb.Booking_ID = jc.Booking_ID;


-- 4. Total customers
SELECT COUNT(*) AS Total_Customers
FROM CUSTOMER;


-- 5. Highest labour charge
SELECT MAX(Labour_Charge) AS Highest_Labour_Charge
FROM TASK;


-- 6. Average labour charge
SELECT AVG(Labour_Charge) AS Average_Labour_Charge
FROM TASK;


-- 7. Mechanic workload
SELECT m.Name, COUNT(a.Assignment_ID) AS Total_Assignments
FROM MECHANIC m
JOIN ASSIGNMENT a
ON m.Mechanic_ID = a.Mechanic_ID
GROUP BY m.Mechanic_ID, m.Name;


-- 8. Spare parts used
SELECT jc.Job_Card_ID, sp.Part_Name, pu.Quantity
FROM PART_USAGE pu
JOIN JOB_CARD jc
ON pu.Job_Card_ID = jc.Job_Card_ID
JOIN SPARE_PART sp
ON pu.Part_ID = sp.Part_ID;


-- 9. Total revenue
SELECT SUM(Total_Amount) AS Total_Revenue
FROM INVOICE;


-- 10. Payments by mode
SELECT Payment_Mode, COUNT(*) AS Number_of_Payments
FROM PAYMENT
GROUP BY Payment_Mode;